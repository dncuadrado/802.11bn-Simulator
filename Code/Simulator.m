clear all
% clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% IEEE 802.11bn Simulator  %%%%%%%%%%%%%%%%%%

% %%% Define the system simulation system (DCF, ST, CSR)
simulation_system = 'DCF';     % For validating simulated against Bianchi's model for either DCF, C-SR: 
                               % Validation only works for DCF and C-SR. ST is a special case of C-SR.
                           % 1---> select simulation_system = 'DCF' or simulation_system = 'CSR' 
                           % 2---> set validation = 'yes'
                           % 3---> high traffic load to guarantee saturation, e.g., traffic_load = 5000E6; 
                           % 4---> NOTE: traffic_load high enough to achieve saturation (3000) and control the sim
                           %       duration by setting event number high enough (32000000) or manually with timestamp_to_stop (100)
         

traffic_type = 'Bursty';        % 'Poisson', 'Bursty'         
traffic_load = 'low';        % 'low', 'medium' , 'high'    
validationFlag = 'no';                % for validating against Bianchi's model set 'yes'                                    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input parameters

%%% Scenario-related
AP_number = 4;          % Number of APs
STA_number = 16;         % Number of STAs
grid_value = 60;        % Length of the scenario: grid_value x grid_value
scenario_type = 'grid';           % scenario_type: 'grid' ---> APs are placed in the centre of each subarea and STAs around them
                                  %                'random' ---> both APs and STAs randomly deployed all over the entire area 

walls = [0 grid_value grid_value/2 grid_value/2;            % Scenario design: each row contains the coordinates 
        grid_value/2 grid_value/2 0 grid_value];            % of each wall segment: [x1 x2 y1 y2]

% walls = [0 0 0 0];            % No walls


%%% System-related
TXOP_duration = 5.484E-03;  % Duration of a TXOP
Pn_dBm = -95;               % Noise in dbm
Cca = -82;                  % Clear channel assessment in dBm (default Cca = -82 dBm)
BW = 80;                    % Bandwidth e.g., 20, 40, 80, 160 [in MHz]  
Nss = 2;                    % Number of spatial streams
L = 12E3;                   % Number of bits per single frame


%%% ST and CSR related
priority = 1;               % priority for ST or CSR scheduling ------> 1: number of packets
                                                              % ------> 2: oldest packets  
                                                              % ------> 3: random

                                                                          %%% Compute the number of subcarriers, Nsc, as well as the total power used depending on the bandwidth and the number of spatial streams
[tx_power_ss, Nsc] = TXpowerCalc(BW, Nss);      % tx power per spatial streams and number of subcarriers 

%%% Computing the needed overheads based on the simulation system, i.e., for DCF or CSR
[preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads] = OverheadsCalc();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


% num_comb_ok = zeros(1,1000);
% for i = 1:1000
rng(1);            % For reproducibility   50grid --->    rng() 
                                          %                 rng(129)----> good
iterations = 100;

% STA_matrix_save = zeros(STA_number,2,iterations);
% for j=1:iterations
%     %%% Devices deployment (scenarios are randomly per default if "rng" above is commented )
%     [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value);
%     STA_matrix_save(:,:,j) = STA_matrix;
% end

AP_matrix = [grid_value/4,grid_value/4;
    grid_value/4,3*grid_value/4;
    3*grid_value/4,grid_value/4;
    3*grid_value/4,3*grid_value/4];


sim = '30metros-16STAs';
load(horzcat('/home/dnunez/Papers/journal_CSR_scheduling/deployment datasets/',sim, '/STA_matrix_save.mat'));

 
DCFdelay = [];
CSRNumPkdelay = [];
CSROldPkdelay = []; 
CSRWeighteddelay = [];

traffic_load_idx = {'high'};

% %%% Creating a progress bar to track the current state of the simulation
% f = waitbar(0,'Please wait...');

parpool('local',32)

