function [ ex ] = runExperiment( cds)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
ex=experiment();
    %configure the parameters we want to load into the experiment:
    ex.meta.hasLfp=false;
    ex.meta.hasKinematics=true;
    ex.meta.hasForce=true;
    ex.meta.hasUnits=true;
    ex.meta.hasTrials=true;
    %load data from cds to experiment
    ex.addSession(cds)
%% change the units if you want to:
    %ex.units.deleteInvalid
    %ex.units.removeSorting
%% set configuration parameters for computing firing rate:
    ex.firingRateConfig.cropType='tightCrop';
    ex.firingRateConfig.offset=-0;
    %ex.firingRateConfig.lags=[-2 3];
    %firing rate may be computed directely by using ex.calcFR, or will be
    %computed on the fly when ex.binData is called
    
%% configure bin parameters:
    % set binConfig parameters:
    ex.binConfig.include(1).field='units';
    ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
    ex.binConfig.include(2).field='kin';
        ex.binConfig.include(2).which={};%empty gets you all columns, a cell array of strings only pulls the columns with the specified labels
    ex.binConfig.include(3).field='force';
        ex.binConfig.include(3).which={};
        
%% bin the data:
    ex.binData()
        
%% configure PD parameters:    
    %set which PD types to compute:
    ex.bin.pdConfig.pos=true;
    ex.bin.pdConfig.vel=true;
    ex.bin.pdConfig.force=false;
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
    ex.bin.pdConfig.windows=[];
%% calculate the PD
    ex.bin.fitPds
    %the experiment automatically catches the fitPds operation and copies
    %the data in ex.bin.pdData into ex.analysis(end+1).data. This lets you
    %run serial analyses with the data all saved in ex.analysis. We do
    %still need to add a label to tell us what the analysis was later on:
    ex.analysis(end).notes='force PDs computed during bumps';


end

