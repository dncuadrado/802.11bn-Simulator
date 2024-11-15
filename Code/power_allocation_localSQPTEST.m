function [P_opt, is_feasible] = power_allocation_localSQPTEST(N, noise_power, H, P_max, P0, SinrThreshold)
    
    % Objective function for sum rate maximization
    % objective = @(P) -sum(log2(1 + (P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P)));
    objective = @(P) -sum(log(log2(1 + (P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P))));

    % Constraints
    lb = zeros(N, 1); % Lower bound: P >= 0
    ub = P_max * ones(N, 1); % Upper bound: P <= P_max

    % Nonlinear constraint function that enforces SINR threshold
    sinr_constraint = @(P) sinr_constraints(P, SinrThreshold, noise_power, H);

    % Options for fmincon
    options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'none', 'OptimalityTolerance', 1e-6);

    % Run optimization
    [P_opt, ~, exitflag] = fmincon(objective, P0, [], [], [], [], lb, ub, sinr_constraint, options);
    
    % Check feasibility of the solution
    [c, ~] = sinr_constraints(P_opt, SinrThreshold, noise_power, H);
    is_feasible = all(c <= 0); % Solution is feasible if all constraints are satisfied
    
    % If the solution is infeasible, return an empty vector
    if ~is_feasible || exitflag <= 0
        P_opt = []; % No feasible solution found
        is_feasible = false;
    end
end

% Nonlinear constraint for SINR thresholds
function [c, ceq] = sinr_constraints(P, SinrThreshold, noise_power, H)
    % Preallocate constraint vector
    c = zeros(length(SinrThreshold), 1);
    
    % Calculate each SINR constraint
    for i = 1:length(SinrThreshold)
        interference = noise_power + sum(H(i, :) .* P') - H(i, i) * P(i);
        sinr_i = (P(i) * H(i, i)) / interference;
        
        % SINR constraint: must satisfy sinr_i >= SinrThreshold(i)
        c(i) = SinrThreshold(i) - sinr_i; % Constraint c(i) <= 0 if SINR is satisfied
    end
    
    ceq = []; % No equality constraints
end
