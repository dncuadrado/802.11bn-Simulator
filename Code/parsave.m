function parsave(Resultsfilepath, DCFdelay, CSRNumPkdelay, CSROldPkdelay, CSRWeighteddelay)

DCFfilename = horzcat(Resultsfilepath,'/DCFdelay.mat');
save(DCFfilename,"DCFdelay");

CSRNumPkfilename = horzcat(Resultsfilepath,'/CSRNumPkdelay.mat');
save(CSRNumPkfilename,"CSRNumPkdelay");

CSROldPkfilename = horzcat(Resultsfilepath,'/CSROldPkdelay.mat');
save(CSROldPkfilename,"CSROldPkdelay");

CSRWeightedfilename = horzcat(Resultsfilepath,'/CSRWeighteddelay.mat');
save(CSRWeightedfilename,"CSRWeighteddelay");




end