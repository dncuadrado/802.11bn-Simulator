function SetParalellpool()

%%% To set the parpool. 

% Check the info about cores
core_info = evalc('feature(''numcores'')');

% Use a regular expression to find the number of logical cores
logicalCores = regexp(core_info, 'detected: (\d+) logical cores', 'tokens');

% Convert from cell array to number
if ~isempty(logicalCores)
    numLogicalCores = str2double(logicalCores{1}{1});
else
    error('Could not find the number of logical cores in core_info');
end


numLogicalCores = 4;


% Start or adjust the parallel pool to use the detected number of workers
if isempty(gcp('nocreate'))
    % Start a new parallel pool with detected number of workers
    pctConfig = parcluster;
    pctConfig.NumWorkers = numLogicalCores;
    pctConfig.NumThreads = 1;  % Limit each worker to 1 thread
    parpool(pctConfig, numLogicalCores);
else
    % Adjust existing parallel pool size if necessary
    currentPool = gcp;
    if currentPool.NumWorkers ~= numLogicalCores
        delete(currentPool);           % Close existing pool
        pctConfig = parcluster;
        pctConfig.NumWorkers = numLogicalCores;
        pctConfig.NumThreads = 1;  % Limit each worker to 1 thread
        parpool(pctConfig, numLogicalCores);  % Start new pool with correct number of workers
    end
end



end