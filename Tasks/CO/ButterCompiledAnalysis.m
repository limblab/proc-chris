% load('C:\Users\wrest\Documents\MATLAB\SensoryMappings\Butter\ButterMapping20180611.mat')
% % load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_4_TD_sorted-resort_resort.mat')
% load('C:\Users\wrest\Documents\MATLAB\SensoryMappings\Butter\ButterMapping20180611.mat');
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180326\TD\Butter_CO_20180326_TD.mat');
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180326\TD\Butter_CO_20180326_1_TD__Conservative.mat')

%%
clear all 
close all
date = '20170913';
monkey = 'Chips';
array = 'LeftS1Area2';
useMapping = false;

if useMapping
    mappingFile = getSensoryMappings(monkey);
    mappingFile = findDistalArm(mappingFile);
    mappingFile = findHandCutaneousUnits(mappingFile);
    mappingFile = findProximalArm(mappingFile);
    mappingFile = findMiddleArm(mappingFile);
    mappingFile = findCutaneous(mappingFile);
end
beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO');
td = normalizeTDLabels(td);
%%
if ~isfield(td, 'idx_movement_on')
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeak(td, params);
end

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
param.arrays = {array};
param.in_signals = {'vel'};
param.train_new_model = true;

params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
param.windowAct= windowAct;
param.windowPas =windowPas;
param.date = date;
if td(1).bin_size == .001
    td=binTD(td, 10);
    td = getMoveOnsetAndPeak(td,params);
    td = td(~isnan([td.idx_movement_on]));

end
%%
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td, param);
%%
%% Load the sensory mapping files, upload into the neuron structure
param.array = array;
param.sinTuned= neuronsNew.sinTunedAct | neuronsNew.sinTunedPas;
getCOActPasStatsArbDir(td, param);
neuronsCO = [neuronsNew];
%%
if useMapping
    neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
end
saveNeurons(neuronsCO,'MappedNeurons');

%% Compute the trial averaged speed of each direction
params.tuningCondition = {'isSorted'};
neuronStructPlot(neurons, params);
%%