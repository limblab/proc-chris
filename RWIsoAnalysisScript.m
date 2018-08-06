% clear all
% clear all
% clear all
% load('/media/chris/DataDisk/MonkeyData/RW/Butter/20180703/TD/Butter_RWIso_20180703_TD.mat')
% getSensoryMappings();
array = 'RightCuneate';
date = '20170125';
task= 'RWIso';
params.arrays = {'RightCuneate'};
% paramTD.include_ts = true;
% paramTD.include_start = true;
% trial_data = parseFileByTrial(cds, paramTD);
% %%
% [tdIdx,td] = getTDidx(trial_data, 'result', 'R');
params.go_cue_name ='idx_goCueTime';
params.end_name = 'idx_endTime';
params.do_onset = false;
% td1 = binTD(td, 5);
% td1 = removeBadTrials(td1);
% td1 = removeBadNeurons(td1);
td1 = getRWMovements(td, params);
td1 = removeBadTrials(td1);

params.useForce = true;
params.which_field = 'force';
params.min_ds        =  .1;
params.s_thresh      =  5;
td1 = getMoveOnsetAndPeak(td1, params);
td1 = removeBadTrials(td1);
params.windowAct = {'idx_movement_on', 0; 'idx_endTime', 0};

td_act = trimTD(td1, {'idx_movement_on', 0}, {'idx_endTime', 0});
params.in_signals      = 'force';
%%
params.doTrim = false;
[trialProcessed, neuronNew] = compiledRWAnalysis(td_act,params);
params.array = 'RightCuneate';
params.sinTuned= neuronNew.isTuned;
%%
neuronsRW = [neuronNew];
% neuronsRW = insertMappingsIntoNeuronStruct(neuronsRW,mappingLog);

saveNeurons(neuronsRW)
%%
actPDTable = neuronsRW(find(neuronsRW.isSorted & neuronsRW.isCuneate ),:).PD;
gracilePDTable = neuronsRW(find(neuronsRW.isSorted & neuronsRW.isGracile),:).PD;


fh1 = figure;
[~,~,~,tunedPDsCuneate] = plotForceTuningDist(actPDTable,fh1, 'k', pi/4);
fh2 = figure;
[~,~,~,tunedPDs] = plotForceTuningDist(gracilePDTable,fh2, 'r', pi/4);

meanDir = rad2deg(circ_mean(tunedPDs));
%% 
