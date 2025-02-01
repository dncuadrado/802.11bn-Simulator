%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% IEEE 802.11bn Simulator  %%%%%%%%%%%%%%%%%%


% This simulator is intended for evaluating the performance in the downlink of a Multi-AP Coordination Network (MAPC)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input parameters

traffic_type = 'Bursty';            % 'Poisson', 'Bursty', 'CBR'
traffic_load = 'high';          % for BE, i.e., Poisson, Bursty: 'low', 'medium' , 'high'
                                 % for CBR:  'x-y', where x-> bitrate, and y-> fps
EDCAaccessCategory = 'BE';

%%% Scenario-related
AP_number = 4;           % Number of APs
STA_number = 8;         % Number of STAs
grid_value = 40;         % Length of the scenario: grid_value x grid_value
scenario_type = 'grid';           % scenario_type: 'grid' ---> APs are placed in the centre of each subarea and STAs around them

walls = [0 grid_value grid_value/2 grid_value/2;            % Scenario design: each row contains the coordinates
    grid_value/2 grid_value/2 0 grid_value];                % of each wall segment: [x1 x2 y1 y2]


%%% System-related
TXOP_duration = 5E-3;       % Duration of a TXOP, 5.484E-03;
Pn_dBm = -95;               % Noise in dbm
Cca = -82;                  % Clear channel assessment in dBm (default Cca = -82 dBm)
BW = 80;                    % Bandwidth e.g., 20, 40, 80, 160 [in MHz]
Nss = 2;                    % Number of spatial streams
L = 12E3;                   % Number of bits per single frame



%%% Compute the number of subcarriers, Nsc, as well as the total power used depending on the bandwidth and the number of spatial streams
[MaxTxPower, Nsc] = TXpowerCalc(BW, Nss);      % tx power per spatial streams and number of subcarriers

%%% Computing the needed overheads based on the simulation system, i.e., for EDCA or CSR
[preTX_overheadsEDCA, preTX_overheadsCSR, EDCAoverheads, CSRoverheads] = OverheadsCalc(EDCAaccessCategory);

rng(1);            % For reproducibility

iterations = 100;  % Each iteration represents a new deployment (new channel realization)


for i = 1:iterations
    %%% Deployment-dependent %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %% Devices deployment (scenarios are randomly per default if "rng" above is commented )

    [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value);

    %%% Association independently of the position of STAs with respect to their corresponding APs
    association = AP_STA_Association(AP_number, STA_number, scenario_type);

    %%% Create a database with the RSSI values between all the APs and STAs and the association between APs and STAs
    [channelMatrix, RSSI_dB_vector_to_export] = GetChannelMatrix(MaxTxPower, Cca, AP_matrix, STA_matrix, scenario_type, walls);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [per_STA_EDCA_throughput_bianchi, ~] = Throughput_EDCA_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
        Pn_dBm, Nsc, Nss, TXOP_duration, EDCAoverheads, EDCAaccessCategory);
    
    [CGs_STAs, TxPowerMatrix] =  CGcreation(AP_number, STA_number, CSRoverheads,...
        Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Traffic-related %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % % % % %%% Traffic generation
    STAs_arrivals_matrix = TrafficGenerator(STA_number, ...
            traffic_type, traffic_load, L, per_STA_EDCA_throughput_bianchi);

    %%% Timestamp at which the simulation stops
    timestamp_to_stop = 5;

    %%% Check that the timestamp_to_stop is higher than the arrival time of the last packet
    if timestamp_to_stop > max([STAs_arrivals_matrix{:}], [], 'all')
        error('The source of traffic generation finishes before the end of the simulation. Consider to increase the value of event_number or reduce timestamp_to_stop value');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% EDCA
    rng(1);
    simEDCA = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, timestamp_to_stop, ...
                TXOP_duration, Pn_dBm, Nss, Nsc, preTX_overheadsEDCA, preTX_overheadsCSR, EDCAoverheads, CSRoverheads);
    simEDCA.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    simEDCA.simulation_system = 'EDCA';
    simEDCA.accessCategory = EDCAaccessCategory;
    simEDCA.Init();                                    % Initializing STAs
    simEDCA.Start();                                      % Start the simulation


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CSR MNP
    rng(1);
    simMNP = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, timestamp_to_stop, ...
                TXOP_duration, Pn_dBm, Nss, Nsc, preTX_overheadsEDCA, preTX_overheadsCSR, EDCAoverheads, CSRoverheads);
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
    simOP = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, timestamp_to_stop, ...
                TXOP_duration, Pn_dBm, Nss, Nsc, preTX_overheadsEDCA, preTX_overheadsCSR, EDCAoverheads, CSRoverheads);
    simOP.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    simOP.simulation_system = 'CSR';
    simOP.scheduler = 'OP';
    simOP.CGs_STAs = CGs_STAs;
    simOP.TxPowerMatrix = TxPowerMatrix;
    simOP.accessCategory = EDCAaccessCategory;
    simOP.Init();                                    % Initializing STAs
    simOP.Start();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CSR TAT
    rng(1);
    simTAT = MAPCsim(AP_number, STA_number, association, MaxTxPower, channelMatrix, timestamp_to_stop, ...
                TXOP_duration, Pn_dBm, Nss, Nsc, preTX_overheadsEDCA, preTX_overheadsCSR, EDCAoverheads, CSRoverheads);
    simTAT.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
    simTAT.simulation_system = 'CSR';
    simTAT.scheduler = 'TAT';
    simTAT.CGs_STAs = CGs_STAs;
    simTAT.TxPowerMatrix = TxPowerMatrix;
    simTAT.accessCategory = EDCAaccessCategory;
    simTAT.alpha_ = 1/2;
    simTAT.beta_ = 1/2;
    simTAT.Init();                                    % Initializing STAs
    simTAT.Start();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plots
    % Instance to handle the plot
    myplot = MyPlots(simEDCA, simMNP, simOP, simTAT);

    % Comment | uncomment the following to get the desired plots
    
    myplot.PlotPercentileVerbose(i, 50, 99);
    myplot.PlotPrctileDelayPerSTA(99);
    myplot.PlotCDFdelayTotal();
    myplot.PlotCDFdelayPerSTA();
    myplot.PlotTXOPwinNumber();
    myplot.PlotAPcollisionProb();
    myplot.PlotSTAselectionCounter();
end
