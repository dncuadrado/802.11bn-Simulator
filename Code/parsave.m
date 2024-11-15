function    parsave(Resultsfilepath, DCFdelay, MNPdelay, OPdelay, ...
            TATdelay1, TATdelay2, TATdelay3, TATdelay4, TATdelay5, TATdelay6, TATdelay7, TATdelay8, TATdelay9, TATdelay10, TATdelay11, TATdelay12, ...
            Hybriddelay10, Hybriddelay20, Hybriddelay30, Hybriddelay40, Hybriddelay50, Hybriddelay60, Hybriddelay70, Hybriddelay80, Hybriddelay90)



DCFfilename = horzcat(Resultsfilepath,'/DCFdelay.mat');
save(DCFfilename,"DCFdelay");


MNPfilename = horzcat(Resultsfilepath,'/MNPdelay.mat');
save(MNPfilename,"MNPdelay");


OPfilename = horzcat(Resultsfilepath,'/OPdelay.mat');
save(OPfilename,"OPdelay");




TATfilename1 = horzcat(Resultsfilepath,'/TATdelay1.mat');
save(TATfilename1,"TATdelay1");

TATfilename2 = horzcat(Resultsfilepath,'/TATdelay2.mat');
save(TATfilename2,"TATdelay2");

TATfilename3 = horzcat(Resultsfilepath,'/TATdelay3.mat');
save(TATfilename3,"TATdelay3");

TATfilename4 = horzcat(Resultsfilepath,'/TATdelay4.mat');
save(TATfilename4,"TATdelay4");

TATfilename5 = horzcat(Resultsfilepath,'/TATdelay5.mat');
save(TATfilename5,"TATdelay5");

TATfilename6 = horzcat(Resultsfilepath,'/TATdelay6.mat');
save(TATfilename6,"TATdelay6");

TATfilename7 = horzcat(Resultsfilepath,'/TATdelay7.mat');
save(TATfilename7,"TATdelay7");

TATfilename8 = horzcat(Resultsfilepath,'/TATdelay8.mat');
save(TATfilename8,"TATdelay8");

TATfilename9 = horzcat(Resultsfilepath,'/TATdelay9.mat');
save(TATfilename9,"TATdelay9");

TATfilename10 = horzcat(Resultsfilepath,'/TATdelay10.mat');
save(TATfilename10,"TATdelay10");

TATfilename11 = horzcat(Resultsfilepath,'/TATdelay11.mat');
save(TATfilename11,"TATdelay11");

TATfilename12 = horzcat(Resultsfilepath,'/TATdelay12.mat');
save(TATfilename12,"TATdelay12");





Hybridfilename10 = horzcat(Resultsfilepath,'/Hybriddelay10.mat');
save(Hybridfilename10,"Hybriddelay10");

Hybridfilename20 = horzcat(Resultsfilepath,'/Hybriddelay20.mat');
save(Hybridfilename20,"Hybriddelay20");

Hybridfilename30 = horzcat(Resultsfilepath,'/Hybriddelay30.mat');
save(Hybridfilename30,"Hybriddelay30");

Hybridfilename40 = horzcat(Resultsfilepath,'/Hybriddelay40.mat');
save(Hybridfilename40,"Hybriddelay40");

Hybridfilename50 = horzcat(Resultsfilepath,'/Hybriddelay50.mat');
save(Hybridfilename50,"Hybriddelay50");

Hybridfilename60 = horzcat(Resultsfilepath,'/Hybriddelay60.mat');
save(Hybridfilename60,"Hybriddelay60");

Hybridfilename70 = horzcat(Resultsfilepath,'/Hybriddelay70.mat');
save(Hybridfilename70,"Hybriddelay70");

Hybridfilename80 = horzcat(Resultsfilepath,'/Hybriddelay80.mat');
save(Hybridfilename80,"Hybriddelay80");

Hybridfilename90 = horzcat(Resultsfilepath,'/Hybriddelay90.mat');
save(Hybridfilename90,"Hybriddelay90");





end