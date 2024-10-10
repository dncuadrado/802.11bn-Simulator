function parsave(Resultsfilepath, TATdelay)



DCFfilename = horzcat(Resultsfilepath,'/DCFdelay.mat');
save(DCFfilename,"DCFdelay");


MNPfilename = horzcat(Resultsfilepath,'/MNPdelay.mat');
save(MNPfilename,"MNPdelay");


OPfilename = horzcat(Resultsfilepath,'/OPdelay.mat');
save(OPfilename,"OPdelay");


TATfilename = horzcat(Resultsfilepath,'/TATdelay.mat');
save(TATfilename,"TATdelay");

TATfilename1 = horzcat(Resultsfilepath,'/TATdelay1.mat');
save(TATfilename1,"TATdelay1");


Hybridfilename = horzcat(Resultsfilepath,'/Hybriddelay.mat');
save(Hybridfilename,"Hybriddelay");



end
