%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CGs_STAs, TxPowerMatrix]  = CG_creationAnalytical_TPC(AP_number, STA_number, CSRoverheads, ...
            Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration)

% This returns the groups selected and the TXPowerMatrix of each device per group. 
% The groups are created per STA and each STA appear only number_appearance times, so this function can select the
% groups for computing later the C-SR throughput analytically
% 

CG_size = AP_number; % Establishing the max number of AP per group
noise_power = 10^(Pn_dBm/10);
MaxTxPower = 10^(MaxTxPower/10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creating a 2D matrix with all possible AP-STA combinations
one_STA_per_tx = zeros(STA_number,AP_number);

for k = 1:AP_number
    one_STA_per_tx([association{k}],k) = [association{k}];
end

u = cell(1,AP_number);
for i = 1:AP_number
    u{:,i} = unique(one_STA_per_tx(:,i))';
end
map_matrix1 = combvec(u{:})';
map_matrix1(sum(map_matrix1(:,:)==0,2)== AP_number,:) = [];

idx_row = sum(map_matrix1~=0,2);

map_matrix1(idx_row>CG_size,:) = [];

%%%% Reordering the matrix, starting by the rows that have only one non-zero element
u = sum(map_matrix1~=0,2);
map_matrix1(u==1,:)=[];
map_matrix = [one_STA_per_tx;map_matrix1];

% Initializing power transmission matrices
SingleTxPowerMatrix = MaxTxPower.*(one_STA_per_tx~=0);
SingleTxPowerMatrix(SingleTxPowerMatrix == 0) = NaN;
TxPowerMatrixTemp = [SingleTxPowerMatrix;NaN(size(map_matrix1))];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data rate matrix
datarate = NaN(size(SingleTxPowerMatrix));

% One in position of combinations ok
comb_ok = zeros(size(map_matrix,1),1);

% Stores the number of tx packets
rx_packets = zeros(size(map_matrix));

% Value of each combination (the sum of all rx packets in the group)
alpha_coeff = zeros(size(map_matrix,1),1);

% Zero in those groups where some members have been discarded (to avoid check those groups)
Discardlist = ones(size(map_matrix,1),1);

for i = 1:size(map_matrix,1)

    % Discard those groups where Discardlist(i) == 0
    if Discardlist(i) == 0
        continue
    end

    % APs
    [~, APs] = find(map_matrix(i,:)~=0);

    % STAs
    STAs = map_matrix(i,APs);

    % Channel matrix that contains the specific subset of APs and STAs being analyzed
    H = channelMatrix(STAs, APs);

    if length(STAs) == 1    % Use maximum power 
        P = MaxTxPower;
    else         % Compute the subset of power that maximizes the proportional fair Shannon capacity
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% No TPC (Maximum tx power)
        P = MaxTxPower * ones(length(STAs), 1);
        P0 = MaxTxPower * ones(length(STAs), 1) / length(STAs);
        
        % % % %%%% TPC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % %%% 1 - Solving the Opt problem with SQP, 
        % SinrThreshold = SINRstimation(diag(datarate(STAs,APs))./length(STAs), Nsc, Nss);
        % P = power_allocation_localSQP(length(STAs), noise_power, H, MaxTxPower, P0, Nsc, Nss, SinrThreshold);


        %%% 2 - Solving the Opt problem with Particle Swarm Optimization (PSO), considering the exact value of datarate
        P = power_allocation_particleswarm(length(STAs), noise_power, H, MaxTxPower, Nsc, Nss);
        
        %%% Storing the power vector in TxPowerMatrix
        TxPowerMatrixTemp(i, APs) = P';
    end
    
    % Computing the SINR_dB
    SINR = (P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P);
    SINR_db = 10*log10(SINR);
    
    % Initializing MCS-related parameters
    MCS = NaN(length(STAs),1);
    N_bps = NaN(length(STAs),1);
    Rc = NaN(length(STAs),1);

    for k = 1:length(STAs)
        % Computing MCS-related parameters
        [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db(k,1));
        
        if isnan(MCS(k,1)) % Not valid MCS found. Set rx_packets(i,APs(k)) = 0;
            rx_packets(i,APs(k)) = 0;
            datarate(i,APs(k)) = 0;
        else
            rx_packets(i,APs(k)) = floor((1-1E-2)*tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-CSRoverheads));
            datarate(i,APs(k)) = Nsc*N_bps(k,1)*Rc(k,1)*Nss / (12.8e-6 + 0.8e-6);
        end
        
        % Comparing the number of packets received or the datarate in the CSR group 
        % with the optimized power, against its corresponding rx_packets 
        % when transmitting alone at maximum power. Note that the CSR part is multiplied by a length(STAs) factor  
        % if length(STAs)*rx_packets(i,APs(k)) >= rx_packets(STAs(k),APs(k))
        % if SINR_db(k,1) >= 40
        if  length(STAs)*datarate(i,APs(k)) >= datarate(STAs(k),APs(k))
            AP_ok = 1;
            continue
        else
            AP_ok = 0;
            Discardlist(sum(ismember(map_matrix,STAs),2)== length(STAs)) = 0;
            break
        end
    end
    % Include the combination in the list of valid combinations if it works for all APs 
    if AP_ok == 1
        comb_ok(i) = 1;
        %%% This line increases the value of each combination based on the number of tx devices
        alpha_coeff(i) = length(STAs)*sum(rx_packets(i,map_matrix(i,:)~=0));
    end  
