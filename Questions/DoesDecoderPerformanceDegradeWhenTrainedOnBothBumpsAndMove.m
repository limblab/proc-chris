%% Load all files for comparison
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
task = 'COmoveBump';
params.doCuneate = true;

if strcmp(date, '20180607')
    centerHold = true;
else
    centerHold = false;
end
mappingLog = getSensoryMappings(monkey);
if ~exist('tdStart') | ~(datetime(date,'InputFormat', 'yyyyMMdd') == datetime(tdStart(1).date, 'InputFormat', 'MM-dd-yyyy')) 
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
    tdButter1 = trimTD(tdButter1, {'idx_movement_on',0}, {'idx_movement_on', floor(130/(tdButter(1).bin_size*1000))});
    tdButter2 = tdButter(~isnan([tdButter.idx_bumpTime]));
    tdButter2 = trimTD(tdButter2, {'idx_bumpTime', 0}, {'idx_bumpTime', floor(130/(tdButter(1).bin_size*1000))});
else
    tdButter1 = tdButter(isnan([tdButter.idx_bumpTime]));
    tdButter1 = trimTD(tdButter1, {'idx_goCueTime',floor(500/(tdButter(1).bin_size*1000))}, {'idx_goCueTime', floor(630/(tdButter(1).bin_size*1000))});
    tdButter2 = tdButter(~isnan([tdButter.idx_bumpTime]));
    tdButter2 = trimTD(tdButter2, {'idx_bumpTime', 0}, {'idx_bumpTime', floor(130/(tdButter(1).bin_size*1000))});
end
rand1 = randperm(length(tdButter1), length(tdButter2));
tdButter= [tdButter1(rand1), tdButter2];
tdButter1 = tdButter1(rand1);

dirsM = unique([tdButter2.target_direction]);
dirsB = unique([tdButter2.bumpDir]);
dirsM = sort(dirsM(~isnan(dirsM)));
dirsB = sort(dirsB(~isnan(dirsB)));

rbInds = zeros(4,4, length(tdButter2));
for i= 1:4
    for j= 1:4
        rbInds(i,j,find([tdButter2.target_direction] == dirsM(i) & [tdButter2.bumpDir] == dirsB(j))) =true; 
    end
end
rbInds = logical(rbInds);
% tdButter= removeBadTrials(tdButter);
% tdButter(isnan([tdButter.idx_endTime])) =[];
% tdButter([tdButter.idx_endTime] ==1) = [];
butterNaming = tdButter.([array, '_unit_guide']);
sortedFlag = butterNaming(:,2) ~= 0;
[tdButter, cunFlag] = getTDCuneate(tdButter);

%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'linmodel';
params.num_boots = 1;
params.eval_metric = 'r2';
params.glm_distribution= 'normal';
% params.glm_distribution
varsToUse = {{'vel'},...
             {'pos'},...
             {'acc'},...
             {'force'}};

               
     %%     
 guide = tdButter(1).cuneate_unit_guide;
     
for i = 1:length(varsToUse)
    disp(['Working on  ' strjoin(varsToUse{i})])
    params.out_signals= varsToUse{i};
    params.model_name = strjoin(varsToUse{i}, '_');
    modelNames{i} = [params.model_type,'_',strjoin(varsToUse{i}, '_')];
    params.in_signals = {spikes};
    
    [tdButter, modelCombo] = getModel(tdButter, params);
    cv(:,:,i) = getCVModelParams(tdButter1, params);
    tdButter1Split = getModel(tdButter1, modelCombo);
    tdButter2Split = getModel(tdButter2, modelCombo);
    
    pred1Combo{i} = cat(3, tdButter1Split.(modelNames{i}));
    pred2Combo{i} = cat(3, tdButter2Split.(modelNames{i}));
    act1{i} = cat(3, tdButter1Split.(varsToUse{i}{1}));
    act2{i} = cat(3, tdButter2Split.(varsToUse{i}{1}));
    
    
    pr2Combo1(i,:) = squeeze(evalModel(tdButter1Split, params));
    pr2Combo2(i,:) = squeeze(evalModel(tdButter2Split, params));
    
    [tdButter1, model1] = getModel(tdButter1, params);
    pred1Only{i} = cat(3, tdButter1.(modelNames{i}));
    pr2Only1(i,:) = squeeze(evalModel(tdButter1, params));
    
    
    [tdButter2, model2] = getModel(tdButter2, params);
    pred2Only{i} =cat(3, tdButter2.(modelNames{i}));
    pr2Only2(i,:) = squeeze(evalModel(tdButter2, params));
    
end
%%
indList = [];
for i = 1:length(crList(:,1))
    indList = [indList, find(guide(:,1) == crList(i,1) &...
        guide(:,2) == crList(i,2))];
