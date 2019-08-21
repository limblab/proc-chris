
%%
clear all 
close all
date = '20190819';
monkey = 'Snap';
array = 'cuneate';
useMapping = true;

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

td =getTD(monkey, date, 'CO',1);
td = normalizeTDLabels(td);
td = getSpeed(td);

%%
if ~isfield(td, 'idx_movement_on')
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeak(td, params);
end

windowAct= {'idx_movement_on', 0; 'idx_endTime',0}; %Default trimming windows active
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
neuronsNew = fitCOBumpPSTH(td, neuronsNew, params);
% [processedTrialNew, neuronsNew] = compiledCOMoveAnalysis(td, param);
%%
%% Load the sensory mapping files, upload into the neuron structure
param.array = array;
param.sinTuned= neuronsNew.sinTunedAct | neuronsNew.sinTunedPas;
neuronsCO = [neuronsNew];
%%
if useMapping
    neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
end
saveNeurons(neuronsCO,'MappedNeurons');

%% Compute the trial averaged speed of each direction
close all
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas','proximal'};
% params.suffix = 'Windowed';
neuronStructPlot(neuronsCO, params);
%%