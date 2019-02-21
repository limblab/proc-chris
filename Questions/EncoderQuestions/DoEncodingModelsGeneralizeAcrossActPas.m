%% Load all files for comparison
clear
close all
% monkey = 'Lando';
% date = '20170223';
% array = 'LeftS1';
% task = 'RW';
% params.doCuneate = false;
% 
monkey = 'Crackle';
date = '20190213';
array = 'cuneate';
task = 'CO';
params.doCuneate = true;

mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, task);
% % tdButter = smoothSignals(tdButter, struct('signals', 'cuneate_spikes'));

%% Preprocess them (binning, trimming etc)
param.min_fr = 1;
tdButter= removeBadNeurons(tdButter, param);
tdButter = tdButter(getTDidx(tdButter, 'result','R'));   
tdButter = getNorm(tdButter,struct('signals','vel','norm_name','speed'));
tdButter = tdButter(~isnan([tdButter.idx_movement_on]));

tdBump = tdButter(~isnan([tdButter.bumpDir]));
tdButter = tdToBinSize(tdButter, 10);
tdBump = tdToBinSize(tdBump, 10);
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
tdButter = tdToBinSize(tdButter, 50);
tdBump = tdToBinSize(tdBump, 50);
%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';
param.glm_distribution = 'normal';

%% compute the GLMs and accuracies for move data
params.in_signals= {'vel'};
params.out_signals = [spikes];
params.model_name = 'Vel';
[tdButter, glmMove] = getModel(tdButter, params);
velPR2 = squeeze(evalModel(tdButter, params));
Vel = velPR2(sortedFlag& cunFlag)';
%% compute GLMs and accuracies for bump data
[tdBump, glmBump] = getModel(tdBump, params);
velPR2Bump = squeeze(evalModel(tdBump, params));
VelBump = velPR2Bump(sortedFlag&cunFlag)';

%% Cross condition encoding accuracy
tdBump = getModel(tdBump, glmMove);
velMove2BumpPR2 = squeeze(evalModel(tdBump, params));
velMove2BumpPR2 = velMove2BumpPR2(sortedFlag& cunFlag)';
tdMove = getModel(tdButter, glmBump);
velBump2MovePR2 = squeeze(evalModel(tdMove, params));
velBump2MovePR2 = velBump2MovePR2(sortedFlag &cunFlag)';

%% plotting
figure
h1 = histogram(VelBump,15);
hEdges1 = h1.BinEdges;
hold on
histogram(velMove2BumpPR2, hEdges1)
legend('Bump on Bump', 'Move on Bump')
title('PR2 of Bump Encoding Models')

figure
h2 = histogram(Vel,15);
hEdges2 = h2.BinEdges;
hold on
histogram(velBump2MovePR2, hEdges2)
legend('Move on Move', 'Move on Bump')
title('PR2 of Move Encoding Models')

figure
scatter(VelBump, velMove2BumpPR2)
xlabel('Bump PR2')
ylabel('Move to Bump PR2')
title('PR2 of neurons in passive case')
% xlim([0,1])
% ylim([0,1])
set(gca,'TickDir','out', 'box', 'off')


figure
scatter(Vel, velBump2MovePR2)
title('PR2 of neurons in active case')
xlabel('Move PR2')
ylabel('Bump to Move PR2')
% xlim([0,1])
% ylim([0,1])
set(gca,'TickDir','out', 'box', 'off')


figure
histogram(velBump2MovePR2 - Vel)
title('Active movements PR2 Diff')

figure
histogram(velMove2BumpPR2 - VelBump)
title('Passive movements PR2 Diff')

