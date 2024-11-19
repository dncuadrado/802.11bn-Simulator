function SavingDuetoParfor(i,traffic_type, traffic_load, simDCF, simMNP, simOP, simTAT8)

    Resultsfilepath = horzcat('mysims/',traffic_type, '/', traffic_load, '/Deployment', int2str(i));
    if ~exist(Resultsfilepath, 'dir')
        mkdir(Resultsfilepath);
    end
    save(horzcat(Resultsfilepath, '/simDCF.mat'), 'simDCF');
    save(horzcat(Resultsfilepath, '/simMNP.mat'), 'simMNP');
    save(horzcat(Resultsfilepath, '/simOP.mat'), 'simOP');
    save(horzcat(Resultsfilepath, '/simTAT8.mat'), 'simTAT8');
end