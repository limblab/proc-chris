clear all
close all
monkey = 'Butter';
date = '20180405';
array = 'cuneate';
% monkey = 'Lando';
% date = '20170728';
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'RW');

getSensoryMappings(monkey);

td1 = removeBadTrials(td);
td1 = removeBadNeurons(td1);
param.windowAct = {'idx_movement_on'; 'idx_endTime'};
td_act = trimTD(td1, 'idx_movement_on', 'idx_endTime');
td_pas = trimTD(td1, 'idx_startTime', 'idx_movement_on');
tdPeak = trimTD(td1, 'idx_peak_speed', 'idx_peak_speed');
param.in_signals      = 'vel';
%% Find the neurons that best decode position

butterNaming = td1.([array, '_unit_guide']);
sortedFlag = butterNaming(:,2) ~= 0;
names = [td1(1).cuneate_unit_guide];

for i = 1:length(names)
    unitsToUse =i;

    params.model_type    =  'linmodel';
    params.model_name    =  'movementGLM';
    params.in_signals    =  {'cuneate_spikes', unitsToUse};% {'name',idx; 'name',idx};
    params.out_signals   =  {'pos'};% {'name',idx};
    params.train_idx     =  1:length(td1);
    % GLM-specific parameters
    params.glm_distribution     =  'normal';
    params.eval_metric      =  'r2';


    params.model_name    =  'activeModelVelPred';
    params.train_idx    = 1:length(td1);
    [trial_glm_move, model_info_move] = getModel(td1, params);
    r2_glm_move(i,:,:) = evalModel(trial_glm_move, params);
    disp(['Done: ', num2str(i), ' of ', num2str(length(names))])

end
%%
close all
[sorted, inds] = sort(mean(squeeze(mean(r2_glm_move,2)),2));

paramHeat.array = array;
paramHeat.unitsToPlot = inds;
paramHeat.numBounds = 6;
paramHeat.xLimits = [-10,10];
paramHeat.yLimits = [-42, -22];
paramHeat.useJointPCA = false;
paramHeat.plotError = false;
paramHeat.velocityCutoffHigh =5;

[f1, spikingInBounds, varInBounds] = neuralHeatmap(td1,paramHeat);