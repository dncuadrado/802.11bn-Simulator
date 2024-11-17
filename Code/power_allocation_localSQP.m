function [P_opt] = power_allocation_localSQP(N, noise_power, H, P_max, P0, Nsc, Nss, SinrThreshold)


% 
% % % Objective function for proportional fairness (maximize product of rates)
objective = @(P) -computeRates(P, H, noise_power, N, Nsc, Nss); % Maximize product of rates

% Constraints
lb = zeros(N, 1); % Lower bound: P >= 0
ub = P_max * ones(N, 1); % Upper bound: P <= P_max

% Nonlinear constraint function that enforces SINR threshold
sinr_constraint = @(P) sinr_constraints(P, SinrThreshold, noise_power, H);

% Options for fmincon
options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'none', 'OptimalityTolerance', 1e-6);

% Run optimization
[P_opt, ~, ~] = fmincon(objective, P0, [], [], [], [], lb, ub, sinr_constraint, options);

%%% If not power allocation posible with the SINR constraints, return the max power vector
if isempty(P_opt)
    P_opt = P_max * ones(N, 1);
end

end

% Nonlinear constraint for SINR thresholds
function [c, ceq] = sinr_constraints(P, SinrThreshold, noise_power, H)

% Compute rates for each link
sinr_dB = 10*log10((P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P));
c = SinrThreshold - sinr_dB;

ceq = []; % No equality constraints
end

% Nested function to calculate rates
function product_rate = computeRates(P, H, noise_power, N, Nsc, Nss)
T_DFT = 12.8e-6;            % OFDM symbol duration
T_GI = 0.8e-6;
rates = zeros(N, 1); % Initialize rates

% Compute rates for each link
sinr_dB = 10*log10((P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P));

for i = 1:N
    [MCS, N_bps, Rc] = MCS_cal_PER_001(sinr_dB(i));
    if isnan(MCS)
        rates(i) = 0;
    else
        rates(i) = Nsc*N_bps*Rc*Nss/(T_DFT + T_GI);
    end
end


% Product of rates
product_rate = prod(rates); % Return the product of rates
% product_rate = rates; % Return the product of rates
end
