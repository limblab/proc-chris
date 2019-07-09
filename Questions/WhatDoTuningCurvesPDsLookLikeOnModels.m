clear all
close all

butterArray = 'cuneate';
monkeyButter = 'Crackle';
dateButter = '20190327';
mappingFile = getSensoryMappings(monkeyButter);
td = getTD(monkeyButter,dateButter, 'CO',1);
%%
td = getNorm(td,struct('signals','vel','field_extra','speed'));
params.alias = 'acc';
params.signals = 'vel';
td = getDifferential(td, params);    
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getMoveOnsetAndPeak(td, params);
[resultsEnc,td1] = compiledCOEncoding(td, params);
%%
fullModel = resultsEnc.modelFull;
td = binTD(td, 10);
td= getModel(td, fullModel);
%%
windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
params.arrays = {'glm_Full'};
params.date = dateButter;
params.in_signals = {'vel'};
params.train_new_model = true;

params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
params.windowAct= windowAct;
params.windowPas =windowPas;
params.arrays = {'glm_Full'};
params.array = 'glm_Full';
[trials, neuronsNew] = compiledCOActPasAnalysis(td, params);
%%
useMapping = true;
param.array = 'glmFull';
param.sinTuned= neuronsNew.sinTunedAct | neuronsNew.sinTunedPas;
neuronsCO = [neuronsNew];
if useMapping
    neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
end
saveNeurons(neuronsCO,'GLMFits');
%%
params.tuningCondition = {'isSorted', 'sinTunedAct','sinTunedPas'};
% params.suffix = 'Windowed';
neuronStructPlot(neuronsCO, params);
