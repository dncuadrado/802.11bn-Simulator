%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CGs_STAs, TxPowerMatrix] = CG_creationTPC(AP_number, STA_number, CSRoverheads, ...
            Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration)

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data rate matrix
datarate = NaN(size(SingleTxPowerMatrix));

% One in position of combinations ok
comb_ok = zeros(size(map_matrix,1),1);

% Stores the number of tx packets
rx_packets = zeros(size(map_matrix));


% Zero in those groups where some members have been discarded (to avoid check those groups)
Discardlist = ones(size(map_matrix,1),1);

%%%% For verifying the DL
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
    end
end

% Subset of corresponding TX power
TxPowerMatrix = TxPowerMatrixTemp(comb_ok==1,:);

% Reducing the number of combinations, considering only the successful ones
CGs_STAs = map_matrix(comb_ok==1,:);  % Final subsets of STAs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end