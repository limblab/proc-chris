close all
load('Butter_07-03-2018_RW_NeuronStruct.mat')
% load('Lando_01-25-2017_RW_NeuronStruct.mat')
neuronsIso = neurons;
load('Butter_04-05-2018_RW_NeuronStruct.mat')
% load('Lando_07-28-2017_RW_NeuronStruct.mat')
neuronsKin= neurons;

params.cutoff = pi/4;

neuronsIso.sinTunedCIMetric = neuronStructIsTuned(neuronsIso, params)';
neuronsKin.sinTunedCIMetric = neuronStructIsTuned(neuronsKin, params)';

neuronsIsoTuned = neuronsIso(find(neuronsIso.sinTunedCIMetric & neuronsIso.isSorted & neuronsIso.isCuneate), :);
neuronsKinTuned = neuronsKin(find(neuronsKin.sinTunedCIMetric & neuronsKin.isSorted & neuronsKin.isCuneate), :);
fh1 = figure;

plotRWNeuronsTuningCurve(neuronsKinTuned,'b', fh1)
plotRWNeuronsTuningCurve(neuronsIsoTuned,'r', fh1)

% plotRWNeuronsModDepth(neurons0703Tuned)
% plotRWNeuronsModDepth(neurons0405Tuned)
% 
% plotRWNeuronsPD(neurons0703Tuned)
% plotRWNeuronsPD(neurons0405Tuned)

