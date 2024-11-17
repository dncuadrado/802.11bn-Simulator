clear all
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Deployment Generator  %%%%%%%%%%%%%%%%%%


traffic_type = 'VR';        % 'Poisson', 'Bursty', 'VR'
traffic_load = '40-60';        % for BE, i.e., Poisson, Bursty: 'low', 'medium' , 'high'
                            % for VR:   '40-60', '40-90', '40-120'
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

%%% System-related
TXOP_duration = 5E-3;       % Duration of a TXOP, 5.484E-03;
Pn_dBm = -95;               % Noise in dbm
Cca = -82;                  % Clear channel assessment in dBm (default Cca = -82 dBm)
BW = 80;                    % Bandwidth e.g., 20, 40, 80, 160 [in MHz]
Nss = 2;                    % Number of spatial streams
L = 12E3;                   % Number of bits per single frame



%%% Compute the number of subcarriers, Nsc, as well as the total power used depending on the bandwidth and the number of spatial streams
[MaxTxPower, Nsc] = TXpowerCalc(BW, Nss);      % tx power per spatial streams and number of subcarriers

%%% Computing the needed overheads based on the simulation system, i.e., for DCF or CSR
[preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads] = OverheadsCalc();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rng(1);            % For reproducibility

iterations = 100;

AP_matrix = [grid_value/4,grid_value/4;
    grid_value/4,3*grid_value/4;
    3*grid_value/4,grid_value/4;
    3*grid_value/4,3*grid_value/4];

STA_matrix_save = NaN(STA_number,2, iterations);

%%% To validate my specific simulations
mySimValidation(AP_number, STA_number, grid_value, sim);

if strcmp(traffic_type, 'VR')
    EDCAaccessCategory = 'VI';
end
counter = 0;
for i = 1:iterations
    %%% Deployment-dependent %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %% Devices deployment (scenarios are randomly per default if "rng" above is commented )

    stop = 0;

    while stop == 0
        counter = counter + 1;

        [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value);
        % STA_matrix = STA_matrix_save(:,:,i);

        %%% Association independently of the position of STAs with respect to their corresponding APs
        association = AP_STA_Association(AP_number, STA_number, scenario_type);

        % % %%% Deployment PLOT
        % PlotDeployment(AP_matrix, STA_matrix, association, grid_value, walls);

        %%% Create a database with the RSSI values between all the APs and STAs and the association between APs and STAs
        [channelMatrix, RSSI_dB_vector_to_export] = GetChannelMatrix(MaxTxPower, Cca, AP_matrix, STA_matrix, scenario_type, walls);

        [per_STA_DCF_throughput_bianchi, ~] = Throughput_DCF_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
            Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads, EDCAaccessCategory);

        if 0.9*min(per_STA_DCF_throughput_bianchi) > 40   % Compare against the VR bitrate
            stop = 1;
        end
    end
    %
    STA_matrix_save(:,:,i) = STA_matrix;

    %%% Saving the deployment dataset
    filepath = horzcat('deployment datasets/',sim);
    if ~exist(filepath, 'dir')
        mkdir(filepath);
    end
    filename = horzcat(filepath,'/STA_matrix_save.mat');
    save(filename, "STA_matrix_save");
end
toc