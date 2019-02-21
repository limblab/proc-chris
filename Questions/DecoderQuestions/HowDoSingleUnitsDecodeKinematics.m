clear all
close all
monkey = 'Crackle';
date = '20190213';
array = 'cuneate';
task = 'CO';
params.doCuneate = true;

mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, task);
tdButter = smoothSignals(tdButter, struct('signals', 'cuneate_spikes'));
%%
param.min_fr = 1;
tdButter= removeBadNeurons(tdButter, param);
tdButter = tdButter(getTDidx(tdButter, 'result','R'));   
tdButter = getSpeed(tdButter);
% tdButter= removeBadTrials(tdButter);
tdBump = tdButter(~isnan([tdButter.bumpDir]));
tdBump = trimTD(tdBump, 'idx_bumpTime', {'idx_bumpTime', 13});
% tdBump = binTD(tdBump, 5);

tdButter = trimTD(tdButter, 'idx_movement_on', {'idx_movement_on',13});

% tdButter= binTD(tdButter, 5);
% tdButter= removeBadTrials(tdButter);
% tdButter(isnan([tdButter.idx_endTime])) =[];
% tdButter([tdButter.idx_endTime] ==1) = [];
butterNaming = tdButter.([array, '_unit_guide']);
sortedFlag = butterNaming(:,2) ~= 0;
[tdButter, cunFlag] = getTDCuneate(tdButter, params);
tdMove= removeBadNeurons(tdButter);
names = [tdButter(1).cuneate_unit_guide];

for i = 1:length(names)
    unitsToUse =i;

    params.model_type    =  'linmodel';
    params.model_name    =  'movementGLM';
    params.in_signals    =  {'cuneate_spikes', unitsToUse};% {'name',idx; 'name',idx};
    params.out_signals   =  {'vel'};% {'name',idx};
    params.train_idx     =  1:length(tdBump);
    % GLM-specific parameters
    params.glm_distribution     =  'normal';
    
    params.model_name    =  'passiveModelVelPred';
    [trial_glm_bump, model_info_bump] = getModel(tdBump, params);
    [trial_glm_moveWBump] = getModel(tdMove, model_info_bump);
    params.model_name    =  'activeModelVelPred';
    params.train_idx    = 1:length(tdMove);
    [trial_glm_move, model_info_move] = getModel(tdMove, params);
    [trial_glm_bumpWMove] = getModel(tdBump, model_info_move);

    params.eval_metric      =  'r2';
    params.model_name    =  'passiveModelVelPred';
    r2_glm_bump(i,:,:) = evalModel(trial_glm_bump, params);
    r2_glm_moveWBump(i,:,:) = evalModel(trial_glm_moveWBump, params);
    params.model_name    =  'activeModelVelPred';
    r2_glm_move(i,:,:) = evalModel(trial_glm_move, params);
    r2_glm_bumpWMove(i,:,:) = evalModel(trial_glm_bumpWMove, params);

end
%     pause
%% R2 with single neurons
r2MeanBump =squeeze(mean(r2_glm_bump,3));
r2MeanMove = squeeze(mean(r2_glm_move,3));

figure
scatter(r2MeanBump(:,1), r2MeanBump(:,2),'Filled')
title('R2 of Bump X/Y velocity with single unit as input')
xlabel('R2 of Decoding X velocity')
ylabel('R2 of Decoding Y velocity')
axis square
set(gca,'TickDir','out', 'box', 'off')


figure
scatter(r2MeanMove(:,1), r2MeanMove(:,2), 'Filled') 
title('R2 of Move Velocity with single unit as input')
xlabel('R2 of Decoding X velocity')
ylabel('R2 of Decoding Y velocity')
axis square
set(gca,'TickDir','out', 'box', 'off')

