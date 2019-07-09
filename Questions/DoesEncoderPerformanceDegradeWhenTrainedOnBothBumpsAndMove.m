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
           18 2 18 2;...
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
           72 1 72 1; ...
           74 1 74 1;...
           76 1 76 1];
       
monkey = 'Butter';
date = '20180530';
array = 'cuneate';
task = 'COmoveBump';
params.doCuneate = true;
if strcmp(date, '20180607')
    centerHold = true;
else
    centerHold = false;
end
mappingLog = getSensoryMappings(monkey);
if ~exist('tdStart') | ~strcmp(date, tdStart(1).date)
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

if centerHold
    tdButter1 = tdButter(isnan([tdButter.idx_bumpTime]));
    tdButter1 = trimTD(tdButter1, {'idx_movement_on',0}, {'idx_movement_on', 13});
    tdButter2 = tdButter(~isnan([tdButter.idx_bumpTime]));
    tdButter2 = trimTD(tdButter2, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
else
    tdButter1 = tdButter(isnan([tdButter.idx_bumpTime]));
    tdButter1 = trimTD(tdButter1, {'idx_goCueTime',50}, {'idx_goCueTime', 63});
    tdButter2 = tdButter(~isnan([tdButter.idx_bumpTime]));
    tdButter2 = trimTD(tdButter2, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
end

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
varsToUse = {{'pos';'vel';'acc';'speed';'force'}, ...
             {'vel';'acc';'speed'; 'force'},...
             {'pos';'speed';'acc'; 'force'},...
             {'pos';'vel';'speed';'force'},...
             {'pos';'vel';'acc';'speed'},...
             {'pos';'vel';'acc'; 'force'},...
             {'pos'},...
             {'vel'},...
             {'vel_hw'},...
             {'vel_fw'},...
             {'acc'},...
             {'force'},...
             {'speed'},...
             {'speed';'vel'},...
             {'pos';'vel';'acc';'vel_fw'; 'force'}};
         
               
     %%     
 guide = tdButter(1).cuneate_unit_guide;
     
for i = 1:length(varsToUse)
    disp(['Working on  ' strjoin(varsToUse{i})])
    params.in_signals= varsToUse{i};
    params.model_name = strjoin(varsToUse{i}, '_');
    modelNames{i} = strjoin(varsToUse{i}, '_');
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
    
    encVecCombo(i,:) = rownorm(modelCombo.b(2:end,:)');
    encVecOnly1(i,:) = rownorm(model1.b(2:end,:)');
    encVecOnly2(i,:) = rownorm(model2.b(2:end,:)');
    
end
%%
indList = [];
for i = 1:length(crList(:,1))
    if centerHold
    indList = [indList, find(guide(:,1) == crList(i,3) &...
        guide(:,2) == crList(i,4))];
    else
    indList = [indList, find(guide(:,1) == crList(i,1) &...
        guide(:,2) == crList(i,2))];
    end
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

figure
scatter(pr2Dif1(:,modelNum), pr2Dif2(:,modelNum),'filled')
xlabel('Change in PR2 in Bump ')
ylabel('Change in PR2 in Move ')
if centerHold
    title('Model Degradation (Center-hold + Reach)')
else
    title('Model Degradation (Reach Bumps + Reach)')
end
set(gca,'TickDir','out', 'box', 'off')

figure
scatter(meanCV1(:,modelNum), pr2Only1Temp(:,modelNum))


figure;
subplot(4, 1,1)
histogram(pr2Only1Temp(:,modelNum), 0:.05:1)
title('Move Trained on Move')
subplot(4, 1,2)
histogram(pr2Only2Temp(:,modelNum), 0:.05:1)
title('Bump Trained on Bump')
subplot(4, 1,3)
histogram(pr2Combo1Temp(:,modelNum), 0:.05:1)
title('Move Trained on Both')
subplot(4, 1,4)
histogram(pr2Combo2Temp(:,modelNum), 0:.05:1)
title('Bump Trained on Both')

figure;
scatter(pr2Combo1Temp(:,modelNum), pr2Only1Temp(:,modelNum), 'b', 'filled')
hold on
scatter(pr2Combo2Temp(:,modelNum), pr2Only2Temp(:,modelNum), 'r', 'filled')
for i = 1:length(crList)
    dx = -0.01; dy = 0.01; % displacement so the text does not overlay the data points
    text(pr2Combo1Temp(i,modelNum)+ dx, pr2Only1Temp(i,modelNum) +dy, [num2str(crList(i,3)), ' ', num2str(crList(i,4))]);
end
plot([0, 1], [0, 1], 'k-')
if centerHold
    title('Dual-context Accuracy vs. Single Context Accuracy (Center-hold + Reach)')
else
    title('Dual-context Accuracy vs. Single Context Accuracy (Reach Bumps + Reach)')
end
legend('Predicting Active', 'Predicting Passive')
xlabel('PR2 Dual-context')
ylabel('PR2 Single-context')
% xlim([0, 1])
% ylim([0, 1])
set(gca,'TickDir','out', 'box', 'off')

%%
pr2Deg1 = pr2Only1Temp(:,modelNum) - pr2Combo1Temp(:,modelNum);
encVecDif = encVecOnly1(modelNum,:) - encVecOnly2(modelNum,:);
figure
scatter(pr2Deg1, encVecDif(indList))
fitlm(pr2Deg1, encVecDif(indList))
%%
close all
numTrials = 20;
trials1 = randperm(length(tdButter1), numTrials);
trials2 = randperm(length(tdButter2), numTrials);

tdTrial1 = tdButter1(trials1);
tdTrial2 = tdButter2(trials2);
tdSplit1 = tdButter(1:length(tdButter1));
tdSplit2 = tdButter(length(tdButter1)+1:end);
tdSplit1 = tdSplit1(trials1);
tdSplit2 = tdSplit2(trials2);
unitNum = 8;
for i = 1
    varName = ['glm_', strjoin(varsToUse{i}, '_')];
    pred1 = cat(1, tdTrial1.(varName));
    act1 = cat(1, tdTrial1.cuneate_spikes);
    
    pred2 = cat(1, tdTrial2.(varName));
    act2 = cat(1, tdTrial2.cuneate_spikes);
    
    predDual1 = cat(1, tdSplit1.(varName));
    predDual2 = cat(1, tdSplit2.(varName));
    
    pred1 = pred1(:,indList);
    pred2 = pred2(:,indList);
    act1 = act1(:,indList);
    act2 = act2(:,indList);
    predDual1 = predDual1(:,indList);
    predDual2 = predDual2(:,indList);
    
    trialLen = length(tdTrial2(1).pos(:,1));
    
    figure
    plot(pred1(:,unitNum))
    hold on
    plot(predDual1(:,unitNum))
    plot(act1(:,unitNum))
    set(gca,'TickDir','out', 'box', 'off')
    title('Predictions of firing during Active Reaches')
    legend('Trained on only active', 'Trained on active/passive', 'Actual Firing')
    for j = 1:numTrials
        plot([(j-1)*trialLen, (j-1)*trialLen], [0, max([pred1(:,unitNum);act1(:,unitNum); predDual1(:,unitNum)])], '--','Color', [.75,.75,.75], 'HandleVisibility','off')
    end
    
    figure
    plot(pred2(:,unitNum))
    hold on
    plot(predDual2(:,unitNum))
    plot(act2(:,unitNum))

    set(gca,'TickDir','out', 'box', 'off')    
    title('Predictions firing during bumps')
    legend('Trained on only active', 'Trained on active/passive', 'Actual Firing')
    for j = 1:numTrials
        plot([(j-1)*trialLen, (j-1)*trialLen], [0, max([pred2(:,unitNum);act2(:,unitNum); predDual2(:,unitNum)])], '--', 'Color', [.75,.75,.75], 'HandleVisibility','off')
    end
end

%%
tdSplit1 = tdButter(1:length(tdButter1));
tdSplit2 = tdButter(length(tdButter1)+1:end);

varName = ['glm_', strjoin(varsToUse{1}, '_')];

act1 = cat(1, tdSplit1.cuneate_spikes);
act2 = cat(1, tdSplit2.cuneate_spikes);

predDual1 = cat(1, tdSplit1.(varName));
predDual2 = cat(1, tdSplit2.(varName));

activeError = predDual1 - act1;
passiveError = predDual2 - act2;

activeError = activeError(:,indList);
passiveError = passiveError(:,indList);
mActErr = mean(activeError);
mPasErr = mean(passiveError);

figure
scatter(mActErr, mPasErr)