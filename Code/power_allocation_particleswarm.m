function P_opt = power_allocation_particleswarm(N, noise_power, H, P_max, Nsc, Nss)


% % Objective function for proportional fairness (maximize product of rates)
objective = @(P) -sum(log(computeRates(P', H, noise_power, N, Nsc, Nss))); % Maximize product of rates

% Objective function for proportional fairness (maximize product of rates)
% objective = @(P) -sum(computeRates(P', H, noise_power, N, Nsc, Nss)); % Maximize product of rates

% Constraints
lb = zeros(N, 1); % Lower bound: P >= 0
ub = P_max * ones(N, 1); % Upper bound: P <= P_max

% Particle Swarm Optimization Options
options = optimoptions('particleswarm', ...
    'Display', 'off', ... % Disable output during optimization
    'SwarmSize', 100, ...
    'MaxIterations', 500, ...
    'UseParallel', false);

% Run the Particle Swarm Optimization
[P_opt, ~] = particleswarm(objective, N, lb, ub, options);
P_opt = P_opt';


% Calculate final product of rates (proportional fairness objective)
% max_rate = exp(-fval);
end

% Nested function to calculate rates
function product_rate = computeRates(P, H, noise_power, N, Nsc, Nss)
    T_DFT = 12.8e-6;            % OFDM symbol duration
    T_GI = 0.8e-6;
    rates = zeros(N, 1); % Initialize rates

    % Compute rates for each link
    sinr_dB = 10*log10((P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P));
    for i = 1:N
        [~, N_bps, Rc] = MCS_cal_PER_001(sinr_dB(i));
        rates(i) = Nsc*N_bps*Rc*Nss/(T_DFT + T_GI);
    end

    % Product of rates
    product_rate = prod(rates); % Return the product of rates
    % product_rate = rates; % Return the product of rates
end