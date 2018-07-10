load('C:\Users\wrest\Documents\MATLAB\SensoryMappings\Butter\ButterMapping20180611.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_4_TD_sorted-resort_resort.mat')

td20180329 =td;

param.arrays = {'cuneate'};
param.in_signals = {'vel'};
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td20180329, param);
%% 
param.array = 'cuneate';
% getCOActPasStats(td20180329, param);
neuronsCO = [neuronsNew];
neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
%%
params.tuningCondition = {'isSorted', 'isGracile'};
neuronStructPlot(neuronsCO, params);
