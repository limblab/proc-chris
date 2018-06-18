% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Butter\20180607\neuronStruct\NeuronsCO_Butter_20180607.mat', 'neuronStruct20180607')
close all
params.tuningCondition = {'sinTunedAct'};
neuronStructPlot(neuronsCO, params);
params.tuningCondition = {'isSorted','sinTunedAct','sinTunedPas'};
neuronStructPlot(neuronStruct20180403, params);
params.tuningCondition = {'sameDayMap', 'isSpindle', 'isSorted'};
neuronStructPlot(neuronStruct20180403, params);
params.tuningCondition = {'isCuneate', 'isSorted'};
neuronStructPlot(neuronStruct20180403, params);
params.tuningCondition = {'isGracile', 'isSorted'};
