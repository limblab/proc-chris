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
% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_4_TD_sorted_FirstSort.mat')
% 
% 
% clear cds
%%
param.arrays = {'cuneate'};
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td20180329, param);

%%
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\ButterCONeurons.mat')
neuronsCO = [neuronsNew];
mkdir('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\')
save('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\ButterCONeurons.mat', 'neuronsCO')
