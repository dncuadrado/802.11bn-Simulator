clear all
% clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% DCF and CSR throughput calculation %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input parameters
EDCAaccessCategory = 'VI';

%%% Scenario-related
AP_number = 4;          % Number of APs
STA_number = 16;         % Number of STAs
grid_value = 40;        % Length of the scenario: grid_value x grid_value 

scenario_type = 'grid';           % scenario_type: 'grid' ---> APs are placed in the centre of each subarea and STAs around them
                                  %                'random' ---> both APs and STAs randomly deployed all over the entire area 

sim = '20metros-16STAs';

walls = [0 grid_value grid_value/2 grid_value/2;            % Scenario design: each row contains the coordinates 
        grid_value/2 grid_value/2 0 grid_value];            % of each wall segment: [x1 x2 y1 y2]

%%% System-related
TXOP_duration = 5E-3;  % Duration of a TXOP, 5.484E-03;
Pn_dBm = -95;               % Noise in dbm
Cca = -82;                  % Clear channel assessment in dBm (default Cca = -82 dBm)
BW = 80;                    % Bandwidth e.g., 20, 40, 80, 160 [in MHz]  
Nss = 2;                    % Number of spatial streams
L = 12E3;                   % Number of bits per single frame


%%% Compute the number of subcarriers, Nsc, as well as the total power used depending on the bandwidth and the number of spatial streams
[MaxTxPower, Nsc] = TXpowerCalc(BW, Nss);      % tx power per spatial streams and number of subcarriers 

%%% Computing the needed overheads based on the simulation system, i.e., for DCF or CSR
[~, ~, DCFoverheads, CSRoverheads] = OverheadsCalc();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iterations = 1E2;
rng(1);            % For reproducibility

per_STA_DCF_throughput_bianchi = zeros(iterations,STA_number);
DL_throughput_CSR_bianchi = zeros(iterations,STA_number);

AP_matrix = [grid_value/4,grid_value/4;
    grid_value/4,3*grid_value/4;
    3*grid_value/4,grid_value/4;
    3*grid_value/4,3*grid_value/4];

%%% To validate my specific simulations
mySimValidation(AP_number, STA_number, grid_value, sim);

% % %%% Loading the deployment dataset
load(horzcat('deployment datasets/',sim, '/STA_matrix_save.mat'));
load(horzcat('deployment datasets/',sim, '/channelMatrix_save.mat'));
load(horzcat('deployment datasets/',sim, '/RSSI_dB_vector_to_export_save.mat'));

% SetParalellpool();

updateWaitbar = waitbarParfor(iterations, "Calculation in progress...");
parfor i = 1:iterations
    % disp(i)
    %%% Deployment-dependent %%%%%%%%%%%
    %%% Devices deployment (scenarios are randomly per default if "rng" above is commented )
    % [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value);
    STA_matrix = STA_matrix_save(:,:,i);

    % Association independently of the position of STAs with respect to their corresponding APs
    association = AP_STA_Association(AP_number, STA_number, scenario_type);

    % %%% Deployment PLOT
    % PlotDeployment(AP_matrix, STA_matrix, association, grid_value, walls);

    %%% Create a database with the RSSI values between all the APs and STAs and the association between APs and STAs
    % [channelMatrix, RSSI_dB_vector_to_export] = GetChannelMatrix(MaxTxPower, Cca, AP_matrix, STA_matrix, scenario_type, walls);
    channelMatrix = channelMatrix_save(:,:,i);
    RSSI_dB_vector_to_export = RSSI_dB_vector_to_export_save(:,:,i);

    % [CGs_STAs, TxPowerMatrix]  = CG_creationAnalytical_TPC(AP_number, STA_number, CSRoverheads, ...
    %         Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration);

    [CGs_STAs, TxPowerMatrix] = CG_creationTPC(AP_number, STA_number, CSRoverheads, ...
            Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [per_STA_DCF_throughput_bianchi(i,:), ~] = Throughput_DCF_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
                                            Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads, EDCAaccessCategory);


    [DL_throughput_CSR_bianchi(i,:), ~] = Throughput_CSR_bianchi(AP_number, STA_number, CGs_STAs, TxPowerMatrix, ...
                                        channelMatrix, Pn_dBm, Nsc, Nss, TXOP_duration, CSRoverheads, EDCAaccessCategory);
    
    % disp(per_STA_DCF_throughput_bianchi(i,:));
    % disp(DL_throughput_CSR_bianchi(i,:));
    updateWaitbar(); 
end
    
agg_thr_DCF_DL_vector = sum(per_STA_DCF_throughput_bianchi,2);
agg_thr_cSR_bianchi = sum(DL_throughput_CSR_bianchi,2);

allSTA_DCF = reshape(per_STA_DCF_throughput_bianchi,[],1);
allSTA_CSR = reshape(DL_throughput_CSR_bianchi,[],1);

%%
figure
cdf1 = cdfplot(allSTA_DCF);
hold on
cdf2 = cdfplot(allSTA_CSR);

set(cdf1(:,1), 'LineWidth', 2);
set(cdf2(:,1), 'LineWidth', 2);

colororder(["#107860";"#912B09"]);
title('', 'interpreter','latex', 'FontSize', 14)
xlabel('', 'interpreter','latex', 'FontSize', 14)
% xlim([0 110])
ylabel('F(x)', 'interpreter','latex', 'FontSize', 14)
set(gca, 'TickLabelInterpreter','latex');
% legend(name)
grid on

figure
cdf3 = cdfplot(agg_thr_DCF_DL_vector);
hold on
cdf4 = cdfplot(agg_thr_cSR_bianchi);
set(cdf3(:,1), 'LineWidth', 2);
set(cdf4(:,1), 'LineWidth', 2);

colororder(["#107860";"#912B09"]);
title('', 'interpreter','latex', 'FontSize', 14)
xlabel('', 'interpreter','latex', 'FontSize', 14)
% xlim([0 110])
ylabel('F(x)', 'interpreter','latex', 'FontSize', 14)
set(gca, 'TickLabelInterpreter','latex');
% legend(name)
grid on

toc