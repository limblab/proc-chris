params.event_list = {'bumpTime'; 'bumpDir'};
params.extra_time = [.4,.6];
params.include_ts = true;
params.include_start = true;
params.include_naming = true;
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';

clear cds
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_4_TD_sorted_FirstSort.mat')
td20180329 = td(~isnan([td.idx_goCueTime]));
td20180329 = getMoveOnsetAndPeak(td20180329, params);

clear cds
%%
param.arrays = {'cuneate'};
[processedTrial0329, neurons0329] = compiledCOActPasAnalysis(td20180329, param);

%%
neuronsCO = neurons0329;
save('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Lando\CompiledNeurons\ButterCONeurons.mat', 'neuronsCO')
