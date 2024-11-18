function STAs_arrivals_matrix = TrafficGenerator(STA_number,validationFlag, ...
                                traffic_type, traffic_load, L, per_STA_DCF_throughput_bianchi, TrafficfileName, TrafficfilePath)
%%% Generates a cell array with the time of arrivals for each STA

event_number = 150000;                               % number of packets tx along the simulation

switch traffic_load
    case 'low'              % For BE traffic
        C = 0.3;
        trafficGeneration_rate = C*min(per_STA_DCF_throughput_bianchi)*1E6/L; % in packets/s
    case 'medium'
        C = 0.6;
        trafficGeneration_rate = C*min(per_STA_DCF_throughput_bianchi)*1E6/L; % in packets/s
    case 'high'
        C = 0.9;
        trafficGeneration_rate = C*min(per_STA_DCF_throughput_bianchi)*1E6/L; % in packets/s
end
%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Full-buffer
% traffic_load = 2000E6;                                  % bps
% trafficGeneration_rate = traffic_load/L;                % packets/s
% event_number = 20000000;                               % number of packets tx along the simulation
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch traffic_type
    case 'Poisson'      % Poisson distribution
        STAs_arrivals_matrix = poisson_fixed_events (STA_number, validationFlag, event_number, trafficGeneration_rate);
    case 'Bursty'
        STAs_arrivals_matrix = generate_burstTraffic(STA_number, event_number, trafficGeneration_rate);
    case 'VR'
        STAs_arrivals_matrix = generate_VRtraffic(STA_number, traffic_load, L);
    otherwise
        error('Traffic model is not properly specified');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Saving traffic dataset
