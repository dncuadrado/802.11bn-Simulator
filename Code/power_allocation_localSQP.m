function [P_opt] = power_allocation_localSQP(N, noise_power, H, P_max, P0)

% % Objective function for proportional fairness (maximize product of rates)
objective = @(P) -sum(log(log2(1 + (P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P))));

% Constraints
lb = zeros(N, 1); % Lower bound: P >= 0
ub = P_max * ones(N, 1); % Upper bound: P <= P_max

% Options for fmincon
% options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter', 'OptimalityTolerance', 1e-6);
options = optimoptions('fmincon', 'Algorithm', 'sqp', 'display', 'none', 'OptimalityTolerance', 1e-6);

% Run optimization
[P_opt, fval] = fmincon(objective, P0, [], [], [], [], lb, ub, [], options);

% Calculate final product of rates (proportional fairness objective)
% max_rate = exp(-fval);


end