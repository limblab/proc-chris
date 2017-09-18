%template script to load nev and nsx data into matlab using the
%ClassyDataAnalysis package:

%% establish input configuration for loading:
%     lab=6;
%     ranBy='ranByChris';
%     monkey='monkeyLando';
%     task='taskCOBump';
%     %note the .nev extension is not necessary when providing the file name:
%     fname='C:\Users\csv057\Documents\MATLAB\MonkeyData\Garbage\LoadCellTest004';
% 
% %% load data into cds:
%     %make blank cds class:
%     cds=commonDataStructure();
%     %load the data:
%     array='arrayS1';
%     %note the .nev extension is not necessary when providing the file name:
%     cds.file2cds(fname,lab,array,monkey,task,ranBy,'ignoreJumps')
%     % cds may be saved or passeclear alld as an output argument
%     %saving classes REQUIRES the 'v7.3' flag, or the command will fail silently
%     %and just save a tiny useless file
%         lab=6;
%     ranBy='ranByChris';
%     monkey='monkeyLando';
%     task='taskUnknown';
%     %note the .nev extension is not necessary when providing the file name:
%     fname='C:\Users\csv057\Documents\MATLAB\MonkeyData\RawData\Lando\20170511\Lando_20170511_SpindleStim_LeftS1_Unit91Brachialis_006';
% 
% %% load data into cds:
%     %make blank cds class:
%     %load the data:
%     array='arrayRightCuneate';
%     fname='C:\Users\csv057\Documents\MATLAB\MonkeyData\RawData\Lando\20170511\Lando_20170511_SpindleStim_RightCuneate_Unit91Brachialis_006';
% 
%     cds.file2cds(fname,lab,array,monkey,task,ranBy,'ignoreJumps')

%% import data from cds to experiment:
    %make a blank experiment:
%     loadOpenSimData(cds, 'C:\Users\csv057\Documents\MATLAB\MonkeyData\Motion Tracking\20170903', 'muscle_len')
%     loadOpenSimData(cds, 'C:\Users\csv057\Documents\MATLAB\MonkeyData\Motion Tracking\20170903', 'muscle_vel')
%     loadOpenSimData(cds, 'C:\Users\csv057\Documents\MATLAB\MonkeyData\Motion Tracking\20170903', 'joint_ang')
%     loadOpenSimData(cds, 'C:\Users\csv057\Documents\MATLAB\MonkeyData\Motion Tracking\20170903', 'joint_vel')
    ex=experiment();
    %configure the parameters we want to load into the experiment:
%     ex.meta.hasLfp=true;
%     ex.meta.hasKinematics=true;
%     ex.meta.hasForce=true;
    ex.meta.hasUnits=true;
%     ex.meta.hasTrials=true;
    ex.meta.hasEmg = true;
    ex.meta.hasAnalog = true;
    %load data from cds to experiment
    ex.addSession(cds2)
%% change the units if you want to:
    %ex.units.deleteInvalid
    %ex.units.removeSorting
%% set configuration parameters for computing firing rate:
    ex.firingRateConfig.cropType='tightCrop';
    ex.firingRateConfig.offset=-0;
    ex.emg.processDefault;
    %ex.firingRateConfig.lags=[-2 3];
    %firing rate may be computed directely by using ex.calcFR, or will be
    %computed on the fly when ex.binData is called
    
%% configure bin parameters:
    % set binConfig parameters:
    ex.binConfig.include(1).field='units';
    ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
    ex.binConfig.include(2).field = 'analog';
%     ex.binConfig.include(3).field = 'kin';
%     ex.binConfig.include(4).field = 'force';
%     ex.binConfig.include(5).field = 'emg';
        
%% bin the data:
    ex.binData()
        
%% configure PD parameters:    
    %set which PD types to compute:
    ex.bin.pdConfig.pos=true;
    ex.bin.pdConfig.vel=true;
    ex.bin.pdConfig.force=true;
    ex.bin.pdConfig.speed=true;
    %establish which units to compute PD for
    ex.bin.pdConfig.units={};%just use all of them
    
    ex.bin.pdConfig.bootstrapReps=50;
    %establish time windows to use for PD computation. I'm using the 125ms
    %following bump onset here:
    abortMask=true(size(ex.trials.data,1),1);
    abortMask(strmatch('A',ex.trials.data.result,'exact'))=false;
%     bumpTrials=~isnan(ex.trials.data.bumpTime) & abortMask;
    rewardTrials = ex.trials.data.result == 'R';
    %windows are a nx2 column matrix of (start,end) time pairs. PD will be
    %computed on data only within the specified windows. If the
    %ex.bin.pdConfig.windows parameter is left empty, then all data will be
    %used
    window1 = [[ex.trials.data.bumpTime], [ex.trials.data.bumpTime]+.1];
    ex.bin.pdConfig.windows= window1;
%% calculate the PD
    ex.bin.fitPds
    %the experiment automatically catches the fitPds operation and copies
    %the data in ex.bin.pdData into ex.analysis(end+1).data. This lets you
    %run serial analyses with the data all saved in ex.analysis. We do
    %still need to add a label to tell us what the analysis was later on:
    ex.analysis(end).notes='All PDs during Bumps';