% 
% %%% Saving STAs_arrivals_matrix to generate a dataset
% if ~exist(TrafficfilePath, 'dir')
%     mkdir(TrafficfilePath);
% end
% save(horzcat(TrafficfilePath, TrafficfileName),"STAs_arrivals_matrix");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STAs_arrivals_matrix = poisson_fixed_events (STA_number, validationFlag, event_number, trafficGeneration_rate)
    STAs_arrivals_matrix = cell(STA_number,1);

    for j = 1:STA_number

        %  Poisson waiting times follow an exponential distribution, w
        w(1) = 0.0;
        w(2:event_number+1) = - log ( rand ( event_number, 1 ) ) / trafficGeneration_rate;

      
        % Creating the line of time with the exponential times generated
        t(1:event_number+1) = cumsum ( w(1:event_number+1) );

   
        switch validationFlag
            case 'yes'  % Validation against full buffer needs a packet at timestamp = 0;
                STAs_arrivals_matrix{j} = t(1:end-1);
            case 'no'
                STAs_arrivals_matrix{j} = t(2:end);
        end
        
        % %%% Verifying that w follows an exponential distribution
        % %%% 1. Plot histogram with exponential PDF
        % figure;
        % histogram(w, 'Normalization', 'pdf');
        % hold on;
        % x = linspace(0, max(w), 100);
        % lambda = trafficGeneration_rate;           % : Expected rate (1/mean inter-arrival time)
        % y = lambda * exp(-lambda * x);
        % plot(x, y, 'r', 'LineWidth', 2);
        % title('Histogram of Inter-Arrival Times with Exponential PDF');
        % xlabel('Inter-Arrival Time');
        % ylabel('Probability Density');
        % legend('Data', 'Theoretical Exponential PDF');
        % hold off;
    end
    
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STAs_arrivals_matrix = generate_burstTraffic(STA_number, event_number, trafficGeneration_rate)
    
    STAs_arrivals_matrix = cell(STA_number,1);

    %%% Average on and off time
    average_on_time = 1E-3;
    average_off_time = 10E-3;

    % Expected proportion of time spent in the ON state
    on_off_ratio = average_on_time / (average_on_time + average_off_time);

    % Adjusted generation rate during ON periods to match overall generation rate
    adjusted_generation_rate = trafficGeneration_rate / on_off_ratio;
    for j = 1:STA_number
        
        % Initialize variables
        arrival_times = zeros(1,event_number); % Vector to store the arrival times of packets
        current_time = 0;   % Start at time 0
        total_packets_generated = 0; % Track the total number of packets generated

        % Loop until the desired number of packets is generated
        while total_packets_generated < event_number
            % ON period: Generate packets based on adjusted generation_rate
            on_period_duration = exprnd(average_on_time); % Random ON period duration
            packets_in_burst = floor(on_period_duration * adjusted_generation_rate); % Number of packets in this ON period

            for i = 1:packets_in_burst
                if total_packets_generated >= event_number
                    break;
                end
                inter_arrival_time = exprnd(1/adjusted_generation_rate); % Exponential inter-arrival time based on adjusted rate
                current_time = current_time + inter_arrival_time; % Update the current time
                total_packets_generated = total_packets_generated + 1;
                arrival_times(total_packets_generated) = current_time; % Record the arrival time
                
            end

            % OFF period: No packets generated
            off_period_duration = exprnd(average_off_time); % Random OFF period duration
            current_time = current_time + off_period_duration; % Skip time during OFF period
        end

        % Truncate the arrival times vector to the desired number of events
        arrival_times = arrival_times(1:event_number);
        arrival_times(arrival_times==0) = [];
        STAs_arrivals_matrix{j} = arrival_times;
    end
    % Calculate the actual generation rate including both ON and OFF periods
    % total_time = arrival_times(end); % Time at which the last packet arrives
    % effective_generation_rate = event_number / total_time; % Effective generation rate
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STAs_arrivals_matrix = generate_VRtraffic(STA_number, traffic_load, L)
    STAs_arrivals_matrix = cell(STA_number,1);
    
    % Split the string using the '-' delimiter
    values = split(traffic_load, '-');
    
    % Convert the split values to numbers and store them
    bitrate = str2double(values{1});
    fps = str2double(values{2});
    
    % Timestamp to stop the generation
    stopTimestamp = 20;

    % Parameters
    frame_interval = 1 / fps; % Interval between frames in seconds

    % Calculate the number of frames required for each arrival based on bitrate
    frames_per_burst = ceil((bitrate * 1e6 * frame_interval) / L); % Number of consecutive frames per burst
    frame_spacing = 5e-6; % Spacing between frames in burst (5 microseconds)

    % % Initialize figure for plotting
    % figure; hold on;
    % colors = lines(STA_number); % Colors for each STA plot

    for sta = 1:STA_number
        % Initialize for each STA
        interarrival_times = []; % Store inter-arrival times for each STA

        % Initializing the uniform offset between [0, 1/fps]
        current_time = rand() * frame_interval;

        % Generate inter-arrival times until reaching the stop timestamp
        while current_time < stopTimestamp
            % Generate a burst of frames for each arrival
            burst_times = current_time + (0:frames_per_burst-1) * frame_spacing;
            interarrival_times = [interarrival_times, burst_times]; % Append burst times

            % Move to the next frame interval
            current_time = current_time + frame_interval;
        end

        % Store inter-arrival times in the cell array
        STAs_arrivals_matrix{sta} = interarrival_times;

        % % Plot the arrivals for the STA
        % plot(interarrival_times, sta * ones(size(interarrival_times)), '.', 'Color', colors(sta, :), 'MarkerSize', 10);
    end

    % To verify the bitrate and fps
    % for nnn=1:STA_number
    %     12E3*length(STAs_arrivals_matrix{nnn})/(1E6*STAs_arrivals_matrix{nnn}(end));
    %     1/(STAs_arrivals_matrix{nnn}(frames_per_burst+1)-STAs_arrivals_matrix{nnn}(1));
    % end


    % % Plot configuration
    % xlabel('Time (seconds)');
    % ylabel('STA Number');
    % title('VR Traffic Arrivals per STA');
    % legend(arrayfun(@(x) ['STA ' num2str(x)], 1:STA_number, 'UniformOutput', false));
    % grid on;
    % hold off;
    % 
    % % Display result
    % disp('Traffic arrivals generated for each STA stored in STA_cell array:');
    % disp(STAs_arrivals_matrix);


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


