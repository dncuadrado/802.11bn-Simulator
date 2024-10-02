function parsave(Resultsfilepath, CSRWeighteddelay1)


% 
% DCFfilename = horzcat(Resultsfilepath,'/DCFdelay.mat');
% % save(DCFfilename,"DCFdelay");
% 
% 
% CSRNumPkfilename = horzcat(Resultsfilepath,'/CSRNumPkdelay.mat');
% % save(CSRNumPkfilename,"CSRNumPkdelay");
% 
% 
% CSROldPkfilename = horzcat(Resultsfilepath,'/CSROldPkdelay.mat');
% % save(CSROldPkfilename,"CSROldPkdelay");
% 
% 
% CSRWeightedfilename = horzcat(Resultsfilepath,'/CSRWeighteddelay.mat');
% % save(CSRWeightedfilename,"CSRWeighteddelay");

CSRWeighted1filename = horzcat(Resultsfilepath,'/CSRWeighteddelay1.mat');
save(CSRWeighted1filename,"CSRWeighteddelay1");


% CSRHybridfilename = horzcat(Resultsfilepath,'/CSRHybriddelay.mat');
% save(CSRHybridfilename,"CSRHybriddelay");



end
