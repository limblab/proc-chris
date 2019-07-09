% Load all files for comparison
clearvars -except tdStart
% monkey = 'Lando';
% date = '20170223';
% array = 'LeftS1';
% task = 'RW';
% params.doCuneate = false;
% 
crList =  [1 2 1 2; ...
           2 1 2 1;...
           3 1 3 1;...
           11 1 11 1; ...
           12 1 12 1;...
           14 1 14 1; ...
           16 1 16 1;...
           17 1 17 1;...
           18 1 18 1;...
           18 2 18 3;...
           20 1 20 1; ...
           20 2 20 2; ...
           22 1 22 1; ...
           22 2 22 2; ...
           23 1 23 1; ...
           24 2 24 2; ...
           24 3 24 3; ...
           27 1 27 1; ...
           27 2 27 2; ...
           33 1 33 1; ...
           36 1 36 1; ...
           38 1 38 1; ...
           40 1 40 1; ...
           41 1 41 1;...
           42 1 42 1; ...
           45 1 45 1; ...
           50 1 50 1; ...
           62 1 62 1; ...
           67 1 67 1; ...
           72 1 72 2; ...
           74 1 74 1;...
           76 1 76 1];
       
monkey = 'Butter';
date = '20180530';
array = 'cuneate';
task = 'COmovebump';
params.doCuneate = true;
powersToTest = [.1:.05:1];
mappingLog = getSensoryMappings(monkey);
if ~exist('tdStart')
    tdStart =getTD(monkey, date, task,1);
    tdStart = tdToBinSize(tdStart, 10);
end
tdButter = smoothSignals(tdStart, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));

tdButter = getNorm(tdButter,struct('signals','vel','norm_name','speed'));

tdButter = getMoveOnsetAndPeak(tdButter);
% getGracile
% tdButter = smoothSignals(tdButter, struct('signals', 'cuneate_spikes'));

%% Preprocess them (binning, trimming etc)
param.min_fr = 1;
% tdButter= removeBadNeurons(tdButter, param);
tdButter = removeUnsorted(tdButter);
tdButter = tdButter(getTDidx(tdButter, 'result','R'));   
% tdButter = getRWMovements(tdButter);


% tdButter= removeBadTrials(tdButter);
tdButter = tdButter(~isnan([tdButter.idx_movement_on]));
tdButter = tdToBinSize(tdButter, 10);


tdButter = rectifyTDSignal(tdButter, struct('signals', 'vel'));
tdButter = rectifyTDSignal(tdButter, struct('signals', 'vel','rect_type', 'hw'));


[tdButter, field_names] = getPowerTD(tdButter, struct('signals', 'vel', 'powers', powersToTest));


tdButter1 = trimTD(tdButter, {'idx_movement_on',0}, {'idx_movement_on', 13});
tdButter2 = tdButter(~isnan([tdButter.idx_bumpTime]));
tdButter2 = trimTD(tdButter2, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
rand1 = randperm(length(tdButter1), length(tdButter2));
tdButter= [tdButter1(rand1), tdButter2];
tdButter1 = tdButter1(rand1);
% tdButter= removeBadTrials(tdButter);
% tdButter(isnan([tdButter.idx_endTime])) =[];
% tdButter([tdButter.idx_endTime] ==1) = [];
butterNaming = tdButter.([array, '_unit_guide']);
sortedFlag = butterNaming(:,2) ~= 0;
% [tdButter, cunFlag] = getTDCuneate(tdButter);

%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';
% params.glm_distribution
         
               
     %%     
 guide = tdButter(1).cuneate_unit_guide;
     
for i = 1:length(field_names)
    disp(['Working on  ', field_names{i}])
    params.in_signals= field_names{i};
    params.model_name = field_names{i};
    modelNames{i} = field_names{i};
    params.out_signals = {spikes};
    
    [tdButter, modelCombo] = getModel(tdButter, params);
    cv(:,:,i) = getCVModelParams(tdButter1, params);
    tdButter1 = getModel(tdButter1, modelCombo);
    tdButter2 = getModel(tdButter2, modelCombo);
    
    pr2Combo1(i,:) = squeeze(evalModel(tdButter1, params));
    pr2Combo2(i,:) = squeeze(evalModel(tdButter2, params));
    
    [tdButter1, model1] = getModel(tdButter1, params);
    pr2Only1(i,:) = squeeze(evalModel(tdButter1, params));
    
    [tdButter2, model2] = getModel(tdButter2, params);
    pr2Only2(i,:) = squeeze(evalModel(tdButter2, params));
    
end
%%
indList = [];
for i = 1:length(crList(:,1))
    indList = [indList, find(guide(:,1) == crList(i,1) &...
        guide(:,2) == crList(i,2))];
end
%%
close all
modelNum = 1;

pr2Combo1Temp = pr2Combo1(:,indList)';
pr2Combo2Temp = pr2Combo2(:,indList)';

cv1 = squeeze(cv(:, indList,:));
meanCV1 = squeeze(mean(cv1, 1));

pr2Only1Temp = pr2Only1(:, indList)';
pr2Only2Temp = pr2Only2(:,indList)';
pr2Dif1 = pr2Combo1Temp - pr2Only1Temp;
pr2Dif2 = pr2Combo2Temp - pr2Only2Temp;
%%
meanPR2Combo1=  mean(pr2Combo1Temp);
meanPR2Combo2 = mean(pr2Combo2Temp);
meanPR2Only1 = mean(pr2Only1Temp);
meanPR2Only2 = mean(pr2Only2Temp);

figure
plot(powersToTest, meanPR2Only1)
hold on
plot(powersToTest, meanPR2Only2)
title('Average encoding accuracy as a function of power law relationship')
xlabel('Power law coefficient')
ylabel('PR2 of GLM')
legend('Active', 'Passive')
set(gca,'TickDir','out', 'box', 'off')

figure
plot(powersToTest, pr2Only1Temp, 'b')
hold on
plot(powersToTest, pr2Only2Temp, 'r')
xlabel('Power law coefficient')
ylabel('PR2 of GLM')
legend('Active', 'Passive')
set(gca,'TickDir','out', 'box', 'off')

title('Encoding accuracy for each neuron as a function of power law relationship')
