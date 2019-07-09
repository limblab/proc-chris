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
td1 = removeUnsorted(td1);
td2 = removeUnsorted(td2);
td1 = removeGracileTD(td1);
td2 = removeGracileTD(td2);
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

td1 = getMoveOnsetAndPeak(td1);
td2 = getMoveOnsetAndPeak(td2);

td1NoBump = td1(isnan([td1.idx_bumpTime]));
td1NoBump= trimTD(td1NoBump, {'idx_movement_on',0}, {'idx_endTime',0});
td1Bump = td1(~isnan([td1.idx_bumpTime]));
td1Bump = trimTD(td1Bump, {'idx_bumpTime',0}, {'idx_bumpTime', 13});

td3Reach = td1NoBump([td1NoBump.target_direction] ~= 0);
td1Reach =td1NoBump([td1NoBump.target_direction] == 0);
%% Fit GLMs on movement portion
params.model_type = 'glm';
params.num_boots = 100;
params.eval_metric = 'pr2';
params.in_signals= {'vel'};
params.model_name = 'Full';
params.out_signals = 'cuneate_spikes';
[td1NoBump, modelMove] = getModel(td1NoBump, params);
td1Bump = getModel(td1Bump, modelMove);
fullPR2Intra = squeeze(evalModel(td1NoBump,params)); 
fullPR2Gen = squeeze(evalModel(td1Bump, params));

%%
params.model_type = 'glm';
params.num_boots = 100;
params.eval_metric = 'pr2';
params.in_signals= {'vel'};
params.model_name = 'Full';
params.out_signals = 'cuneate_spikes';
[td3Reach, model3Reach] = getModel(td3Reach, params);
td1Reach = getModel(td1Reach, model3Reach);
fullPR2ReachIntra = squeeze(evalModel(td3Reach,params)); 
fullPR2ReachGen = squeeze(evalModel(td1Reach, params));
%%
figure
histogram(mean(fullPR2Intra,2),-.5:.03:1)
hold on
histogram(mean(fullPR2Gen,2), -.5:.03:1)
xlim([-.5, 1])
title('Models Trained on Reaching can''t predict Bumps well')
xlabel('Model PR2')
ylabel('# of units')
set(gca,'TickDir','out', 'box', 'off')

legend('Reach Predictions', 'Bump Predictions')
%%
figure
histogram(mean(fullPR2ReachIntra,2),-.5:.03:1)
hold on
histogram(mean(fullPR2ReachGen,2), -.5:.03:1)
xlim([-.5, 1])
title('Models cannot generalize to other reach directions')
xlabel('Model PR2')
ylabel('# of units')
set(gca,'TickDir','out', 'box', 'off')

legend('Training Directions', 'Testing Direction')