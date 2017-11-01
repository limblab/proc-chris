clear all
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170728\Lando_RW_hold_20170728_001_TD.mat');

array = 'cuneate';

[tdIdx,td] = getTDidx(trial_data, 'result', 'R');
params.go_cue_name ='idx_goCueTime';
params.end_name = 'idx_endTime';
td_act = binTD(td, 5);
td_act = removeBadTrials(td_act);
td_act = removeBadNeurons(td_act);
td_act = getRWMovements(td_act, params);
td_act = removeBadTrials(td_act);
td_act = trimTD(td_act, 'idx_movement_on', 'idx_endTime');
td_act = getRWTargetDirection(td_act);


opensim_idx = find(contains(td_act(1).opensim_names,'_muscVel'));
signal_name = 'opensim';
num_boots = 100;
spikesPDtable_act = getTDPDs(td_act,struct('out_signals',{{[array, '_spikes']}},'out_signal_names',{td(1).([array, '_unit_guide'])},...
                                          'distribution','poisson','move_corr','vel','num_boots',num_boots));
%%
tuningCutoff = pi/4;
isTuned_params = struct('move_corr','vel','CIthresh',tuningCutoff);
isTuned = checkIsTuned(spikesPDtable_act,isTuned_params);
spikesPDtable_act.isTuned = isTuned;
tunedPDTable = spikesPDtable_act(isTuned, :);
h1 = figure;
title('Distribution of PDs during RW')
maxRad = max(tunedPDTable.velModdepth);
colors = linspecer(height(tunedPDTable));
       

polar(0, maxRad)
hold on
for i = 1:height(tunedPDTable)
    plotTuning([], tunedPDTable(i,:), [], tunedPDTable.velModdepth(i), colors(i,:), '-')
end

%%

% param.trials_to_plot= 1:50;
% param.trials = 1:50;
% visData(td_act, param)

spikingMat = cat(1, td_act.cuneate_spikes);
opensimMat = cat(1, td_act.opensim);

coeffs = genericPoissonGLM(spikingMat, opensimMat);