for xxx = 1:1
    traffic_load = traffic_load_idx{xxx};
    % updateWaitbar = waitbarParfor(iterations, "Calculation in progress...");
    
    parfor i = 1:iterations
        % i=36;
        %%% Deployment-dependent %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % %% Devices deployment (scenarios are randomly per default if "rng" above is commented )
        % [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value);
        STA_matrix = STA_matrix_save(:,:,i);

        %%% Create a database with the RSSI values between all the APs and STAs and the association between APs and STAs
        [RSSI_dB_vector_to_export, association, ~] = RSSI_database(tx_power_ss, Cca, AP_matrix, STA_matrix, scenario_type, walls);

        [CGs_STAs, ~] = CG_creation(AP_number, STA_number, DCFoverheads, CSRoverheads, ...
            Pn_dBm, Nsc, Nss, RSSI_dB_vector_to_export, association, TXOP_duration);
        % disp(CGs_STAs);

        [per_STA_DCF_throughput_bianchi, ~] = Throughput_DCF_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
            Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads);


        % %%% Deployment PLOT
        % PlotDeployment(AP_matrix, STA_matrix, association, grid_value, walls);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Traffic-related %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(traffic_load,'low')
            low_load = 0.3*min(per_STA_DCF_throughput_bianchi)*1E6;
            traffic_load_amount = low_load;
        elseif strcmp(traffic_load,'medium')
            medium_load = 0.6*min(per_STA_DCF_throughput_bianchi)*1E6;
            traffic_load_amount = medium_load;
        elseif strcmp(traffic_load,'high')
            high_load = 0.9*min(per_STA_DCF_throughput_bianchi)*1E6;
            traffic_load_amount = high_load;
        end

        trafficGeneration_rate = traffic_load_amount/L;             % packets/s
        event_number = 150000;                               % number of packets tx along the simulation

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Full-buffer
        % traffic_load = 2000E6;                                  % bps
        % trafficGeneration_rate = traffic_load/L;                % packets/s
        % event_number = 20000000;                               % number of packets tx along the simulation
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% Traffic generation
        % STAs_arrivals_matrix = TrafficGenerator(STA_number,validationFlag, traffic_type, event_number, trafficGeneration_rate);
        arrivalfileName = horzcat('STAs_arrivals_matrix',int2str(i));
        destinationName = horzcat('/home/dnunez/Papers/journal_CSR_scheduling/traffic datasets/', traffic_type,'/',traffic_load, ' load/' ,int2str(STA_number),'/',arrivalfileName);
        % save(destinationName,"STAs_arrivals_matrix");
        % continue
        STAs_arrivals_matrix = struct2array(load(horzcat(destinationName,'.mat')));  % load the traffic dataset

        %%% Timestamp at which the simulation stops
        % timestamp_to_stop = max(STAs_arrivals_matrix, [], 'all');
        timestamp_to_stop = 5;

        %%% Check that the timestamp_to_stop is higher than the arrival time of the last packet
        if timestamp_to_stop > max(STAs_arrivals_matrix, [], 'all')
            error('The source of traffic generation finishes before the end of the simulation. Consider to increase the value of event_number or reduce timestamp_to_stop value');
        end


        % num_comb_ok(i) = sum(comb_ok);
        % disp(sum(comb_ok))
        % end

        % return
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% DCF
        rng(1);
        simDCF = MAPCsim(AP_number, STA_number, association, RSSI_dB_vector_to_export, trafficGeneration_rate, event_number, traffic_type, timestamp_to_stop, ...
            priority, simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);         % new "Traffic" object
        simDCF.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
        simDCF.simulation_system = 'DCF';
        simDCF.InitSTA();                                    % Initializing STAs
        simDCF.Start();                                      % Start the simulation


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% CSR NumPk
        rng(1);
        simCSRNumPk = MAPCsim(AP_number, STA_number, association, RSSI_dB_vector_to_export, trafficGeneration_rate, event_number, traffic_type, timestamp_to_stop, ...
            priority, simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
        simCSRNumPk.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
        simCSRNumPk.simulation_system = 'CSR';
        simCSRNumPk.priority = 1;
        simCSRNumPk.InitSTA();                                    % Initializing STAs
        simCSRNumPk.Start();
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% CSR OldPk
        rng(1);
        simCSROldPk = MAPCsim(AP_number, STA_number, association, RSSI_dB_vector_to_export, trafficGeneration_rate, event_number, traffic_type, timestamp_to_stop, ...
            priority, simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
        simCSROldPk.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
        simCSROldPk.simulation_system = 'CSR';
        simCSROldPk.priority = 2;
        simCSROldPk.InitSTA();                                    % Initializing STAs
        simCSROldPk.Start();
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% CSR Weighted
        rng(1);
        simCSRWeighted = MAPCsim(AP_number, STA_number, association, RSSI_dB_vector_to_export, trafficGeneration_rate, event_number, traffic_type, timestamp_to_stop, ...
            priority, simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
        simCSRWeighted.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
        simCSRWeighted.simulation_system = 'CSR';
        simCSRWeighted.priority = 4;
        simCSRWeighted.InitSTA();                                    % Initializing STAs
        simCSRWeighted.Start();
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % % % % %%% CSR Hybrid
        % % % % % rng(1);
        % % % % % simCSRHybrid = MAPCsim(AP_number, STA_number, association, RSSI_dB_vector_to_export, trafficGeneration_rate, event_number, traffic_type, timestamp_to_stop, ...
        % % % % %         priority, simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads);
        % % % % % simCSRHybrid.STA_queue_timeline = STAs_arrivals_matrix;    % Loading the traffic dataset and assigning it to the STAs
        % % % % % simCSRHybrid.simulation_system = 'CSR';
        % % % % % simCSRHybrid.priority = 5;
        % % % % % simCSRHybrid.InitSTA();                                    % Initializing STAs
        % % % % % simCSRHybrid.Start();
        % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % % % %



        %%%%%%%%  Validation
        %%% Make sure that traffic_load is high enough to saturate the network. The higher the event_number parameter the higher
        %%% the accuracy of the simulation result when compared with analytical (bianchi's).
        %%% For validating simulated-CSR against CSR Bianchi's model:
        % 1---> select 'CSR' here
        % 2---> select priority = 3, which does a round robin scheduling for CSR simulated
        % 3---> traffic_load = 1000E6;
        % 4---> select the brute force mode (CG_creation_per_STA_brute_force) as CGs_STAs selection algorithm


        % sim1.PlotValidation(simulation_system, validation, RSSI_dB_vector_to_export, CGs_STAs, Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads, CSRoverheads);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Plots

        % simDCF.PlotCDFdelayTotal();
        % simCSRNumPk.PlotCDFdelayTotal();
        % simCSROldPk.PlotCDFdelayTotal();
        % simCSRWeighted.PlotCDFdelayTotal();
        %
        % sim1.PlotCDFdelayPerSTA();
        %
        % sim1.PlotisemptyWorstCaseDelayPerSTA();
        %
        % sim1.PlotPrctileDelayPerSTA(99)
        %
        % sim1.PlotTXOPwinNumber();
        %
        % sim1.PlotAPcollisionProb();
        %
        % sim1.PlotSTAselectionCounter();

        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % fprintf('------------------------------------------------------------------------ \n');
        % fprintf('Deployment %d  \n',i);
        % fprintf('DCF 50th-tile delay = %f ms \n',prctile(simDCF.delayvector,50)*1000);
        % fprintf('DCF 99th-tile delay = %f ms \n',prctile(simDCF.delayvector,99)*1000);
        % fprintf('CSRNumPk 50th-tile delay = %f ms \n',prctile(simCSRNumPk.delayvector,50)*1000);
        % fprintf('CSRNumPk 99th-tile delay = %f ms \n',prctile(simCSRNumPk.delayvector,99)*1000);
        % fprintf('CSROldPk 50th-tile delay = %f ms \n',prctile(simCSROldPk.delayvector,50)*1000);
        % fprintf('CSROldPk 99th-tile delay = %f ms \n',prctile(simCSROldPk.delayvector,99)*1000);
        % fprintf('CSRWeighted 50th-tile delay = %f ms \n',prctile(simCSRWeighted.delayvector,50)*1000);
        % fprintf('CSRWeighted 99th-tile delay = %f ms \n',prctile(simCSRWeighted.delayvector,99)*1000);
        % fprintf('------------------------------------------------------------------------ \n');

        % B = [[prctile(simDCF.delayvector,99)*1000, prctile(simCSRNumPk.delayvector,99)*1000, prctile(simCSROldPk.delayvector,99)*1000, prctile(simCSRWeighted.delayvector,99)*1000];
        %             [prctile(simDCF.delayvector,50)*1000, prctile(simCSRNumPk.delayvector,50)*1000, prctile(simCSROldPk.delayvector,50)*1000, prctile(simCSRWeighted.delayvector,50)*1000]];
        %
        % disp(B);

        DCFdelay = [DCFdelay;simDCF.delayvector];
        CSRNumPkdelay = [CSRNumPkdelay;simCSRNumPk.delayvector];
        CSROldPkdelay = [CSROldPkdelay;simCSROldPk.delayvector];
        CSRWeighteddelay = [CSRWeighteddelay;simCSRWeighted.delayvector];

        % updateWaitbar();

        % %%% Updating progress bar
        % waitbar(i/iterations,f,'General bar progress...');
    end

    % figure
    % % cdfplot(CSROldPkdelay*1000)
    % cdfplot(CSRWeighteddelay*1000)
    % %%% Close the progress bar
    % close(f);

    % %%% Saving variables
    DCFfilename = horzcat('/home/dnunez/Papers/journal_CSR_scheduling/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load', '/DCFdelay.mat');
    save(DCFfilename,"DCFdelay");

    CSRNumPkfilename = horzcat('/home/dnunez/Papers/journal_CSR_scheduling/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load','/CSRNumPkdelay.mat');
    save(CSRNumPkfilename,"CSRNumPkdelay");

    CSROldPkfilename = horzcat('/home/dnunez/Papers/journal_CSR_scheduling/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load','/CSROldPkdelay.mat');
    save(CSROldPkfilename,"CSROldPkdelay");

    CSRWeightedfilename = horzcat('/home/dnunez/Papers/journal_CSR_scheduling/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load','/CSRWeighteddelay.mat');
    save(CSRWeightedfilename,"CSRWeighteddelay");

end

toc














