clear all
rng(1)
event_number = 10000;       % Generate 1000 packets
traffic_load = 1E6;
generation_rate = traffic_load/12E3;    
average_on_time = 1E-3;       % Average ON period lasts 1 second
average_off_time = 20E-3;      % Average OFF period lasts 2 seconds

[arrival_times, effective_generation_rate] = generate_packet_arrival_times(event_number, generation_rate, average_on_time, average_off_time);

% Display the effective generation rate
disp(['Effective generation rate: ', num2str(effective_generation_rate), ' packets/second']);

% Plot the inter-arrival times
inter_arrival_times = diff([0; arrival_times]);
figure;
stem(arrival_times, 1000*inter_arrival_times);
xlabel('Time (s)');
ylabel('Inter-Arrival Time (ms)');
title('Packet Arrival Times');

figure
stem(arrival_times,ones(10000,1));
xlabel('Time (s)');
ylabel('Normalized packet lenght');





