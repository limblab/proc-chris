load('Crackle_20190325_CObump_cuneate_idx_movement_on_idx_movement_on_idx_bumpTime_idx_bumpTime_NeuronStruct_MappedNeurons.mat')
mapping = getSensoryMappings('Crackle');
mapping = findHandCutaneousUnits(mapping);
mapping = findProximalArm(mapping);
mapping = findMiddleArm(mapping);
mapping = findDistalArm(mapping);
mapping = findCutaneous(mapping);
neurons = insertMappingsIntoNeuronStruct(neurons, mapping);
saveNeurons(neurons)
% neurons = neurons(~[neurons.cutaneous],:);
%% 
params.tuningCondition = {'isSorted'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted','sinTunedAct', 'sinTunedPas'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas', 'sameDayMap'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas', 'sameDayMap', 'proprio'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas', 'sameDayMap', 'cutaneous'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas', 'sameDayMap', 'proximal'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas', 'sameDayMap', 'midArm'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas', 'sameDayMap', 'distal'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sinTunedAct', 'sinTunedPas', 'midArm'};
neuronStructPlot(neurons, params);
%%
params.tuningCondition = {'isSorted', 'sameDayMap', 'sinTunedAct', 'sinTunedPas','isSpindle'};
spindles = neuronStructPlot(neurons, params);

