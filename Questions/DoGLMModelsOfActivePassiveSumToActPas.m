%% Basic parameter setup
close all
clear all
plotRasters = 1;
savePlots = 1;
savePDF = true;
%% File parameters
date = '20180530';
monkey = 'Butter';
unitNames= 'cuneate';
%% Load the TDs
td1 =getTD(monkey, date, 'COmoveBump',1);
td2 = getTD(monkey, '20180607','CO',1);
%% Load the Neuron structs
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\neuronStruct\Butter_20180607_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons2 = neurons;
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180530\neuronStruct\Butter_20180530_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons1 = neurons;
clear neurons;
%% Compute the neuron matching
% crList= findMatchingNeurons(neurons1, neurons2);
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
           
           
           
%% Compute the bump effect and move effect from 0607
td1 = getNorm(td1,struct('signals','vel','field_extra','speed'));
td2 = getNorm(td2,struct('signals','vel','field_extra','speed'));

td1 = tdToBinSize(td1, 10);
td2 = tdToBinSize(td2,10);

td1 = smoothSignals(td1, struct('signals', ['cuneate_spikes']));
td2 = smoothSignals(td2, struct('signals', ['cuneate_spikes']));



td2 = getMoveOnsetAndPeak(td2);
td1 = getMoveOnsetAndPeak(td1);

preMove = trimTD(td2, {'idx_goCueTime', -10}, {'idx_goCueTime', -5});
preMoveVel = cat(3, preMove.vel);
premoveSpeed = rownorm(squeeze(preMoveVel(1, :, :))');
tdMove2= trimTD(td2, {'idx_goCueTime',50}, {'idx_goCueTime', 63});
moveVel = cat(3, tdMove2.vel);
moveSpeed = rownorm(squeeze(moveVel(1,:,:))');
tdBump2= td2(~isnan([td2.idx_bumpTime]));
tdBump2 = trimTD(tdBump2, 'idx_bumpTime', {'idx_bumpTime', 13});
tdBump2 = removeUnsorted(tdBump2);
tdMove2 = removeUnsorted(tdMove2); 
td1 = removeUnsorted(td1);
td1 = smoothSignals(td1, struct('signals', 'cuneate_spikes'));

td1 = trimTD(td1, {'idx_goCueTime', 50}, {'idx_goCueTime', 63});


dirsM = unique([tdMove2.target_direction]);
dirsB = unique([tdBump2.bumpDir]);
dirsM = dirsM(~isnan(dirsM));
dirsB = dirsB(~isnan(dirsB));

%% Fit GLMs on movement portion
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';
params.in_signals= {'vel'};
params.model_name = 'Full';
params.out_signals = 'cuneate_spikes';
[tdMove2, modelMove] = getModel(tdMove2, params);
fullPR2 = squeeze(evalModel(tdMove2, params));

[tdBump2, modelBump] = getModel(tdBump2, params);
fullPRBump2 = squeeze(evalModel(tdBump2, params));

for i= 1:length(dirsM)
    tdDir{i} = td1([td1.target_direction] == dirsM(i));
end
%%
for i = 1:length(dirsM)
    [tdDir{i}, modelBump1{i}] = getModel(tdDir{i}, params);
    for j = 1:length(dirsM)
        tdDir{j} = getModel(tdDir{j}, modelBump1{i});
        pr2(i,j,:) = squeeze(evalModel(tdDir{j}, params));
    end
end
%%
for i =1:length(pr2(1,1,:))
    meanPR2(i) = mean(diag(pr2(:,:,i)));
    nondiag = ~logical(eye(4,4));
    temp = squeeze(pr2(:,:,i));
    temp(temp == Inf | temp == -Inf) = -1;
    meanGen(i) = mean(temp(nondiag));
    
end
%%
figure
histogram(meanPR2,-.5:.03:.5)
hold on
histogram(meanGen, -.5:.03:.5)
xlim([-.5, .5])
title('Models of Bumps cannot generalize to other reach directions')
xlabel('Model PR2')
ylabel('# of units')
set(gca,'TickDir','out', 'box', 'off')

legend('Intra-reach', 'Inter-reach')