end
%%
pr2Combo1Temp = pr2Combo1';
pr2Combo2Temp = pr2Combo2';

cv1 = squeeze(cv);
meanCV1 = squeeze(mean(cv1, 1));

pr2Only1Temp = pr2Only1';
pr2Only2Temp = pr2Only2';
pr2Dif1 = pr2Combo1Temp - pr2Only1Temp;
pr2Dif2 = pr2Combo2Temp - pr2Only2Temp;
%%
figure
scatter(meanCV1(:,1), pr2Only1Temp(:,1))
%%

figure;
subplot(4, 1,1)
histogram(pr2Only1Temp(:,1), 0:.05:1)
title('Move Trained on Move')
subplot(4, 1,2)
histogram(pr2Only2Temp(:,1), 0:.05:1)
title('Bump Trained on Bump')
subplot(4, 1,3)
histogram(pr2Combo1Temp(:,1), 0:.05:1)
title('Move Trained on Both')
subplot(4, 1,4)
histogram(pr2Combo2Temp(:,1), 0:.05:1)
title('Bump Trained on Both')
%%
figure
hold on
colors = linspecer(length(pr2Only1Temp(1,:)));
bColors = colors.^(.4);
for i = 1:length(pr2Only1Temp(1,:)) 
    scatter(pr2Combo1Temp(:,i), pr2Only1Temp(:,i),36, colors(i,:),'Filled')
    scatter(pr2Combo2Temp(:,i), pr2Only2Temp(:,i),36, colors(i,:))
end
plot([0, 1], [0, 1], 'k-')
title('Dual training set vs. single training set')
legend('Predicting Active', 'Predicting Passive')
xlabel('R2 Dual-context')
ylabel('R2 Single-context')

set(gca,'TickDir','out', 'box', 'off')

%%
close all
velCombo1 = pred1Combo{1};
velCombo2 = pred2Combo{1};
vel1Act = act1{1};
vel2Act = act2{1};
velOnly1 =pred1Only{1};
velOnly2 = pred2Only{1};

numTrials = 20;
trials1 = randperm(length(vel1Act(1,1,:)), numTrials);
trials2 = randperm(length(vel2Act(1,1,:)), numTrials);

velCombo1 = velCombo1(:,1,trials1);
velOnly1 = velOnly1(:,1, trials1);
vel1Act = vel1Act(:,1,trials1);

velCombo2 = velCombo2(:,1,trials1);
velOnly2 = velOnly2(:,1, trials1);
vel2Act = vel2Act(:,1,trials1);

trialLen = length(velCombo1(:,1,1));

figure2
plot(velCombo1(:))
hold on
plot(velOnly1(:))
plot(vel1Act(:))
for j = 1:numTrials
    plot([(j-1)*trialLen, (j-1)*trialLen], [min([velOnly1(:);vel1Act(:); velCombo1(:)]), max([velOnly1(:);vel1Act(:); velCombo1(:)])], '--', 'Color', [.75,.75,.75], 'HandleVisibility','off')
end
title('Active Reach Velocity predictions')
xlabel('Time (bins)')
ylabel('Velocity X (cm/s)')
legend('Trained on active/passive', 'Trained on active only', 'Actual Speed')
    set(gca,'TickDir','out', 'box', 'off')

figure2
plot(velCombo2(:))
hold on
plot(velOnly2(:))
plot(vel2Act(:))
for j = 1:numTrials
    plot([(j-1)*trialLen, (j-1)*trialLen], [min([velOnly2(:);vel2Act(:); velCombo2(:)]), max([velOnly2(:);vel2Act(:); velCombo2(:)])], '--', 'Color', [.75,.75,.75], 'HandleVisibility','off')
end
title('Bump Velocity predictions')
xlabel('Time (bins)')
ylabel('Velocity X (cm/s)')
legend('Trained on active/passive', 'Trained on passive only', 'Actual Speed')
set(gca,'TickDir','out', 'box', 'off')

%% 
close all
posCombo1 = pred1Combo{2};
posCombo2 = pred2Combo{2};
pos1Act = act1{2};
pos2Act = act2{2};
posOnly1 =pred1Only{2};
posOnly2 = pred2Only{2};

colors = linspecer(4);

    figure2
    hold on
for i = 1:4
    for j = 1:4
        posX = pos2Act(:, 1, rbInds(i,j,:));
        posY = pos2Act(:, 2, rbInds(i,j,:));
        scatter(posX(:), posY(:), 5, colors(j,:))
        
    end
end
title('Hand position during movement bumps')

    figure2
    hold on
