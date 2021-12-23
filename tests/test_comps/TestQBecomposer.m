classdef TestQBecomposer
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   Instance methods
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        function obj = TestQBecomposer()
        end

        function[] = run_exact(obj, qth, alg, gen, m, n, rank, target_tol, test_tol, logging)
            
            seed = 24;
            qth.A = gen(m, n, rank, 42);
            qth.k = rank;

            [Q, B, ~] = alg(qth.A, qth.k, seed, logging);
            qth.Q = Q;
            qth.B = B;

            % Run tests
            qth.test_exact(test_tol);
            qth.test_valid_onb(test_tol);
            qth.test_exact_B(test_tol);
            qth.test_exact_rank_B();
        end

        function[] = run_estimated(obj, qth, alg, gen, rank, target_tol, test_tol, logging)
            
            seed = 24;
            qth.A = gen(m, n, rank, 0, 42);
            qth.k = rank;

            [Q, B, ~] = alg(qth.A, qth.k, seed, logging);
            qth.Q = Q;
            qth.B = B;

            % Run tests
            qth.test_exact(test_tol);
            qth.test_valid_onb(test_tol);
            qth.test_exact_B(test_tol);
        end
    end
end