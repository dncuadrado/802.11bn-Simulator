clear all
% clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% DCF and CSR throughput calculation %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input parameters

%%% Scenario-related
AP_number = 4;          % Number of APs
STA_number = 8;         % Number of STAs
% grid_value = 40;        % Length of the scenario: grid_value x grid_value 
% grid_value = 50;
grid_value = 40;
scenario_type = 'grid';           % scenario_type: 'grid' ---> APs are placed in the centre of each subarea and STAs around them
                                  %                'random' ---> both APs and STAs randomly deployed all over the entire area 

walls = [0 grid_value grid_value/2 grid_value/2;            % Scenario design: each row contains the coordinates 
        grid_value/2 grid_value/2 0 grid_value];            % of each wall segment: [x1 x2 y1 y2]

% walls = [0 0 0 0];            % No walls

%%% System-related
TXOP_duration = 5.484E-03;
Pn_dBm = -95;               % Noise in dbm
Cca = -82;                  % Clear channel assessment in dBm (default Cca = -82 dBm)
BW = 80;                    % Bandwidth e.g., 20, 40, 80, 160 [in MHz]  
Nss = 2;                    % Number of spatial streams
L = 12E3;                   % Number of bits per single frame


%%% Compute the number of subcarriers, Nsc, as well as the total power used depending on the bandwidth and the number of spatial streams
[tx_power_ss, Nsc] = TXpowerCalc(BW, Nss);      % tx power per spatial streams and number of subcarriers 

%%% Computing the needed overheads based on the simulation system, i.e., for DCF or CSR
[~, ~, DCFoverheads, CSRoverheads] = OverheadsCalc();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iterations = 1E4;
rng(1);            % For reproducibility

per_STA_DCF_throughput_bianchi = zeros(iterations,STA_number);
DL_throughput_CSR_bianchi = zeros(iterations,STA_number);

% updateWaitbar = waitbarParfor(iterations, "Calculation in progress...");
for i = 1:iterations
    % disp(i)
    %%% Deployment-dependent %%%%%%%%%%%
    %%% Devices deployment (scenarios are randomly per default if "rng" above is commented )
    [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value);


    % %%% Validation scenario 1 ----- 20 meters 
    % STA_matrix = [11.0680657344492	9.97455244907084
    %     5.52668873476985	14.3799130416077
    %     11.5959666302172	31.4450888096107
    %     11.6038117039619	29.0249203556387
    %     28.8890013235228	10.7866157012118
    %     30.7962909265201	12.8030058826915
    %     30.0217217427852	31.4189811308726
    %     32.1057553887391	30.8757003092022];

    STA_matrix= [14.2644   13.7394
        11.0591   10.3437
        5.3413   35.4651
        10.2185   39.2305
        30.1845   11.0308
        22.2905   14.1042
        33.9521   35.5857
        25.7944   34.5644]; % new deployment #36



    %%% Create a database with the RSSI values between all the APs and STAs and the association between APs and STAs
    [RSSI_dB_vector_to_export, association, ~] = RSSI_database(tx_power_ss, Cca, AP_matrix, STA_matrix, scenario_type, walls);

    % %%% Deployment PLOT
    % PlotDeployment(AP_matrix, STA_matrix, association, grid_value, walls);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% For validating simulated CSR against CSR bianchi's model uncomment this
    [CGs_STAs]  = CG_creation_per_STA_brute_force(AP_number, STA_number, DCFoverheads, CSRoverheads, ...
        Pn_dBm, Nsc, Nss, RSSI_dB_vector_to_export, association, TXOP_duration);
    
    % STA_matrix_save(:,:,i) = STA_matrix;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [per_STA_DCF_throughput_bianchi(i,:), ~] = Throughput_DCF_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
                                            Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads);


    [DL_throughput_CSR_bianchi(i,:), ~] = Throughput_CSR_bianchi(AP_number, STA_number, association, CGs_STAs, ...
                                        RSSI_dB_vector_to_export, Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads, CSRoverheads);
    % sum(per_STA_DCF_throughput_bianchi(i,:))
    % sum(DL_throughput_CSR_bianchi(i,:))
    per_STA_DCF_throughput_bianchi(i,:)
    DL_throughput_CSR_bianchi(i,:)
    % if sum(per_STA_DCF_throughput_bianchi(i,:)) - 1E-12 > sum(DL_throughput_CSR_bianchi(i,:))
    %     error('check')
    % end
    
    % updateWaitbar(); 
end
    
agg_thr_DCF_DL_vector = sum(per_STA_DCF_throughput_bianchi,2);
agg_thr_cSR_bianchi = sum(DL_throughput_CSR_bianchi,2);
diff_vector = DL_throughput_CSR_bianchi - per_STA_DCF_throughput_bianchi;
A = sum(diff_vector > 0,2);
B = find(A == STA_number);
[~, idx] = max(sum(diff_vector(B,:),2));
per_STA_DCF_throughput_bianchi(B(idx),:)
DL_throughput_CSR_bianchi(B(idx),:)
STA_matrix_save(:,:,B(idx));

figure
cdfplot(agg_thr_DCF_DL_vector);
hold on
cdfplot(agg_thr_cSR_bianchi);
hold on

title('', 'interpreter','latex', 'FontSize', 14)
xlabel('Aggregate Throughput [Mbps]', 'interpreter','latex', 'FontSize', 14)
ylabel('F(x)', 'interpreter','latex', 'FontSize', 14)
set(gca, 'TickLabelInterpreter','latex');
% legend(name)
grid on


toc




























