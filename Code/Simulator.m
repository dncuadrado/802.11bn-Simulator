clear all
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% IEEE 802.11bn Simulator  %%%%%%%%%%%%%%%%%%

% %%% Define the system simulation system (DCF, CSR)
simulation_system = 'DCF';     % For validating simulated against Bianchi's model for either DCF, C-SR:

% 1---> select simulation_system = 'DCF' or simulation_system = 'CSR'
% 2---> set validation = 'yes'
% 3---> high traffic load to guarantee saturation, e.g., traffic_load = 5000E6;
% 4---> NOTE: traffic_load high enough to achieve saturation (3000) and control the sim
%       duration by setting event number high enough (32000000) or manually with timestamp_to_stop (100)

validationFlag = 'no';                % for validating against Bianchi's model set 'yes'



traffic_type = 'Bursty';        % 'Poisson', 'Bursty', 'VR'
traffic_load = 'high';        % for BE, i.e., Poisson, Bursty: 'low', 'medium' , 'high'
                             % for VR:   '30-60', '30-90', '30-120'
EDCAaccessCategory = 'BE';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input parameters

%%% Scenario-related
AP_number = 4;          % Number of APs
STA_number = 8;         % Number of STAs
grid_value = 40;        % Length of the scenario: grid_value x grid_value
scenario_type = 'grid';           % scenario_type: 'grid' ---> APs are placed in the centre of each subarea and STAs around them
%                'random' ---> both APs and STAs randomly deployed all over the entire area
sim = '20metros-8STAs';

walls = [0 grid_value grid_value/2 grid_value/2;            % Scenario design: each row contains the coordinates
    grid_value/2 grid_value/2 0 grid_value];            % of each wall segment: [x1 x2 y1 y2]

% walls = [0 0 0 0];            % No walls


%%% System-related
TXOP_duration = 5E-3;       % Duration of a TXOP, 5.484E-03;
Pn_dBm = -95;               % Noise in dbm
Cca = -82;                  % Clear channel assessment in dBm (default Cca = -82 dBm)
BW = 80;                    % Bandwidth e.g., 20, 40, 80, 160 [in MHz]
Nss = 2;                    % Number of spatial streams
L = 12E3;                   % Number of bits per single frame



%%% Compute the number of subcarriers, Nsc, as well as the total power used depending on the bandwidth and the number of spatial streams
[MaxTxPower, Nsc] = TXpowerCalc(BW, Nss);      % tx power per spatial streams and number of subcarriers


rng(1);            % For reproducibility

iterations = 100;

AP_matrix = [grid_value/4,grid_value/4;
    grid_value/4,3*grid_value/4;
    3*grid_value/4,grid_value/4;
    3*grid_value/4,3*grid_value/4];

%%% To validate my specific simulations
mySimValidation(AP_number, STA_number, grid_value, sim);

%%% Loading the deployment dataset
load(horzcat('deployment datasets/',sim, '/STA_matrix_save.mat'));
load(horzcat('deployment datasets/',sim, '/channelMatrix_save.mat'));
load(horzcat('deployment datasets/',sim, '/RSSI_dB_vector_to_export_save.mat'));

% SetParalellpool();

if strcmp(traffic_type, 'VR')
    EDCAaccessCategory = 'VI';
end