for i = 1:4
    for j = 1:4
        posX = posCombo2(:, 1, rbInds(i,j,:));
        posY = posCombo2(:, 2, rbInds(i,j,:));
        scatter(posX(:), posY(:), 5, colors(j,:))
        
    end
end
title('Predicted hand position during movement Bumps using dual-context model')

    figure2
    hold on
for i = 1:4
    for j = 1:4
        posX = posOnly2(:, 1, rbInds(i,j,:));
        posY = posOnly2(:, 2, rbInds(i,j,:));
        if i == 1
            scatter(posX(:), posY(:), 5, colors(j,:))
        else
            scatter(posX(:), posY(:),5, colors(j,:), 'HandleVisibility', 'off')
        end
    end
end
leg = legend('Right', 'Up', 'Left', 'Down');
title('Predicted hand position during movement bumps using single-context model')
title(leg, 'Bump Direction')

velCombo1 = pred1Combo{1};
velCombo2 = pred2Combo{1};
vel1Act = act1{1};
vel2Act = act2{1};
velOnly1 =pred1Only{1};
velOnly2 = pred2Only{1};

colors = linspecer(4);


        figure2
    hold on
for i = 1:4
    for j = 1:4
        velX = vel2Act(:, 1, rbInds(i,j,:));
        velY = vel2Act(:, 2, rbInds(i,j,:));
        scatter(velX(:), velY(:), 5, colors(j,:))
        
    end
end
title('Hand velocity during movement bumps')


    figure2
    hold on
for i = 1:4
    for j = 1:4
        velX = velCombo2(:, 1, rbInds(i,j,:));
        velY = velCombo2(:, 2, rbInds(i,j,:));
        scatter(velX(:), velY(:), 5, colors(j,:))
        
    end
end
title('Predicted hand velocity during movement bumps using dual-context model')



    figure2
    hold on
for i = 1:4
    for j = 1:4
        velX = velOnly2(:, 1, rbInds(i,j,:));
        velY = velOnly2(:, 2, rbInds(i,j,:));
        if i == 1
            scatter(velX(:), velY(:), 5, colors(j,:))
        else
            scatter(velX(:), velY(:),5, colors(j,:), 'HandleVisibility', 'off')
        end
    end
end
leg = legend('Right', 'Up', 'Left', 'Down');
title(leg, 'Bump Direction')
title('Predicted hand velocity during movemetn bumps using single context model')
%%

for i = 1:4
    for j = 1:4
        if i == j
            velAssist(i) = mean(rownorm(mean(vel2Act(:,:, rbInds(i,i,:)),3)));
            velCombAssist(i) = mean(rownorm(mean(velCombo2(:,:,rbInds(i,i,:)),3)));
            velOnlyAssist(i) = mean(rownorm(mean(velOnly2(:,:,rbInds(i,i,:)),3)));

            
        elseif j == getResistive(i)
            velResist(i) = mean(rownorm(mean(vel2Act(:,:, rbInds(i,j,:)),3)));
            velCombResist(i) = mean(rownorm(mean(velCombo2(:,:,rbInds(i,j,:)),3)));
            velOnlyResist(i) = mean(rownorm(mean(velOnly2(:,:,rbInds(i,j,:)),3)));

        end
    end 
end
max1 = [velAssist, velResist, velCombAssist, velCombResist, velOnlyAssist, velOnlyResist];

colors = linspecer(4);
figure
plot([0, max(max1)], [0, max(max1)], 'k--', 'HandleVisibility', 'off') 
hold on
for i = 1:4
    scatter(velAssist(i), velResist(i), 64,  colors(i,:), 'o', 'filled', 'HandleVisibility', 'off')
    scatter(velCombAssist(i), velCombResist(i), 64,  colors(i,:), '+', 'HandleVisibility', 'off')
    scatter(velOnlyAssist(i), velOnlyResist(i), 64,  colors(i,:), '*', 'HandleVisibility', 'off')
end
set(gca,'TickDir','out', 'box', 'off')
title('Velocity predictions in assistive/resistive bumps')
xlabel('Assistive Bumps')
ylabel('Resistive Bumps')
for i = 1:4
    scatter([1,1],[10000,10000], 64, colors(i,:), 'o', 'filled')
end
scatter([1,2],[10000,10000],64, 'k', 'o', 'filled')
scatter([1,2],[10000,10000],64, 'k', '+')
scatter([1,2],[10000,10000], 64, 'k', '*')
xlim([0, max(max1)])
ylim([0,max(max1)])

leg = {'Right', 'Up', 'Left', 'Down', 'Actual', 'Dual-Context', 'Single-Context'};
legend(leg)

%%
function out = getResistive(ind)
    switch ind
        case 1
            out = 3;
        case 2
            out = 4;
        case 3
            out = 1;
        case 4
            out = 2;
    end
end
%%
