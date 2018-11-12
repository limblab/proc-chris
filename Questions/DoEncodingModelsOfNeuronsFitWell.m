%% Load all files for comparison
clear
% monkey = 'Lando';
% date = '20170223';
% array = 'LeftS1';
% task = 'RW';
% params.doCuneate = false;
% 
monkey = 'Butter';
date = '20180607';
array = 'cuneate';
task = 'CO';
params.doCuneate = true;

mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, task);
tdButter = smoothSignals(tdButter, struct('signals', 'cuneate_spikes'));

%% Preprocess them (binning, trimming etc)
param.min_fr = 1;
tdButter= removeBadNeurons(tdButter, param);
tdButter = tdButter(getTDidx(tdButter, 'result','R'));   
% tdButter = getRWMovements(tdButter);

tdButter = getSpeed(tdButter);
% tdButter= removeBadTrials(tdButter);
tdButter = trimTD(tdButter, 'idx_movement_on', 'idx_endTime');
tdButter= binTD(tdButter, 5);
% tdButter= removeBadTrials(tdButter);
tdButter(isnan([tdButter.idx_endTime])) =[];
tdButter([tdButter.idx_endTime] ==1) = [];
butterNaming = tdButter.([array, '_unit_guide']);
sortedFlag = butterNaming(:,2) ~= 0;
[tdButter, cunFlag] = getTDCuneate(tdButter, params);
%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';

params.in_signals= {'pos';'vel';'speed'};
params.model_name = 'Full';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'vel';'speed'};
params.model_name = 'FullMinusPos';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusPos = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos';'speed'};
params.model_name = 'FullMinusVel';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusVel = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos';'vel';'speed'};
params.model_name = 'FullMinusForce';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusForce = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos';'vel'};
params.model_name = 'FullMinusSpeed';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusSpeed = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos'};
params.model_name = 'Pos';
tdButter= getModel(tdButter, params);
posPR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'vel'};
params.model_name = 'Vel';
tdButter= getModel(tdButter, params);
velPR2 = squeeze(evalModel(tdButter, params));
% 
% params.in_signals= {'force'};
% params.model_name = 'Force';
% tdButter= getModel(tdButter, params);
% forcePR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'speed'};
params.model_name = 'Speed';
tdButter= getModel(tdButter, params);
speedPR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'speed', 'vel'};
params.model_name = 'VelSpeed';
tdButter= getModel(tdButter, params);
velSpeedPR2 = squeeze(evalModel(tdButter, params));
%%
Full = squeeze(fullPR2(sortedFlag & cunFlag))';
FullMinusPos = fullPR2minusPos(sortedFlag& cunFlag);
FullMinusVel = fullPR2minusVel(sortedFlag& cunFlag);
FullMinusForce = fullPR2minusForce(sortedFlag& cunFlag);
FullMinusSpeed = fullPR2minusSpeed(sortedFlag& cunFlag);
Vel = velPR2(sortedFlag& cunFlag)';
Pos = posPR2(sortedFlag& cunFlag)';
% Force = forcePR2(sortedFlag& cunFlag)';
Speed = speedPR2(sortedFlag& cunFlag)';
VelSpeed = velSpeedPR2(sortedFlag& cunFlag)';

%% Compute the relative R2 between the combined speed velocity model and the model with just one or the other.
% the removal which causes the model to suffer 
params.model_name = {'Speed', 'VelSpeed'};
relSpeedR2 = evalModel(tdButter, params);
params.model_name = {'Vel', 'VelSpeed'};
relVelR2 = evalModel(tdButter, params);

figure;h = histogram(relSpeedR2,20);hold on;edges = h.BinEdges; histogram(relVelR2,edges);legend({'AddingVelocity', 'AddingSpeed'});ylabel('# of neurons');xlabel('RelativeR2');
title([monkey, ' ', array, ' Relative R2 gained by adding other model parameter'])

% This plot shows that the Vel model gains more from the addition of speed
% than the speed model does from the addition of velocity.
%% Plotting R2s to inspect how they look
butterR2table = table(Full, Pos, Vel, Speed, VelSpeed);

figure
scatter(butterR2table.Speed, butterR2table.Vel)
hold on
xlim([0, .8])
ylim([0,.8])
title([monkey, ' ', array, ' R2 for speed/vel models'])
xlabel('SpeedR2')
ylabel('Vel R2')
set(gca,'TickDir','out', 'box', 'off')

%%
figure
subplot(5,1,1)
histogram(Full,0:.05:1.0)
meanFull = sum(Full)/length(Full);
hold on
title('Full')
xlim([0, 1])
ylim([0,30])
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
scatter(meanFull, 20, '*r')

subplot(5,1,2)
histogram(Pos,0:.05:1.0)
meanPos = mean(Pos);
hold on
title('Position')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
xlim([0, 1])
ylim([0,30])
scatter(meanPos, 20, '*r')


subplot(5,1,3)
histogram(Vel,0:.05:1.0)
meanVel = mean(Vel);
hold on
title('Velocity')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
xlim([0, 1])
ylim([0,30])
scatter(meanVel, 20, '*r')

subplot(5,1,4)
histogram(Speed,0:.05:1.0)
meanSpeed = mean(Speed);
hold on
title('Speed')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
xlim([0, 1])
ylim([0,30])
scatter(meanSpeed, 20, '*r')

subplot(5,1,5)
histogram(VelSpeed,0:.05:1.0)
meanVelSpeed = mean(VelSpeed);
hold on
title('VelSpeed')
set(gca,'TickDir','out', 'box', 'off')
suptitle('R2 of Encoding Models')
xlabel('Pseudo R2')
ylabel('# of neurons')
xlim([0, 1])
ylim([0,30])
scatter(meanVelSpeed, 20, '*r')

%%
% close all
vec = 1:length(sortedFlag);
plotParams.array = 'LeftS1';
% for i = vec(sortedFlag)
%     plotParams.outputNum = i;
%     plotTDModelFits(tdButter, plotParams);
% end
% Moral of the story: Encoding models don't fit super well typically, but
% removing speed from the joint model hurts the prediction more than
% removing velocity (eg. the neurons care more about speed than the
% direction)
%%