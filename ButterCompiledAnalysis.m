%% PLOT SMOOTHFR
% 
% params.event_list = {'bumpTime'; 'bumpDir'};
% params.extra_time = [.4,.6];
% params.include_ts = true;
% params.include_start = true;
% params.include_naming = true;
% params.train_new_model = true;
% params.start_idx =  'idx_goCueTime';
% params.end_idx = 'idx_endTime';
% 
% clear cds
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_4_TD_sorted_FirstSort.mat')

td20180329 =td;
clear cds

param.arrays = {'cuneate'};
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td20180329, param);
%% 
param.array = 'cuneate';
getCOActPasStats(td20180329, param);
%%
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\ButterCONeurons.mat')
load('C:\Users\csv057\Documents\MATLAB\MapData\Butter\ButterMapping20180330.mat')
neuronsCO = [neuronsNew];
neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
mkdir('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\')
save('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\ButterCONeurons.mat', 'neuronsCO')
%%
cd('C:\Users\csv057\Pictures\CuneateSummaryPhotos\Cuneate\')
params.tuningCondition = {'isCuneate'};
neuronStructPlot(neuronsCO, params);

%%
cd('C:\Users\csv057\Pictures\CuneateSummaryPhotos\Cuneate\SinusoidalTuned\Active\')
params.tuningCondition = {'isCuneate', 'sinTunedAct'};
neuronStructPlot(neuronsCO, params);

cd('C:\Users\csv057\Pictures\CuneateSummaryPhotos\Cuneate\SinusoidalTuned\Passive\')
params.tuningCondition = {'isCuneate', 'sinTunedPas'};
neuronStructPlot(neuronsCO, params);

cd('C:\Users\csv057\Pictures\CuneateSummaryPhotos\Cuneate\SinusoidalTuned\Both\')
params.tuningCondition = {'isCuneate', 'sinTunedAct', 'sinTunedPas'};
neuronStructPlot(neuronsCO, params);

%%
cd('C:\Users\csv057\Pictures\CuneateSummaryPhotos\Cuneate\Mapping\Proprioceptive\')
params.tuningCondition = {'isCuneate', 'sameDayMap', 'isProprioceptive'};
neuronStructPlot(neuronsCO, params);

cd('C:\Users\csv057\Pictures\CuneateSummaryPhotos\Cuneate\Mapping\Spindle\')
params.tuningCondition = {'isCuneate', 'sameDayMap', 'isSpindle'};
neuronStructPlot(neuronsCO, params);

%%
cd('C:\Users\csv057\Pictures\CuneateSummaryPhotos\Gracile\')
params.tuningCondition = {'isGracile'};
neuronStructPlot(neuronsCO, params);
