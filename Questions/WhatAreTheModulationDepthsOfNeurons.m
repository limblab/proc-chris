%% Load all files for comparison
clear
monkey = 'Butter';
date = '20180405';
mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, 'RW');
%% Preprocess them (binning, trimming etc)
param.min_fr = 1;
tdButter= removeBadNeurons(tdButter, param);
tdButter = tdButter(getTDidx(tdButter, 'result','R'));   
tdButter = getRWMovements(tdButter);

tdButter = getSpeed(tdButter);
tdButter= removeBadTrials(tdButter);
% tdButter = trimTD(tdButter, 'idx_movement_on', 'idx_endTime');
tdButter= binTD(tdButter, 5);
% tdButter= removeBadTrials(tdButter);
% tdButter(isnan([tdButter.idx_endTime])) =[];
% tdButter([tdButter.idx_endTime] ==1) = [];
butterNaming = tdButter.cuneate_unit_guide;
sortedFlag = butterNaming(:,2) ~= 0;
[tdButter, cunFlag] = getTDCuneate(tdButter);
%% Compute the full models, and the pieces of the models
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';

params.in_signals= {'pos';'vel';'force';'speed'};
params.model_name = 'Full';
params.out_signals = {'cuneate_spikes'};
[tdButter, fullModel] = getModel(tdButter, params);
fullPR2 = squeeze(evalModel(tdButter, params));

%% 
close all
for i = 1:length(tdButter(1).glm_Full(1,:))
    x = fullModel.b(2:8,i)./norm(fullModel.b(2:8,i));
    xinv = -1*fullModel.b(2:8,i)./norm(fullModel.b(2:8,i));
    maxRate(i)= glmval(fullModel.b(:,i),x', 'log')/tdButter(1).bin_size;
    minRate(i) = glmval(fullModel.b(:,i),xinv', 'log')/tdButter(1).bin_size;
end
% histogram(maxRate)
% hold on
% histogram(minRate)
modDepth = maxRate-minRate;

figure
ax1 = axes('Position',[0 0 1 1],'Visible','off');
ax2 = axes('Position',[.15 .2 .8 .6]);
histogram(modDepth, 30)
title('Modulation Depths as determined by unit firing predicted by encoding model')
xlabel('Predicted Modulation depth (highest predicted firing-lowest predicted firing)')
ylabel('# of neurons')
axes(ax1)
text(.1,.1,{'Butter20180405RW'}, 'FontSize', 6)