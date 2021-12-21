function [Q, log] = rf1(A, k, p, s, logging)
    %{
    Standard routine for constructing a matrix Q of size 
    (size(A, 2), k) where range(Q) is "reasonably" well aligned with 
    the span of the top k right singular vectors of A.

    Uses power iteration technique (recommended for cases with slow decay 
    of singular values of A), controlled by parameter p. Each power
    iteratin step requires two passes over A.

    s is an int or RandomStream. It controls all random number generation.

    Uses QR decomposition for insuring orthogonality of the columns of
    sketch Q.
    %}
    if logging.depth == 0 || logging.span == 0
        log_present = 0;
        log.status = 'Optional parameter for logging detailed information has not been passed.'; 
    else
        log_present = 1;
    end

    s = MarlaRandStream(s);
    class_A = class(A);
    [~, n] = size(A);
    % By default, a Gaussian random sketching matrix is used.
    % Alternative choices are present in '../../utils/sketching_operators'.
    if log_present, tic, end
    Omega = randn(s, n, k, class_A);
    [Q, ~] = qr(A * Omega, 0);
    if log_present, log.t_sketch = toc; end

    if log_present, tic, end
    for j = 1 : p
        [Q, ~] = qr(A' * Q, 0);
        [Q, ~] = qr(A * Q, 0);
    end
    if log_present, log.t_power_iter = toc; end
end