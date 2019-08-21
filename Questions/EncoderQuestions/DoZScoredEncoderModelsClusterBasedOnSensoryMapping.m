% Load all files for comparison
clearvars -except tdStart
params.start_idx        =  'idx_goCueTime';
params.end_idx          =  'idx_endTime';
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
%%   
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
tdButter = getSpeed(tdButter);
tdButter = getMoveOnsetAndPeak(tdButter, params);
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
    tdButter1 = trimTD(tdButter1, {'idx_movement_on',0}, {'idx_endTime', 0});
else
    tdButter1 = tdButter(isnan([tdButter.idx_bumpTime]));
    tdButter1 = trimTD(tdButter1, {'idx_goCueTime',50}, {'idx_goCueTime', 63});
    tdButter2 = tdButter(~isnan([tdButter.idx_bumpTime]));
    tdButter2 = trimTD(tdButter2, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
end

tdButter1 = zscoreSignals(tdButter1, struct('signals', {{'pos', 'vel', 'vel_hw', 'vel_fw', 'acc', 'speed', 'force'}}));
%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';
% params.glm_distribution
varsToUse = {{'pos';'vel';'acc';'speed';'force'}};%, ...
%              {'vel';'acc';'speed'; 'force'},...
%              {'pos';'speed';'acc'; 'force'},...
%              {'pos';'vel';'speed';'force'},...
%              {'pos';'vel';'acc';'speed'},...
%              {'pos';'vel';'acc'; 'force'},...
%              {'pos'},...
%              {'vel'},...
%              {'vel_hw'},...
%              {'vel_fw'},...
%              {'acc'},...
%              {'force'},...
%              {'speed'},...
%              {'speed';'vel'},...
%              {'pos';'vel';'acc';'vel_fw'; 'force'}};
%          
               
     %%     
 guide = tdButter(1).cuneate_unit_guide;
     
for j = 1:length(varsToUse)
    disp(['Working on  ' strjoin(varsToUse{j})])
    params.in_signals= varsToUse{j};
    params.model_name = strjoin(varsToUse{j}, '_');
    modelNames{j} = strjoin(varsToUse{j}, '_');
    params.out_signals = {spikes};
    
    cv(:,:,j) = getCVModelParams(tdButter1, params);
    
    
    [tdButter1, model1{j}] = getModel(tdButter1, params);
    pr2Only1(j,:) = squeeze(evalModel(tdButter1, params));
    
    
end
%%
close all
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\neuronStruct\Butter_20180607_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')

dims = [1 2 3];
colors = linspecer(6);

neuronsInc = [];
sortedNeurons = neurons(logical([neurons.isSorted]),:);
indList = sortedNeurons.sameDayMap & sortedNeurons.isCuneate;
neuronsInc = sortedNeurons(indList,:);

pr2 = pr2Only1(:, indList);
b = model1{1}.b(:, indList);
b1 = b(2:end,:);
bN = normc(b1);
[pcs, v, latent, t2, exp, mu]  = pca(bN);

prop = logical(neuronsInc.proprio);
cut = logical(neuronsInc.cutaneous);
spindles = logical(neuronsInc.isSpindle);
proximal = logical(neuronsInc.proximal);
middle = logical(neuronsInc.midArm);
distal = logical(neuronsInc.distal);

figure2();
scatter3(pcs(prop,dims(1)), pcs(prop,dims(2)), pcs(prop,dims(3)), 16, colors(1,:),'filled')
hold on
scatter3(pcs(cut, dims(1)), pcs(cut,dims(2)), pcs(cut,dims(3)), 16, colors(2,:),'filled')
legend({'proprioceptive', 'cutaneous'})
axis equal
xlabel(['PC', num2str(dims(1))])
ylabel(['PC', num2str(dims(2))])
zlabel(['PC', num2str(dims(3))])
set(gca,'TickDir','out', 'box', 'off')

figure2();
scatter3(pcs(spindles, dims(1)), pcs(spindles,dims(2)), pcs(spindles,dims(3)), 16, colors(1,:),'filled')
hold on
scatter3(pcs(~spindles & prop, dims(1)), pcs(~spindles & prop, dims(2)), pcs(~spindles & prop,dims(3)), 16, colors(2,:),'filled')
legend('Spindles', 'Proprioceptive nonspindles')
axis equal
xlabel(['PC', num2str(dims(1))])
ylabel(['PC', num2str(dims(2))])
zlabel(['PC', num2str(dims(3))])
set(gca,'TickDir','out', 'box', 'off')

figure2();
scatter3(pcs(proximal,dims(1)), pcs(proximal, dims(2)), pcs(proximal,dims(3)), 16, colors(1,:),'filled')
hold on
scatter3(pcs(middle, dims(1)), pcs(middle,dims(2)), pcs(middle,dims(3)), 16, colors(2,:),'filled')
scatter3(pcs(distal, dims(1)), pcs(distal,dims(2)), pcs(distal,dims(3)), 16, colors(3,:),'filled')
axis equal
legend('proximal', 'midArm', 'distal')
xlabel(['PC', num2str(dims(1))])
ylabel(['PC', num2str(dims(2))])
zlabel(['PC', num2str(dims(3))])
set(gca,'TickDir','out', 'box', 'off')

%% Do LDA on weights to split these neuron classes by sensory mapping
numBoot = 100;
classVec = prop;
incVec = logical(ones(length(prop),1));

% groupA = spindles;
% groupB = prop;

% groupA = proximal;
% groupB = middle;
% groupC = distal;

% incVec = groupA | groupB | groupC;

% classVec = ~groupA(incVec) &  groupB(incVec);
% classVec = zeros(sum(incVec),1);
% classVec = classVec + groupB(incVec);
% classVec = classVec + 2*groupC(incVec);

bTemp = b(:, incVec);
bs = randi(sum(incVec),sum(incVec),numBoot);
for i = 1:numBoot
    disp(['Working on boot ', num2str(i)])
    classVec1 = classVec(bs(:, i));
    b3 = bTemp(:,bs(:,i));
for j = 1:length(classVec)
    b2 = b3(:, 1:end ~= j);
    classVec2 = classVec(1:end ~=j);
    mdl1 = fitcdiscr(b2', classVec2);
    pred2 = predict(mdl1, b3(:,j)');
    goodPred(i,j) = pred2 == classVec(j);
end

end
%%
acc1 = sort(sum(goodPred'))/length(classVec);
bootMean = bootci(100, @mean, acc1);
figure2();
histogram(acc1, 0:.05:1)
title('Mean performance in held-out set')
xlabel('Accuracy (%)')
ylabel('# of iterations')
set(gca,'TickDir','out', 'box', 'off')