for i = 1:100
    %%% selected deaployment : 20
    %%% Deployment-dependent %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %% Devices deployment (scenarios are randomly per default if "rng" above is commented )

    % [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value);
    STA_matrix = STA_matrix_save(:,:,i);

    %%% Association independently of the position of STAs with respect to their corresponding APs
    association = AP_STA_Association(AP_number, STA_number, scenario_type);

    % % %%% Deployment PLOT
    % PlotDeployment(AP_matrix, STA_matrix, association, grid_value, walls);

    %%% Create a database with the RSSI values between all the APs and STAs and the association between APs and STAs
    % [channelMatrix, RSSI_dB_vector_to_export] = GetChannelMatrix(MaxTxPower, Cca, AP_matrix, STA_matrix, scenario_type, walls);
    channelMatrix = channelMatrix_save(:,:,i);
    RSSI_dB_vector_to_export = RSSI_dB_vector_to_export_save(:,:,i);
    
    %%% Computing the needed overheads based on the simulation system, i.e., for DCF or CSR
    [preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads] = OverheadsCalc(EDCAaccessCategory);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [per_STA_DCF_throughput_bianchi, ~] = Throughput_DCF_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
        Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads, EDCAaccessCategory);

    [CGs_STAs, TxPowerMatrix] =  CGcreation(validationFlag, AP_number, STA_number, CSRoverheads,...
        Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Traffic-related %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TrafficfileName = horzcat('STAs_arrivals_matrix',int2str(i), '.mat');
    TrafficfilePath = horzcat('traffic datasets/',sim, '/', traffic_type, '/', traffic_load, '/');
    
    % % % % %%% Traffic generation
    % STAs_arrivals_matrix = TrafficGenerator(STA_number,validationFlag, ...
    %         traffic_type, traffic_load, L, per_STA_DCF_throughput_bianchi, TrafficfileName, TrafficfilePath);

    STAs_arrivals_matrix = load(horzcat(TrafficfilePath, TrafficfileName)).STAs_arrivals_matrix;  % load the traffic dataset

    %%% Timestamp at which the simulation stops
    timestamp_to_stop = 5;

    %%% Check that the timestamp_to_stop is higher than the arrival time of the last packet
    if timestamp_to_stop > max([STAs_arrivals_matrix{:}], [], 'all')
        error('The source of traffic generation finishes before the end of the simulation. Consider to increase the value of event_number or reduce timestamp_to_stop value');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% DCF
    rng(1);
    simDCF = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
        simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);         % new "Traffic" object
    simDCF.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    simDCF.simulation_system = 'DCF';
    simDCF.accessCategory = EDCAaccessCategory;
    simDCF.Init();                                    % Initializing STAs
    simDCF.Start();                                      % Start the simulation


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CSR MNP
    rng(1);
    simMNP = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
        simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    simMNP.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    simMNP.simulation_system = 'CSR';
    simMNP.scheduler = 'MNP';
    simMNP.CGs_STAs = CGs_STAs;
    simMNP.TxPowerMatrix = TxPowerMatrix;
    simMNP.accessCategory = EDCAaccessCategory;
    simMNP.Init();                                    % Initializing STAs
    simMNP.Start();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CSR OP
    rng(1);
    simOP = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
        simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    simOP.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    simOP.simulation_system = 'CSR';
    simOP.scheduler = 'OP';
    simOP.CGs_STAs = CGs_STAs;
    simOP.TxPowerMatrix = TxPowerMatrix;
    simOP.accessCategory = EDCAaccessCategory;
    simOP.Init();                                    % Initializing STAs
    simOP.Start();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT1
    % rng(1);
    % simTAT1 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT1.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT1.simulation_system = 'CSR';
    % simTAT1.scheduler = 'TAT';
    % simTAT1.CGs_STAs = CGs_STAs;
    % simTAT1.TxPowerMatrix = TxPowerMatrix;
    % simTAT1.accessCategory = EDCAaccessCategory;
    % simTAT1.alpha_ = 0;
    % simTAT1.beta_ = 1/4;
    % simTAT1.Init();                                    % Initializing STAs
    % simTAT1.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT2
    % rng(1);
    % simTAT2 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT2.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT2.simulation_system = 'CSR';
    % simTAT2.scheduler = 'TAT';
    % simTAT2.CGs_STAs = CGs_STAs;
    % simTAT2.TxPowerMatrix = TxPowerMatrix;
    % simTAT2.accessCategory = EDCAaccessCategory;
    % simTAT2.alpha_ = 0;
    % simTAT2.beta_ = 1/2;
    % simTAT2.Init();                                    % Initializing STAs
    % simTAT2.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT3
    % rng(1);
    % simTAT3 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT3.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT3.simulation_system = 'CSR';
    % simTAT3.scheduler = 'TAT';
    % simTAT3.CGs_STAs = CGs_STAs;
    % simTAT3.TxPowerMatrix = TxPowerMatrix;
    % simTAT3.accessCategory = EDCAaccessCategory;
    % simTAT3.alpha_ = 0;
    % simTAT3.beta_ = 3/4;
    % simTAT3.Init();                                    % Initializing STAs
    % simTAT3.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT4
    % rng(1);
    % simTAT4 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT4.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT4.simulation_system = 'CSR';
    % simTAT4.scheduler = 'TAT';
    % simTAT4.CGs_STAs = CGs_STAs;
    % simTAT4.TxPowerMatrix = TxPowerMatrix;
    % simTAT4.accessCategory = EDCAaccessCategory;
    % simTAT4.alpha_ = 1/4;
    % simTAT4.beta_ = 1/4;
    % simTAT4.Init();                                    % Initializing STAs
    % simTAT4.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT5
    % rng(1);
    % simTAT5 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT5.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT5.simulation_system = 'CSR';
    % simTAT5.scheduler = 'TAT';
    % simTAT5.CGs_STAs = CGs_STAs;
    % simTAT5.TxPowerMatrix = TxPowerMatrix;
    % simTAT5.accessCategory = EDCAaccessCategory;
    % simTAT5.alpha_ = 1/4;
    % simTAT5.beta_ = 1/2;
    % simTAT5.Init();                                    % Initializing STAs
    % simTAT5.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT6
    % rng(1);
    % simTAT6 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT6.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT6.simulation_system = 'CSR';
    % simTAT6.scheduler = 'TAT';
    % simTAT6.CGs_STAs = CGs_STAs;
    % simTAT6.TxPowerMatrix = TxPowerMatrix;
    % simTAT6.accessCategory = EDCAaccessCategory;
    % simTAT6.alpha_ = 1/4;
    % simTAT6.beta_ = 3/4;
    % simTAT6.Init();                                    % Initializing STAs
    % simTAT6.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT7
    % rng(1);
    % simTAT7 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT7.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT7.simulation_system = 'CSR';
    % simTAT7.scheduler = 'TAT';
    % simTAT7.CGs_STAs = CGs_STAs;
    % simTAT7.TxPowerMatrix = TxPowerMatrix;
    % simTAT7.accessCategory = EDCAaccessCategory;
    % simTAT7.alpha_ = 1/2;
    % simTAT7.beta_ = 1/4;
    % simTAT7.Init();                                    % Initializing STAs
    % simTAT7.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CSR TAT8
    rng(1);
    simTAT8 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
        simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    simTAT8.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    simTAT8.simulation_system = 'CSR';
    simTAT8.scheduler = 'TAT';
    simTAT8.CGs_STAs = CGs_STAs;
    simTAT8.TxPowerMatrix = TxPowerMatrix;
    simTAT8.accessCategory = EDCAaccessCategory;
    simTAT8.alpha_ = 1/2;
    simTAT8.beta_ = 1/2;
    simTAT8.Init();                                    % Initializing STAs
    simTAT8.Start();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT9
    % rng(1);
    % simTAT9 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT9.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT9.simulation_system = 'CSR';
    % simTAT9.scheduler = 'TAT';
    % simTAT9.CGs_STAs = CGs_STAs;
    % simTAT9.TxPowerMatrix = TxPowerMatrix;
    % simTAT9.accessCategory = EDCAaccessCategory;
    % simTAT9.alpha_ = 1/2;
    % simTAT9.beta_ = 3/4;
    % simTAT9.Init();                                    % Initializing STAs
    % simTAT9.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT10
    % rng(1);
    % simTAT10 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT10.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT10.simulation_system = 'CSR';
    % simTAT10.scheduler = 'TAT';
    % simTAT10.CGs_STAs = CGs_STAs;
    % simTAT10.TxPowerMatrix = TxPowerMatrix;
    % simTAT10.accessCategory = EDCAaccessCategory;
    % simTAT10.alpha_ = 3/4;
    % simTAT10.beta_ = 1/4;
    % simTAT10.Init();                                    % Initializing STAs
    % simTAT10.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT11
    % rng(1);
    % simTAT11 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT11.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT11.simulation_system = 'CSR';
    % simTAT11.scheduler = 'TAT';
    % simTAT11.CGs_STAs = CGs_STAs;
    % simTAT11.TxPowerMatrix = TxPowerMatrix;
    % simTAT11.accessCategory = EDCAaccessCategory;
    % simTAT11.alpha_ = 3/4;
    % simTAT11.beta_ = 1/2;
    % simTAT11.Init();                                    % Initializing STAs
    % simTAT11.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR TAT12
    % rng(1);
    % simTAT12 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %     simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simTAT12.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simTAT12.simulation_system = 'CSR';
    % simTAT12.scheduler = 'TAT';
    % simTAT12.CGs_STAs = CGs_STAs;
    % simTAT12.TxPowerMatrix = TxPowerMatrix;
    % simTAT12.accessCategory = EDCAaccessCategory;
    % simTAT12.alpha_ = 3/4;
    % simTAT12.beta_ = 3/4;
    % simTAT12.Init();                                    % Initializing STAs
    % simTAT12.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid10
    % rng(1);
    % simHybrid10 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid10.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid10.simulation_system = 'CSR';
    % simHybrid10.scheduler = 'Hybrid';
    % simHybrid10.CGs_STAs = CGs_STAs;
    % simHybrid10.TxPowerMatrix = TxPowerMatrix;
    % simHybrid10.accessCategory = EDCAaccessCategory;
    % simHybrid10.hybridThreshold = 10;
    % simHybrid10.Init();                                    % Initializing STAs
    % simHybrid10.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid20
    % rng(1);
    % simHybrid20 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid20.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid20.simulation_system = 'CSR';
    % simHybrid20.scheduler = 'Hybrid';
    % simHybrid20.CGs_STAs = CGs_STAs;
    % simHybrid20.TxPowerMatrix = TxPowerMatrix;
    % simHybrid20.accessCategory = EDCAaccessCategory;
    % simHybrid20.hybridThreshold = 20;
    % simHybrid20.Init();                                    % Initializing STAs
    % simHybrid20.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid30
    % rng(1);
    % simHybrid30 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid30.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid30.simulation_system = 'CSR';
    % simHybrid30.scheduler = 'Hybrid';
    % simHybrid30.CGs_STAs = CGs_STAs;
    % simHybrid30.TxPowerMatrix = TxPowerMatrix;
    % simHybrid30.accessCategory = EDCAaccessCategory;
    % simHybrid30.hybridThreshold = 30;
    % simHybrid30.Init();                                    % Initializing STAs
    % simHybrid30.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid40
    % rng(1);
    % simHybrid40 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid40.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid40.simulation_system = 'CSR';
    % simHybrid40.scheduler = 'Hybrid';
    % simHybrid40.CGs_STAs = CGs_STAs;
    % simHybrid40.TxPowerMatrix = TxPowerMatrix;
    % simHybrid40.accessCategory = EDCAaccessCategory;
    % simHybrid40.hybridThreshold = 40;
    % simHybrid40.Init();                                    % Initializing STAs
    % simHybrid40.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid50
    % rng(1);
    % simHybrid50 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid50.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid50.simulation_system = 'CSR';
    % simHybrid50.scheduler = 'Hybrid';
    % simHybrid50.CGs_STAs = CGs_STAs;
    % simHybrid50.TxPowerMatrix = TxPowerMatrix;
    % simHybrid50.accessCategory = EDCAaccessCategory;
    % simHybrid50.hybridThreshold = 50;
    % simHybrid50.Init();                                    % Initializing STAs
    % simHybrid50.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid60
    % rng(1);
    % simHybrid60 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid60.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid60.simulation_system = 'CSR';
    % simHybrid60.scheduler = 'Hybrid';
    % simHybrid60.CGs_STAs = CGs_STAs;
    % simHybrid60.TxPowerMatrix = TxPowerMatrix;
    % simHybrid60.accessCategory = EDCAaccessCategory;
    % simHybrid60.hybridThreshold = 60;
    % simHybrid60.Init();                                    % Initializing STAs
    % simHybrid60.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid70
    % rng(1);
    % simHybrid70 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid70.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid70.simulation_system = 'CSR';
    % simHybrid70.scheduler = 'Hybrid';
    % simHybrid70.CGs_STAs = CGs_STAs;
    % simHybrid70.TxPowerMatrix = TxPowerMatrix;
    % simHybrid70.accessCategory = EDCAaccessCategory;
    % simHybrid70.hybridThreshold = 70;
    % simHybrid70.Init();                                    % Initializing STAs
    % simHybrid70.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid80
    % rng(1);
    % simHybrid80 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid80.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid80.simulation_system = 'CSR';
    % simHybrid80.scheduler = 'Hybrid';
    % simHybrid80.CGs_STAs = CGs_STAs;
    % simHybrid80.TxPowerMatrix = TxPowerMatrix;
    % simHybrid80.accessCategory = EDCAaccessCategory;
    % simHybrid80.hybridThreshold = 80;
    % simHybrid80.Init();                                    % Initializing STAs
    % simHybrid80.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%% CSR Hybrid90
    % rng(1);
    % simHybrid90 = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
    %         simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
    % simHybrid90.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    % simHybrid90.simulation_system = 'CSR';
    % simHybrid90.scheduler = 'Hybrid';
    % simHybrid90.CGs_STAs = CGs_STAs;
    % simHybrid90.TxPowerMatrix = TxPowerMatrix;
    % simHybrid90.accessCategory = EDCAaccessCategory;
    % simHybrid90.hybridThreshold = 90;
    % simHybrid90.Init();                                    % Initializing STAs
    % simHybrid90.Start();
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





    %%%%%%%%  Validation
    %%% Make sure that traffic_load is high enough to saturate the network. The higher the event_number parameter the higher
    %%% the accuracy of the simulation result when compared with analytical (bianchi's).
    %%% For validating simulated-CSR against CSR Bianchi's model:
    % 1---> select 'CSR' here
    % 2---> select priority = 3, which does a round robin scheduling for CSR simulated
    % 3---> traffic_load = 1000E6;
    % 4---> select the brute force mode (CG_creation_per_STA_brute_force) as CGs_STAs selection algorithm


    % sim1.PlotValidation(simulation_system, validation, MaxTxPower, channelMatrix, RSSI_dB_vector_to_export, CGs_STAs, Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads, CSRoverheads);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plots
    % SavingDuetoParfor(i,traffic_type, traffic_load, simDCF, simMNP, simOP, simTAT8);

    myplot = MyPlots(simDCF, simMNP, simOP, simTAT8);
    myplot.PlotPercentileVerbose(i, 50, 99);
    %
    % myplot.PlotPrctileDelayPerSTA(99);
    % myplot.PlotCDFdelayTotal();
    % myplot.PlotCDFdelayPerSTA();
    % myplot.PlotTXOPwinNumber();
    % myplot.PlotAPcollisionProb();
    % myplot.PlotSTAselectionCounter();


    % DCFdelay = simDCF.delayvector;
    % MNPdelay = simMNP.delayvector;
    % OPdelay = simOP.delayvector;
    %
    % TATdelay1 = simTAT1.delayvector;
    % TATdelay2 = simTAT2.delayvector;
    % TATdelay3 = simTAT3.delayvector;
    % TATdelay4 = simTAT4.delayvector;
    % TATdelay5 = simTAT5.delayvector;
    % TATdelay6 = simTAT6.delayvector;
    % TATdelay7 = simTAT7.delayvector;
    % TATdelay8 = simTAT8.delayvector;
    % TATdelay9 = simTAT9.delayvector;
    % TATdelay10 = simTAT10.delayvector;
    % TATdelay11 = simTAT11.delayvector;
    % TATdelay12 = simTAT12.delayvector;


    % Hybriddelay10 = simHybrid10.delayvector;
    % Hybriddelay20 = simHybrid20.delayvector;
    % Hybriddelay30 = simHybrid30.delayvector;
    % Hybriddelay40 = simHybrid40.delayvector;
    % Hybriddelay50 = simHybrid50.delayvector;
    % Hybriddelay60 = simHybrid60.delayvector;
    % Hybriddelay70 = simHybrid70.delayvector;
    % Hybriddelay80 = simHybrid80.delayvector;
    % Hybriddelay90 = simHybrid90.delayvector;

    % % % % % %%% Saving variables
    % Resultsfilepath = horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, '/Deployment', int2str(i));
    % if ~exist(Resultsfilepath, 'dir')
    %     mkdir(Resultsfilepath);
    % end
    % %
    % parsave(Resultsfilepath, DCFdelay, MNPdelay, OPdelay, ...
    %     TATdelay1, TATdelay2, TATdelay3, TATdelay4, TATdelay5, TATdelay6, TATdelay7, TATdelay8, TATdelay9, TATdelay10, TATdelay11, TATdelay12, ...
    %     Hybriddelay10, Hybriddelay20, Hybriddelay30, Hybriddelay40, Hybriddelay50, Hybriddelay60, Hybriddelay70, Hybriddelay80, Hybriddelay90);

    % updateWaitbar();
    % toc
end




toc