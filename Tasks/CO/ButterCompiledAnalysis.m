% load('C:\Users\wrest\Documents\MATLAB\SensoryMappings\Butter\ButterMapping20180611.mat')
% % load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_4_TD_sorted-resort_resort.mat')
% load('C:\Users\wrest\Documents\MATLAB\SensoryMappings\Butter\ButterMapping20180611.mat');
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180326\TD\Butter_CO_20180326_TD.mat');
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180326\TD\Butter_CO_20180326_1_TD__Conservative.mat')

%%
clear all 
close all
date = '20190213';
monkey = 'Crackle';
unitNames = 'cuneate';

mappingFile = getSensoryMappings(monkey);
mappingFile = findDistalArm(mappingFile);
mappingFile = findHandCutaneousUnits(mappingFile);
mappingFile = findProximalArm(mappingFile);
mappingFile = findMiddleArm(mappingFile);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO');

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
param.arrays = {'cuneate'};
param.in_signals = {'vel'};
param.train_new_model = true;

param.windowAct= windowAct;
param.windowPas =windowPas;
param.date = td(1).date;
if td(1).bin_size == .001
    td=binTD(td, 10);
    td = td(~isnan([td.idx_movement_on]));
end
% neuronsToInclude =  [2,4,60,98,172,12,19,23,25,27,29,91,175];
% td20180607 = subsetNeurons(td20180607, struct('indices', neuronsToInclude));
%%
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td, param);
%%
%% Load the sensory mapping files, upload into the neuron structure
param.array = 'cuneate';
param.sinTuned= neuronsNew.sinTunedAct | neuronsNew.sinTunedPas;
getCOActPasStatsArbDir(td, param);
neuronsCO = [neuronsNew];

neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
saveNeurons(neuronsCO,'MappedNeurons');

%% Compute the trial averaged speed of each direction
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas'};
neuronStructPlot(neuronsCO, params);
%%
windowAct= {'idx_movement_on', 0; 'idx_movement_on',5}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',1};
tdBin = binTD(td,5);
tdPas = tdBin(~isnan([tdBin.idx_bumpTime]));
tdAct = trimTD(tdBin, windowAct(1,:), windowAct(2,:));
tdPas = trimTD(tdPas, windowPas(1,:), windowPas(2,:));
%%
velActTrial = cat(3, tdAct.vel);
velAct = squeeze(mean(velActTrial,1))';
meanVelAct = mean(velAct);

velPasTrial = cat(3, tdPas.vel);
velPas = squeeze(mean(velPasTrial,1))';

meanVelPas = mean(velPas);
scatter(velAct(:,1), velAct(:,2),'k')
hold on
xlim([-60,60])
ylim([-60,60])
axis equal
scatter(velPas(:,1), velPas(:,2), 'r')
scatter(meanVelAct(1), meanVelAct(2),100,'g', 'filled')
scatter(meanVelPas(1), meanVelPas(2),100,'g', 'filled')
ang1 = rad2deg(atan2(meanVelAct(2), meanVelAct(1)));
%% Plot the tuning of the neurons and compare it to the highest velocity
actPDTable = neuronsCO(find(neuronsCO.isSorted & neuronsCO.isCuneate & neuronsCO.sinTunedAct) ,:).actPD;
pasPDTable = neuronsCO(find(neuronsCO.isSorted & neuronsCO.isCuneate & neuronsCO.sinTunedPas), :).pasPD;
actPasPDTable = neuronsCO(find(neuronsCO.isSorted & neuronsCO.isCuneate & neuronsCO.sinTunedPas & neuronsCO.sinTunedAct), :);

% for i = 1:length(actPasPDTable)
    pds = [actPasPDTable.actPD.velPD, actPasPDTable.pasPD.velPD];
    diffs= angleDiff(pds(:,1), pds(:,2), true, false);
    histogram(diffs)
   

%%
fh1 = figure;
[~,~,~,tunedPDs] = plotTuningDist(actPDTable,fh1, 'k', pi/2);
figure
[~,~,~,tunedPDsPas] = plotTuningDist(pasPDTable,fh1, 'k', pi/2);

meanDir = rad2deg(circ_mean(tunedPDs));

%% Fit decoding models to velocity and position to determine which neurons
%  best reflect the kinematics of the handle
disp('all units')
params.z_score_x = false;
params.flag = 1:length(tdAct(1).cuneate_spikes(1,:));
[tdVel, modelEval.All, modelFits.All] = linearVelocityDecoder(tdAct, params);

% Only sorted units
disp('Sorted units')
params.flag = find(neuronsCO.isSorted);
[tdVel, modelEval.Sorted, modelFits.Sorted] = linearVelocityDecoder(tdAct, params);
% Only sorted cuneate units
disp('Sorted Cuneate')
params.flag = find(neuronsCO.isCuneate& neuronsCO.isSorted);
[tdVel, modelEval.SortedCuneate, modelFits.SortedCuneate] = linearVelocityDecoder(tdAct, params);
% Only gracile channels
disp('Gracile')
params.flag = find(neuronsCO.isGracile);
[tdVel, modelEval.Gracile, modelFits.Gracile] = linearVelocityDecoder(tdAct, params);
% Only sorted Gracile units
disp('Gracile sorted')
params.flag = find(neuronsCO.isGracile & neuronsCO.isSorted);
[tdVel, modelEval.SortedGracile, modelFits.SortedGracile] = linearVelocityDecoder(tdAct, params);
% Only spindles
disp('spindles')
params.flag = find(neuronsCO.isSpindle & neuronsCO.sameDayMap & neuronsCO.isSorted);
[tdVel, modelEval.Spindles, modelFits.Spindles] = linearVelocityDecoder(tdAct, params);