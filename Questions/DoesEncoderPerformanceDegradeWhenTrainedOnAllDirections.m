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
date = '20180607';
array = 'cuneate';
task = 'CO';
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
    tdButterNoRight = tdButter([tdButter.target_direction] ~= 0);
    tdButterNoRight = trimTD(tdButterNoRight, {'idx_movement_on',0}, {'idx_movement_on', 13});
    tdButterRight = tdButter([tdButter.target_direction] == 0);
    tdButterRight = trimTD(tdButterRight, {'idx_movement_on', 0}, {'idx_movement_on', 13});
end

rand1 = randperm(length(tdButterNoRight), length(tdButterRight));
tdButter= [tdButterNoRight(rand1), tdButterRight];
tdButterNoRight = tdButterNoRight(rand1);
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
    
    [tdButter, modelAllDirs] = getModel(tdButter, params);
    cv(:,:,i) = getCVModelParams(tdButterNoRight, params);
    tdButterNoRight = getModel(tdButterNoRight, modelAllDirs);
    tdButterRight = getModel(tdButterRight, modelAllDirs);
    
    pr2NoRightTrainedAll(i,:) = squeeze(evalModel(tdButterNoRight, params));
    pr2RightTrainedAll(i,:) = squeeze(evalModel(tdButterRight, params));
    
    [tdButterNoRight, modelNoRight] = getModel(tdButterNoRight, params);
    pr2NoRightTrainedNoRight(i,:) = squeeze(evalModel(tdButterNoRight, params));
    
    [tdButterRight, modelRight] = getModel(tdButterRight, params);
    pr2RightTrainedRight(i,:) = squeeze(evalModel(tdButterRight, params));
    
    encVecAllDirs(i,:) = rownorm(modelAllDirs.b(2:end,:)');
    encVecNoRight(i,:) = rownorm(modelNoRight.b(2:end,:)');
    encVecRight(i,:) = rownorm(modelRight.b(2:end,:)');
    
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

pr2NoRightTrainedAllTemp = pr2NoRightTrainedAll(:,indList)';
pr2RightTrainedAllTemp = pr2RightTrainedAll(:,indList)';

cv1 = squeeze(cv(:, indList,:));
meanCV1 = squeeze(mean(cv1, 1));

pr2NoRightTrainedNoRightTemp = pr2NoRightTrainedNoRight(:, indList)';
pr2RightTrainedRightTemp = pr2RightTrainedRight(:,indList)';

pr2Dif1 = pr2NoRightTrainedAllTemp - pr2NoRightTrainedNoRightTemp;
pr2Dif2 = pr2RightTrainedAllTemp - pr2RightTrainedRightTemp;

figure
scatter(pr2Dif1(:,modelNum), pr2Dif2(:,modelNum),'filled')
xlabel('Change in PR2 in Bump ')
ylabel('Change in PR2 in Move ')
if centerHold
    title('Model Degradation by including all directions')
else
    title('Model Degradation (Reach Bumps + Reach)')
end
set(gca,'TickDir','out', 'box', 'off')

figure
scatter(meanCV1(:,modelNum), pr2NoRightTrainedNoRightTemp(:,modelNum))


figure;
subplot(4, 1,1)
histogram(pr2NoRightTrainedNoRightTemp(:,modelNum), 0:.05:1)
title('No Right Trained on No Right Reach')
subplot(4, 1,2)
histogram(pr2RightTrainedRightTemp(:,modelNum), 0:.05:1)
title('Right Trained on Right Reach')
subplot(4, 1,3)
histogram(pr2NoRightTrainedAllTemp(:,modelNum), 0:.05:1)
title('No Right Trained on All')
subplot(4, 1,4)
histogram(pr2RightTrainedAllTemp(:,modelNum), 0:.05:1)
title('Right Trained on All')

figure;
scatter(pr2NoRightTrainedAllTemp(:,modelNum), pr2NoRightTrainedNoRightTemp(:,modelNum), 'b', 'filled')
hold on
scatter(pr2RightTrainedAllTemp(:,modelNum), pr2RightTrainedRightTemp(:,modelNum), 'r', 'filled')
for i = 1:length(crList)
    dx = -0.01; dy = 0.01; % displacement so the text does not overlay the data points
    text(pr2NoRightTrainedAllTemp(i,modelNum)+ dx, pr2NoRightTrainedNoRightTemp(i,modelNum) +dy, [num2str(crList(i,3)), ' ', num2str(crList(i,4))]);
end
plot([0, 1], [0, 1], 'k-')
if centerHold
    title('Single context Accuracy vs. Dual-Context Accuracy (Right and NonRight Trained)')
end
legend('Predicting Non-Right Reaches', 'Predicting Right Reaches')
xlabel('PR2 Trained on All Directions')
ylabel('PR2 Trained on Single Context (Right or Non-Right)')
% xlim([0, 1])
% ylim([0, 1])
set(gca,'TickDir','out', 'box', 'off')

%%
pr2Deg1 = pr2NoRightTrainedNoRightTemp(:,modelNum) - pr2NoRightTrainedAllTemp(:,modelNum);
encVecDif = encVecNoRight(modelNum,:) - encVecRight(modelNum,:);
figure
scatter(pr2Deg1, encVecDif(indList))
fitlm(pr2Deg1, encVecDif(indList))
%%
close all
numTrials = 20;
trials1 = randperm(length(tdButterNoRight), numTrials);
trials2 = randperm(length(tdButterRight), numTrials);

tdTrial1 = tdButterNoRight(trials1);
tdTrial2 = tdButterRight(trials2);
tdSplit1 = tdButter(1:length(tdButterNoRight));
tdSplit2 = tdButter(length(tdButterNoRight)+1:end);
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
tdSplit1 = tdButter(1:length(tdButterNoRight));
tdSplit2 = tdButter(length(tdButterNoRight)+1:end);

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