end

% Remove entries where comb_ok is 0
mask = (comb_ok ~= 0);
alpha_coeff = alpha_coeff(mask);
map_matrix = map_matrix(mask, :);
TxPowerMatrixTemp = TxPowerMatrixTemp(mask, :);

%%% Group final selection based on the alpha_coeff %%%%%%%%%%%%%%%%%%%%%%%%%%%
number_appearance = 1;

% Optimization problem for group selection. Fair selection, number_appearance defines the same number of occurrences for
% each STA in the finally selected groups
selected_rows = selection_optimized(map_matrix, alpha_coeff, number_appearance);

% Heuristic for group selection
% selected_rows = selection_heuristic(map_matrix, alpha_coeff, number_appearance);


% % Stores the selected rows from the map_matrix
CGs_STAs = map_matrix(selected_rows,:);

% Stores the tx power values for the selected groups
TxPowerMatrix = TxPowerMatrixTemp(selected_rows,:);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Solving OPT problems for analytical throughput calculation (CG_creationAnalytical_TPC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selected_rows = selection_optimized(map_matrix, alpha_coeff, number_appearance)
    %%% Select the indexes in map_matrix that maximizes the sum of the coefficients in alpha_coeff, 
    % constrained to the same number of occurences, number_appearance, for each STA in 
    % the final selection. 
    % The method used is the solution of an optimization problem, considering fairness because all STAs are selected the
    % same number_appearance

    % Define the problem size
    [num_rows, ~] = size(map_matrix);
    STA_number = max(map_matrix(:)); % Determine the max STA number
    
    % Define the optimization variables
    % Binary variable x(i) indicating if row i is selected (1) or not (0)
    x = optimvar('x', num_rows, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

    obj = alpha_coeff' * x; % Direct sum of alpha_coeff for selected rows
    
    % Constraints
    constraints = [];
    
    % Each STA number should appear at most number_appearance times
    for sta = 1:STA_number
        % Find rows where this STA number appears
        rows_with_sta = find(any(map_matrix == sta, 2));
        % Add constraint: sum(x(rows_with_sta)) <= number_appearance
        if ~isempty(rows_with_sta)
            constraints = [constraints; sum(x(rows_with_sta)) <= number_appearance];
        end
    end
    
    % Create the optimization problem
    prob = optimproblem('Objective', obj, 'ObjectiveSense', 'maximize');
    prob.Constraints.cons = constraints;
    
    % Solve the problem
    options = optimoptions('intlinprog', 'Display', 'off');
    [solution, fval, ~] = solve(prob, 'Options', options);
    
    % Output results
    selected_rows = find(solution.x > 0.5); % Rows selected in the optimal solution
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selected_rows = selection_heuristic(map_matrix, alpha_coeff, number_appearance)
    %%% Select the indexes in map_matrix that maximizes the sum of the coefficients in alpha_coeff,
    % constrained to the same number of occurences, number_appearance, for each STA in
    % the final selection. The method used is an heuristic
    
    
    STA_number = max(map_matrix(:)); % Determine the max STA number
    
    % Sort the coefficient matrix by highest values and get top positions
    [~, pos] = maxk(alpha_coeff, size(map_matrix, 1));
    
    % Vector d to return the first occurrence row for each STA
    d = arrayfun(@(r) find(sum(map_matrix(pos, :) == r, 2), 1), 1:STA_number)';
    
    % Sort to get the worst values for each STA
    [~, p] = mink(d, STA_number);
    
    % Initialize counters and other variables
    
    stop_counter = zeros(STA_number, 1);
    controller = 1;
    
    % Main loop to determine valid combinations
    for j = 1:STA_number
        counter = d(p(j));
        while stop_counter(p(j)) < number_appearance && counter <= size(map_matrix, 1)
    
            % Filter out zero indices from map_matrix before accessing stop_counter
            valid_indices = map_matrix(pos(counter), :) > 0;
    
            % Check if row can be selected
            set_controller = all(~(valid_indices & stop_counter(map_matrix(pos(counter), valid_indices)) >= number_appearance));
    
            % Update counters if row is selected
            if set_controller
                indices_to_update = map_matrix(pos(counter), valid_indices);
                stop_counter(indices_to_update) = stop_counter(indices_to_update) + 1;
                selected_rows(controller, 1) = pos(counter);
                controller = controller + 1;
            end
    
            % Move to the next row
            counter = counter + 1;
        end
    end
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%