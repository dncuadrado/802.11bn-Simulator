classdef MAPCsim < handle
    % Traffic class to handle the traffic generated for the STAs 

    properties ( Access = 'private' )
        %%% System-related
        TXOP_duration                           % Duration of a TXOP
        Pn_dBm                                  % Noise in dbm
        Cca                                     % Clear channel assessment in dBm (default Cca = -82 dBm)
        BW                                      % Bandwidth e.g., 20, 40, 80, 160 [in MHz]  
        Nss                                     % Number of spatial streams
        Nsc                                     % Number of subcarriers
        tx_power_ss
            
        %%% Scenario-related
        association                             % Cell array with the list of STAs associated to APs
        RSSI_dB_vector_to_export

        %%% Traffic-related
        event_number = 150000;                   % number of events to explore
        APs_packet_indicator                    % Indicator of AP availability of packets to transmit (used mainly in the backoff process)
        firstPosPosition                        % controls the position  of the first available packet to transmit to each STA 
        lastPosTimestamp                        % controls the timestamp of the last available packet to transmit to each STA (sensitive to sim timeline) 
        lastPosPosition                         % controls the position  of the last available packet to transmit to each STA (sensitive to sim timeline)
        rrobin_DCF_group_selector               % indicates the STA to transmit
        rrobin_CSR_group_selector               % indicates the group to transmit
        tempDelay                               % track the temporal delay 


        %%% Backoff-related
        backoffValues                           % vector which stores the backoff values
        backoffStage                            % vector with the current stage of the backoff of each AP, from 1 to 6, 
                                                % stage 1: 0-15
                                                % stage 2: 0-31
                                                % stage 6: 0-1023
        
        %%% TXOP-related
        preTX_overheadsDCF                      % DCF overheads before transmission 
        preTX_overheadsCSR                      % CSR overheads before transmission
        DCFoverheads                            % Entire DCF overheads
        CSRoverheads                            % Entire CSR overheads    

        %%% STA selection counter


        %%% For results
        throughput_sim
        
    end

    properties ( Access = 'public' )    
        n_APs                                   % number of APs
        n_STAs                                  % number of stations

        STA_queue_timeline                      % matrix that contains the traffic arrivals, n_STAs x event_number dimensions to the case it is generated by Generator
        firstPosTimestamp                       % controls the timestamp of the first available packet to transmit to each STA  
        delivery_timestamp_record               % cell array to store for each STA the timestamp at which every packet is transmitted 
        delay_per_STA                           % stores the delay per STA
        delayvector                             % vector that contains the delay of all STAs
        traffic_type                            % Poisson, Bursty
        timestamp_to_stop                       % simulation duration [in seconds]


        TXOPwinNumber                           % stores each time that an AP wins the contention
        TXOPcollision                           % stores each time an AP has a collision
        STAselectionCounter                     % stores the number of times that each STA is selected
        APcollision_prob                        % stores the collision probability per AP

        %%% MAPC related
        simulation_system
        validationFlag
        CGs_STAs                                % Matrix that stores the C-SR groups
        scheduler                               % scheduling: - Number of packets: 'MNP' 
                                                %             - Oldest packet: 'OP'
                                                %             - Random selection: 'Random'
                                                %             - TAT selection: 'TAT'
                                                %             - Hybrid selection: 'Hybrid'  

        alpha_ = 1/2;                           % For TAT scheduler- default 1/2
        beta_ = 1/2;                            % For TAT scheduler- default 1/2
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = MAPCsim(n_APs, n_STAs, association, RSSI_dB_vector_to_export, traffic_type, timestamp_to_stop, ...
                scheduler, simulation_system, validationFlag, TXOP_duration, Pn_dBm, Cca, BW, Nss, Nsc, preTX_overheadsDCF, preTX_overheadsCSR, DCFoverheads, CSRoverheads) % initialize object (constructor)
            
            %%% Initializing properties
            %%% System-related
            self.TXOP_duration = TXOP_duration;  % Duration of a TXOP
            self.Pn_dBm = Pn_dBm;               % Noise in dbm
            self.Cca = Cca;                  % Clear channel assessment in dBm (default Cca = -82 dBm)
            self.BW = BW;                    % Bandwidth e.g., 20, 40, 80, 160 [in MHz]  
            self.Nss = Nss;                    % Number of spatial streams
            self.Nsc = Nsc;
        

            self.n_STAs = n_STAs;                  
            self.n_APs = n_APs;                 
            self.association = association; 
            self.RSSI_dB_vector_to_export = RSSI_dB_vector_to_export;
            
            self.traffic_type = traffic_type;
            self.timestamp_to_stop = timestamp_to_stop;

            self.STA_queue_timeline = zeros(self.n_STAs,self.event_number); 
            self.firstPosTimestamp = zeros(n_STAs,1);
            self.firstPosPosition = zeros(n_STAs,1);


            self.lastPosTimestamp = zeros(n_STAs,1);
            self.lastPosPosition = zeros(n_STAs,1);
            self.delivery_timestamp_record = cell(n_STAs,1); 
            
            self.simulation_system = simulation_system;
            self.validationFlag = validationFlag;
            self.scheduler = scheduler;
            
            
            self.APs_packet_indicator = zeros(n_APs,1);
            self.backoffValues = randi([0 15],1,self.n_APs);
            self.backoffStage = zeros(n_APs,1);

            self.TXOPwinNumber = zeros(n_APs,1);
            self.TXOPcollision = zeros(n_APs,1);
            
            self.preTX_overheadsDCF = preTX_overheadsDCF;                  
            self.preTX_overheadsCSR = preTX_overheadsCSR;                     
            self.DCFoverheads = DCFoverheads;                            
            self.CSRoverheads = CSRoverheads;                            

            self.STAselectionCounter = zeros(n_STAs,1);
            
            self.throughput_sim = zeros(n_STAs,1);
            self.delay_per_STA = cell(self.n_STAs,1);
            self.tempDelay = cell(self.n_STAs,1);
            self.delayvector = [];
            self.APcollision_prob = 0;
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    methods ( Access = 'private' )

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function CGcreation(self)
            
            if strcmp(self.simulation_system,'CSR') %%% groups for CSR
                if strcmp(self.validationFlag,'yes')
                    %%% For validating simulated CSR against CSR bianchi's model uncomment this (Brute Force)
                    [self.CGs_STAs]  = CG_creation_per_STA_brute_force(self.n_APs, self.n_STAs, self.DCFoverheads, self.CSRoverheads, ...
                        self.Pn_dBm, self.Nsc, self.Nss, self.RSSI_dB_vector_to_export, self.association, self.TXOP_duration);
                else
                    [self.CGs_STAs, ~] = CG_creation(self.n_APs, self.n_STAs, self.DCFoverheads, self.CSRoverheads, ...
                        self.Pn_dBm, self.Nsc, self.Nss, self.RSSI_dB_vector_to_export, self.association, self.TXOP_duration);
                    
                    % self.CGs_STAs = CG_creation_per_STA(self.n_APs, self.n_STAs, 40, ...
                    %             self.Pn_dBm, self.RSSI_dB_vector_to_export, self.association);
                end
            else
                % %%% CG creation (for ST and DCF --not needed though--)
                self.CGs_STAs = CG_creation_per_STA_singleSTA(self.n_APs, self.n_STAs, self.association); 
            end

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function UpdateAP(self,sim_timeline)
            %%% Updates a vector that indicates whether each AP has packets to transmit. Each position indicates the AP
            %%% idx
            
            %%% Restarting all APs to zero
            self.APs_packet_indicator = zeros(self.n_APs,1);
            
            %%% Finding APs with packets at sim timelime and putting ones in those AP positions
            for k = 1:self.n_APs
                if sum(self.firstPosTimestamp([self.association{k}]) <= sim_timeline)~=0
                    self.APs_packet_indicator(k,1) = 1;
                end
            end      
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function UpdateSTA(self, STA_rx, received_packets, sim_timeline, temp_elapsed_time)
            if received_packets ~= 0 % If at least one packet properly received , i.e., received_packets~=0, update STA properties, otherwise, jump it 
                %%% Update STA properties
                position_pointer = self.firstPosPosition(STA_rx)+received_packets;

                %%% Updating delivery timestamp
                self.delivery_timestamp_record{STA_rx}(self.firstPosPosition(STA_rx):position_pointer-1) = sim_timeline + temp_elapsed_time;

                %%% Validation for negative delay
                if (self.delivery_timestamp_record{STA_rx}(end) - self.STA_queue_timeline(STA_rx,length(self.delivery_timestamp_record{STA_rx})))  <= 0
                    error('Value of delay is not valid')
                end
                
                %%% Update the Position and the Timestamp of the first available packet for each STA
                self.firstPosTimestamp(STA_rx) = self.STA_queue_timeline(STA_rx,position_pointer);  % timestamp
                self.firstPosPosition(STA_rx) = position_pointer;                                   % position
                self.tempDelay{STA_rx} = [self.delivery_timestamp_record{STA_rx,:}] - self.STA_queue_timeline(STA_rx,1:length([self.delivery_timestamp_record{STA_rx,:}]));
            end
            %%% Updating the counter of STA selection
            self.STAselectionCounter(STA_rx) = self.STAselectionCounter(STA_rx) + 1;
                
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [backofftime, TXOPwinner] = Backoff(self)
            %%% Backoff process
            CWmin = 16;
            
            APs_with_packets = find(self.APs_packet_indicator==1);
            % fprintf('Backoff values = [ %d %d %d %d ] \n',self.backoffValues);
            % fprintf('APs with packets = [ %d %d %d %d ] \n',APs_with_packets);

            slotnum = min(self.backoffValues(APs_with_packets));                      % stores the current number of backoff slots
            self.backoffValues(APs_with_packets) = self.backoffValues(APs_with_packets) - slotnum;      
            idx = find(self.backoffValues(APs_with_packets)==0);                      % find the position of the device(s) that reach zero
            
            decrementing_backoff = 1;
            collision_counter = 0;
            while decrementing_backoff
                if length(idx)==1           % we have a winner
                    TXOPwinner = APs_with_packets(idx);
                    % fprintf('TXOP winner - AP%d \n',TXOPwinner);
                    self.TXOPwinNumber(APs_with_packets(idx)) = self.TXOPwinNumber(APs_with_packets(idx)) + 1;   % increase the counter of TXOP wins
                    self.backoffValues(APs_with_packets(idx)) = randi([0 (CWmin-1)],1,1);    % the TXOP winner restart its backoff counter
                    self.backoffStage(APs_with_packets(idx)) = 0;                     % the backoff stage of the TXOP winner is restarted to stage 1, i.e., ([0 15])                     
                    decrementing_backoff = 0;
                else                        % a collision occurred 
                    % fprintf('Collisioned APs = [ %d %d] \n',idx);
                    for i = 1:length(idx)
                        self.TXOPwinNumber(APs_with_packets(idx(i))) = self.TXOPwinNumber(APs_with_packets(idx(i))) + 1;   % increase the counter of TXOP wins
                        self.TXOPcollision(APs_with_packets(idx(i))) = self.TXOPcollision(APs_with_packets(idx(i))) + 1;   % increase the counter of collisions for this AP 

                        if self.backoffStage(APs_with_packets(idx(i))) < 6 % Increment the stage until the maximum stage number, m = 6
                            % self.backoffStage(APs_with_packets(idx(i))) = 0;  % single backoff
                            self.backoffStage(APs_with_packets(idx(i))) = self.backoffStage(APs_with_packets(idx(i))) + 1;      % the backoff stage of the collided device is increased to the next stage
                        end
  
                        self.backoffValues(APs_with_packets(idx(i))) = randi([0 (CWmin*2^(self.backoffStage(APs_with_packets(idx(i))))-1)],1,1);    % the backoff counter of the collided device is restarted
                        % fprintf('Selected backoff value: %d \n',self.backoffValues(APs_with_packets(idx(i))));                                                                                                                         % The new upper value of the CW = CWmin*2^i - 1
                                                                                                                                                 % The selected value is a random number between 0 and CW
                    end
                    
                    slotnum = slotnum + min(self.backoffValues(APs_with_packets));    % old backoff number + new backoff number
                    collision_counter = collision_counter + 1;   % increase the number of collisions
                    self.backoffValues(APs_with_packets) = self.backoffValues(APs_with_packets) - min(self.backoffValues(APs_with_packets));
                    idx = find(self.backoffValues(APs_with_packets)==0);
                    % fprintf('Backoff values = [ %d %d %d %d ] \n',self.backoffValues);
                end
    
            end
            

            % Tc = 56E-6 + 16e-6 + 48E-6 + 34e-6 + 9e-6;        % collision duration -----> Tc = RTS + SIFS + CTS + DIFS + Te
            Tc = 42E-6 + 16e-6 + 36E-6 + 34e-6 + 9e-6;
                                         
            

            backofftime = slotnum*9e-6 + collision_counter*Tc;  % time due to backoff + collisions (if any)
            % fprintf('Slot number = %d \n',slotnum);
            % fprintf('Number of collisions = %d \n',collision_counter);
            % fprintf('Backoff values = [ %d %d %d %d ] \n',self.backoffValues);
            % fprintf('Backof stage = [%d %d %d %d] \n',self.backoffStage');
            % disp('----------------------------------');

            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [STA_rx, APs] = schedulingV1(self, sim_timeline, TXOPwinner)
            %%% Scheduling %%%%%%%
            
            switch self.simulation_system
                case 'DCF'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
                    %%%%%%%      DCF     %%%%%%%%%%

                    switch self.validationFlag
                        case 'yes'
                            %%% Round Robin scheduling. ONLY to compare with Bianchi's model. 
                            %%% Initializing round robin counter
                            if sum(self.firstPosPosition)==self.n_STAs
                                for k = 1:self.n_APs
                                    self.rrobin_DCF_group_selector{k}(:) = [1;zeros(length(self.association{k})-1,1)];
                                end
                            end
                            %%% Selecting the corresponding STA depending on the state of self.rrobin_DCF_group_selector{TXOPwinner}
                            STA_rx = self.association{TXOPwinner}(self.rrobin_DCF_group_selector{TXOPwinner}==1);
                            %%% Updating the round robin counter
                            self.rrobin_DCF_group_selector{TXOPwinner} = circshift(self.rrobin_DCF_group_selector{TXOPwinner},1);

                            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        otherwise
                            % %%% STA selection. Looks for the STA with the oldest packet in the queue of the TXOP winner
                            [~, STAidx] = min(self.firstPosTimestamp([self.association{TXOPwinner}]));
                            STA_rx = self.association{TXOPwinner}(STAidx);
                    end

                    %%% AP
                    APs = TXOPwinner;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                otherwise
                    %%% Scheduling the STAs based on:
                    % if self.validationFlag = 'yes', it uses a round robin scheduler, i.e., same tx probability for all devices

                    %%% Looking for STAs with packets available
                    CGs = self.CGs_STAs;
                    for j=1:self.n_STAs
                        if self.firstPosTimestamp(j) > sim_timeline     % Jump if the given STA does not have any packets at sim timeline
                            [rowSTA, colSTA] = find(CGs==j);
                            CGs(rowSTA,colSTA) = 0;                % Remove the STA from all the groups where it appears
                            continue
                        end
        
                        %%% lastPosPosition is used below to estimate the total number of packets available until sim_timeline
                        self.lastPosPosition(j) = find(self.STA_queue_timeline(j,:)<=sim_timeline,1,'last');
                        self.lastPosTimestamp(j) = self.STA_queue_timeline(j,self.lastPosPosition(j));
                    end
                    
                    CGs = unique(CGs,'rows','stable');
                    CGs(~any(CGs,2),:) = [];      % removing all-zero rows 

        
                    uni = cell(size(CGs,1),1);
                    ScorePackets = zeros(size(CGs,1),1);       % Scores the number of packets of each group
                    ScoreTimeOldest = zeros(size(CGs,1),1);          % Scores the timestamp of the oldest packet of the group
                    ScoreTAT = zeros(size(CGs,1),1); 

                    for i = 1:size(CGs,1)
                        u = unique(CGs(i,:));
                        u(u==0) = [];
                        uni{i} = u;
        
                        ScorePackets(i) = sum(self.lastPosPosition(u)-self.firstPosPosition(u) + 1);    % sum all the available packets per group
                        ScoreTimeOldest(i) = min(self.firstPosTimestamp(u));                            % finds the oldest packet per group
                        
                        if strcmp(self.scheduler,'TAT') || strcmp(self.scheduler,'Hybrid')
                            ei_min = min(self.firstPosTimestamp(u));
                            ei_max = max(self.firstPosTimestamp(u));
                            t = sim_timeline;
                            delta_nt = t - ei_min;
                            Delta_nt = t - ei_max;


                            if length(u) == 1
                                ScoreTAT(i) = delta_nt;
                            else
                                % ScoreTAT(i) = delta_nt + delta_nt*Delta_nt/(alpha_*delta_nt);   % ok
                                ScoreTAT(i) = delta_nt + self.beta_*(Delta_nt - self.alpha_*delta_nt);
                            end
                        end

                    end
                    
                    switch self.validationFlag
                        case 'yes'
                            if self.rrobin_CSR_group_selector==0 % initializing the round robin CSR selector
                                self.rrobin_CSR_group_selector = zeros(size(self.CGs_STAs,1),1);
                                self.rrobin_CSR_group_selector(1,:) = 1;
                            end


                            %%% Bianchi's paper model
                            % STA = self.association{TXOPwinner}(randi([1 length(self.association{TXOPwinner}(:))],1,1)); %% The TXOP winner randomly selects one of its STAs 
                            % [idx_score, ~] = find(self.CGs_STAs == STA);   % Find the group where the selected STA appears

                            %%% Round Robin
                            idx_score = find(self.rrobin_CSR_group_selector==1);
                            self.rrobin_CSR_group_selector = circshift(self.rrobin_CSR_group_selector,1);
                        otherwise
                            switch self.scheduler
                                case 'MNP' % priority is the group with the highest number of packets
                                    [maxScore, idx_score] = max(ScorePackets);          % find the group with the highest number of packets
                                    equalScoreIdx = find(ScorePackets==maxScore);       % looks for more than one group with the same number of packets among the winners
                                    if length(equalScoreIdx)~=1                         % if true (i.e., a tie, more than one winners)
                                        [~, idx_score_temp] = min(ScoreTimeOldest(equalScoreIdx));
                                        idx_score = equalScoreIdx(idx_score_temp);         % select the group with the oldest packet among the winners
                                    end
                                case 'OP' % priority is the group with the oldest packet
                                    [minOldestScore, idx_score] = min(ScoreTimeOldest);
                                    equalScoreIdx = find(ScoreTimeOldest==minOldestScore);       % looks for more than one group with the same timestamp among the winners (probably due to the same STA in these groups)
                                    if length(equalScoreIdx)~=1                         % if true (i.e., a tie, more than one winners)
                                        [~, idx_score_temp] = max(ScorePackets(equalScoreIdx));
                                        idx_score = equalScoreIdx(idx_score_temp);         % select the group with the highest number of packets among the winners
                                    end
                                case 'Random' % random selection
                                    idx_score = randi([1 length(uni)],1,1);
                                case 'TAT' % CSR TAT 
                                    [~, idx_score] = max(ScoreTAT);
                                case 'Hybrid' % CSR hybrid
                                    if ~isempty([self.tempDelay{:}])
                                        prcentile = prctile([self.tempDelay{:}],50);
                                        % prcentile = 5E-3;
                                    else
                                        prcentile = 5E-3;
                                    end

                                    if delta_nt > prcentile % OP
                                        [minOldestScore, idx_score] = min(ScoreTimeOldest);
                                        equalScoreIdx = find(ScoreTimeOldest==minOldestScore);       % looks for more than one group with the same timestamp among the winners (probably due to the same STA in these groups)
                                        if length(equalScoreIdx)~=1                         % if true (i.e., a tie, more than one winners)
                                            [~, idx_score_temp] = max(ScorePackets(equalScoreIdx));
                                            idx_score = equalScoreIdx(idx_score_temp);         % select the group with the highest number of packets among the winners
                                        end
                                    else    % MNP
                                        [maxScore, idx_score] = max(ScorePackets);          % find the group with the highest number of packets
                                        equalScoreIdx = find(ScorePackets==maxScore);       % looks for more than one group with the same number of packets among the winners
                                        if length(equalScoreIdx)~=1                         % if true (i.e., a tie, more than one winners)
                                            [~, idx_score_temp] = min(ScoreTimeOldest(equalScoreIdx));
                                            idx_score = equalScoreIdx(idx_score_temp);         % select the group with the oldest packet among the winners
                                        end
                                    end
                            end
                    end

                    %%% Getting the resulting STAs for this TXOP
                    STA_rx = sort([uni{idx_score}]');
                    
        
                    %%% Finding the APs which these STAs are associated to:
                    % Initialize a vector to store the positions
                     APs = zeros(size(STA_rx));
                    
                    % Loop through each value in STA_rx
                    for i = 1:length(STA_rx)
                        % Find the position where the current value appears in the association cell array
                        idx = find(cellfun(@(x) ismember(STA_rx(i), x), self.association), 1);
                        
                        % Store the position in the vector
                        APs(i) = idx;
                    end
            end
                
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function elapsed_time = TXtimeCalc(self, STA_rx, APs, pd, sim_timeline, data_tx_time)
            %%% TX calculation. Computes the time (temp_elapsed_time) spent by the given STA_rx and APs to transmit 
            %%% as well as the number of transmitted packets (transmitted_packets).

            %%%%%%%%% Transmissions 
            %%% Initializing tx parameters
            MCS = zeros(length(STA_rx),1);
            N_bps = zeros(length(STA_rx),1);
            Rc = zeros(length(STA_rx),1);
            
            agg_packets = zeros(length(STA_rx),1);
            lastPos = zeros(length(STA_rx),1);
            firstPos = zeros(length(STA_rx),1);
            
            tx_Packets = zeros(length(STA_rx),1);
            received_packets = zeros(length(STA_rx),1);
            temp_elapsed_time = zeros(length(STA_rx),1);
            
            
            %%% Computing the transmitted_packets and the time spent to tx them (temp_real_time)
            for k = 1:length(STA_rx)  
                PRx = 10^(self.RSSI_dB_vector_to_export(STA_rx(k,1),APs(k))/10);
        
                %%% Interference computation
                Pint_temp = 0;
                if length(APs) > 1      % For multi-AP case
                    AP_other_vector = setdiff(APs,APs(k));
                    for l = 1:length(AP_other_vector)   
                        Pint_temp = Pint_temp + 10^(self.RSSI_dB_vector_to_export(STA_rx(k,1),AP_other_vector(l))/10);
                    end
                else
                    Pint_temp = 0;
                end
        
                %%% SINR calculation
                SINR = PRx/(Pint_temp + 10^(self.Pn_dBm/10));
                SINR_db = 10*log10(SINR);
                
                %%% N_bps and Rc calculation
                switch self.validationFlag
                    case 'yes'
                        [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);
                    otherwise
                        % Using a variable to randomly modify the SINR value
                        SNR_db_deviation = random(pd);
                        [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db+SNR_db_deviation);
                        % [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);
                end
       
                %%% Max number of A-MPDUs (packets allowed due to SINR)
                agg_packets(k,1) = tx_packets(self.Nsc, N_bps(k,1), Rc(k,1), self.Nss, data_tx_time);
        
                %%% Validations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% Number of packets validation
                if agg_packets(k,1) > 1024
                    error('Imposible to tx more than 1024 MPDUs')
                end
                %%% MCS validation.  MCS = -1, means that the SINR is under the minimum allowed
                if MCS(k,1) == -1 
                    error('Not a valid MCS');
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
                %%% Find the real number of packets to be transmitted ----> packets in queue vs packets allowed (due to SINR)
                % lastPos(k,1) = traffic.lastPosPosition(STA_rx(k));
                lastPos(k,1) = find(self.STA_queue_timeline(STA_rx(k),:)<=sim_timeline,1,'last');
                firstPos(k,1) = self.firstPosPosition(STA_rx(k));
        
                if (lastPos(k,1) - firstPos(k,1) + 1) > agg_packets(k,1)                % arrived packets > allowed packets (based on SINR ---agg_packets) to transmit in this TXOP 
                    tx_Packets(k,1) = agg_packets(k,1);
                else
                    tx_Packets(k,1) = lastPos(k,1) - firstPos(k,1) + 1;        % arrived packets < allowed packets (based on SINR ---agg_packets) to transmit in this TXOP
                end
                
               
                %%% This avoids to transmit more packets that the total number of packets of the STA_queue_timeline
                if (firstPos(k,1) + tx_Packets(k,1) - 1) >= length(self.STA_queue_timeline(STA_rx(k),:))
                    tx_Packets(k,1) = length(self.STA_queue_timeline(STA_rx(k),:)) - firstPos(k,1);
                end
                

                %%% Real time spent to transmit data
                switch self.validationFlag 
                    case 'yes' 
                        received_packets(k,1) = tx_Packets(k,1);
                        temp_elapsed_time(k,1) = data_tx_time;
                    otherwise
                        received_packets(k,1) = binornd(tx_Packets(k,1),(1-1E-2)); % binomial distribution where max_numPackets is the number of trials 
                                                                                   % and success probability = 1 - PER ---> PER = 1E-2
                        temp_elapsed_time(k,1)  = elapsed_time_tx(self.Nsc, N_bps(k,1), Rc(k,1), self.Nss, tx_Packets(k,1)); % tx packets could be different to rx packets (some losses) 
                end
                
                %%% Updating the position of the first valid packet for each STA and updating delivery_timestamp_record
                self.UpdateSTA(STA_rx(k),received_packets(k,1), sim_timeline, temp_elapsed_time(k,1));
            end      

            %%% elapsed_time is the max among all  
            elapsed_time = max(temp_elapsed_time);

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function TrafficAnalysis(self)

            %%% Analysis of the results
            for j=1:self.n_STAs      % per STA Analysis
                self.delay_per_STA{j} = [self.delivery_timestamp_record{j,:}] - self.STA_queue_timeline(j,1:length([self.delivery_timestamp_record{j,:}]));
                self.delayvector = [self.delayvector;self.delay_per_STA{j}']; 
                self.throughput_sim (j) = 12E3*length([self.delivery_timestamp_record{j,:}])/(1E6*(max([self.delivery_timestamp_record{j,:}]))); 
            end
            
            for jj=1:self.n_APs      % Per AP analysis        
                self.APcollision_prob(jj) = self.TXOPcollision(jj)./self.TXOPwinNumber(jj); 
            end
            

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    end  
    
    methods ( Access = 'public' )

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function InitSTA(self)
            %%% Initializing STAs
            for i=1:self.n_STAs
                self.firstPosTimestamp(i,1) = self.STA_queue_timeline(i,1);     % The first timestamp in the STA queue timeline
                self.firstPosPosition(i,1) = 1;        % The first packet available for each STA is the number 1
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Start(self)
            
            %%% Create the MAPC groups
            self.CGcreation(); 

            %%% To vary the SINR at the receivers
            pd = makedist('Normal','mu',0,'sigma',1);   % create a random variable with Normal dist, mean=0 and std deviation=1

            %%% Line of time
            sim_timeline = 0;

            %%% Simulation
            while sim_timeline < self.timestamp_to_stop

                %%% to forward the simulation timeline up to the next packet arrival
                if min(self.firstPosTimestamp) > sim_timeline
                    sim_timeline = min(self.firstPosTimestamp);
                end

                %%% Update the buffer state of APs, to indicate whether they have packets or not to tx
                self.UpdateAP(sim_timeline);

                %%% Contention process. Backoff and TXOP winner
                [backofftime, TXOPwinner] = self.Backoff();          % backoff time can also include time due to collisions

                %%% Moving forward the simulation timeline, i.e., after backoff and collisions (if any)
                sim_timeline = sim_timeline + backofftime;

                %%% Scheduling. STAs and APs selection for the ongoing TXOP depending on the simulation_system employed, i.e., DCF or CSR
                [STA_rx, APs] = self.schedulingV1(sim_timeline, TXOPwinner);
                

                %%% Moving forward the simulation timeline, after pre tx overheads that depend on whether the TXOP will be single or
                %%% coordinated
                if strcmp(self.simulation_system,'DCF') % for DCF
                    sim_timeline = sim_timeline + self.preTX_overheadsDCF; % moving the timeline up to: sim_timeline + RTS + SIFS + CTS + SIFS + time_preamble_data
                    data_tx_time = self.TXOP_duration - self.DCFoverheads;
                else % for ST and CSR
                    sim_timeline = sim_timeline + self.preTX_overheadsCSR; % moving the timeline up to: sim_timeline + TRTS + TSIFS + TCTS + TSIFS + T_MAPC_TXOP + TSIFS + time_preamble_data;
                    data_tx_time = self.TXOP_duration - self.CSRoverheads;
                end

                %%% TX calculation. Computes the elapsed time due to the transmission. Updates also the per STA traffic queues
                %%% depending on the number of transmitted packets
                elapsed_time = self.TXtimeCalc(STA_rx, APs, pd, sim_timeline, data_tx_time);

                %%% Updating the simulation timeline
                sim_timeline = sim_timeline + elapsed_time + 159E-06;   % 159us: TSIFS + TBACK + DIFS + Te;

            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%% Analysis

            self.TrafficAnalysis();

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
end  
