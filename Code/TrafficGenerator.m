function STAs_arrivals_matrix = TrafficGenerator(STA_number,validation, traffic_type,event_number, trafficGeneration_rate)

STAs_arrivals_matrix = zeros(STA_number,event_number);
%%% Generates a traffic matrix, with the time of arrivals for each STA
switch validation
    case 'yes'
        for j = 1:STA_number
            A = poisson_fixed_events(event_number, trafficGeneration_rate)';                              % Poisson distribution (lambda,event_number)
            STAs_arrivals_matrix(j,:) = A(1:end-1);
        end
    otherwise
        for j = 1:STA_number
            if strcmp(traffic_type,'Poisson')
                A = poisson_fixed_events(event_number, trafficGeneration_rate)';                              % Poisson distribution
                STAs_arrivals_matrix(j,:) = A(2:end);                       % removing packets at t=0
            elseif strcmp(traffic_type,'Bursty')
                STAs_arrivals_matrix(j,:) = generate_burstTraffic(event_number, trafficGeneration_rate)';
                if sum(STAs_arrivals_matrix(j,:)==0)~=0
                    STAs_arrivals_matrix(j,STAs_arrivals_matrix(j,:)==0) = [];
                end
            else
                error('Traffic model is not properly specified');
            end
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ t, w ] = poisson_fixed_events (event_number, trafficGeneration_rate)
    %
    %  Input:
    %
    %    real LAMBDA, the average number of events per unit time.
    %
    %    integer EVENT_NUM, the number of events to wait for.
    %
    %  Output:
    %
    %    real T(EVENT_NUM+1), the time at which a total of 0, 1, 2, ...
    %    and EVENT_NUM events were observed.
    %
    %    real W(EVENT_NUM+1), the waiting time until the I-th event
    %    occurred.
    %

    %
    %  Poisson waiting times follow an exponential distribution.
    %
    w(1) = 0.0;
    w(2:event_number+1) = - log ( rand ( event_number, 1 ) ) / trafficGeneration_rate;
    %
    %  The time til event I is the sum of the waiting times 0 through I.
    %
    t(1:event_number+1) = cumsum ( w(1:event_number+1) );

    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arrival_times = generate_burstTraffic(event_number, trafficGeneration_rate)

    %%% This settings corresponds to 90 fps
    average_on_time = 1E-3;
    average_off_time = 10E-3;

    % Initialize variables
    arrival_times = []; % Vector to store the arrival times of packets
    current_time = 0;   % Start at time 0
    total_packets_generated = 0; % Track the total number of packets generated

    % Expected proportion of time spent in the ON state
    on_off_ratio = average_on_time / (average_on_time + average_off_time);

    % Adjusted generation rate during ON periods to match overall generation rate
    adjusted_generation_rate = trafficGeneration_rate / on_off_ratio;

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
            arrival_times = [arrival_times; current_time]; % Record the arrival time
            total_packets_generated = total_packets_generated + 1;
        end

        % OFF period: No packets generated
        off_period_duration = exprnd(average_off_time); % Random OFF period duration
        current_time = current_time + off_period_duration; % Skip time during OFF period
    end

    % Truncate the arrival times vector to the desired number of events
    arrival_times = arrival_times(1:event_number);

    % Calculate the actual generation rate including both ON and OFF periods
    total_time = arrival_times(end); % Time at which the last packet arrives
    effective_generation_rate = event_number / total_time; % Effective generation rate
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end