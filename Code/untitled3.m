% Example Usage

% Create an instance of TrafficSourceBatch
ts = TrafficSourceBatch();

% Configure the properties
ts.bandwidth = 1000; % Example bandwidth
ts.L = 100; % Example packet size (mean size)
ts.type_generation = 0; % Markovian
ts.type_size = 0; % Markovian
ts.source_id = 1;
ts.priority = 5;

% Setup and start the TrafficSourceBatch
ts.Setup();
tic; % Start the simulation time
ts.Start();

% Wait for some time to simulate the process
pause(10); % Simulate for 10 seconds

% Stop the TrafficSourceBatch
ts.Stop();
