function [x_star, log] = lsqr_sap2(A, b, sampling_factor, tol, iter_lim, smart_init, logging) 
    
    if logging == 0
        disp('Optional parameter for logging detailed information has not been passed.'); 
    end

    [num_rows, num_cols] = size(A);
    d = dim_checks(sampling_factor, num_rows, num_cols);
    
    % Sketch the data matrix.
    if logging, tic, end
    Omega = randn(d, num_rows);
    A_ske = Omega * A;
    if logging, log.t_sketch = toc; end
    
    % Factor the sketch. 
    %  We also measure the time to scale the right singular vectors
    %   as needed for the preconditioner. SAP1 doesn't have a
    %   directly comparable cost.
    if logging, tic, end
    [U, S, V] = svd(A_ske, 'econ');
    % ISSUE TO REPORT: For some reason, [U,S,V] = svd(A,"vector") does not
    % work.
    S = diag(S);
    rank = nnz(S > S(1) * num_cols * eps('double'));
    N = bsxfun(@rdivide, V(1:rank, :)', S(1:rank));
    if logging, log.t_factor = toc; end
    
    if smart_init
        % Sketch-and-solve type preprocessing.
        %   This isn't necessarily preferable, because it changes the
        %   norm of b, which affects termination criteria.  
        if logging, tic, end
        b_ske = Omega * b;
        x_ske = N * (U(:, 1:rank)' * b_ske);
        b_remainder = b - A * x_ske;
        success = norm(b_remainder, 2) < norm(b, 2);
        if logging, log.t_presolve = toc; end
        
        % Iterative phase.
        if success
           % x_ske is a better starting point than the zero vector. 
           if logging, tic, end
           [x_star, ~, ~, iters, resvec, ~] = lsqr(A, b_remainder, tol, iter_lim, N);
           x_star = x_star + ske;
           if logging, log.t_iterate = toc; end 
        else
           % The zero vector is at least as good as x_ske. 
           if logging, tic, end
           [x_star, ~, ~, iters, resvec, ~] = lsqr(A, b, tol, iter_lim, N);
           if logging, log.t_iterate = toc; end 
        end
    else
        % Iterative phase.
        if logging, tic, end
        [x_star, ~, ~, iters, resvec, ~] = lsqr(A, b, tol, iter_lim, N);
        if logging, log.t_iterate = toc; end 
    end
    
    if logging
        % Record a vector of cumulative times to (1) sketch and factor, and
        % (2) take an individual step in LSQR (amortized!).
        %
        % Amortizing the time taken by a single step of LSQR is reasonable,
        % because convergence behavior can be seen by how the normal
        % equation error decays from one iteration to the next.
        t_setup = log.t_sketch + log.t_factor;
        amortized = linspace(0, log.t_iterate, iters);
        cumulative = t_setup + log.t_presolve + amortized;
        log.times = [t_setup cumulative];
        
        % Record a vector of (preconditioned) normal equation errors. Treat
        % the zero vector as a theoretically valid initialization point which
        % we would use before the "solve" phase of "sketch-and-solve".
        ar0 = N' * (A' * b);
        ar0norm = norm(ar0, 'fro');
        log.x = x_star;
        log.arnorms = [ar0norm; resvec];
    end
end

function [d] = dim_checks(sampling_factor, num_rows, num_cols)
    assert(num_rows >= num_cols);
    d = cast((sampling_factor * num_cols), 'uint16');
    if d > num_rows
        fprintf(['The embedding dimension "d" should not be larger than the', ... 
        'number of rows of the data matrix. Here, an embedding dimension', ...
        'of d=%d has been requested for a matrix with only %d rows.', ...
        'We will proceed by setting d=%d. This parameter choice will', ...
        'result in a very inefficient algorithm!'], d, num_rows, num_rows);
        d = num_rows; 
    end
    assert(d >= num_cols);
end