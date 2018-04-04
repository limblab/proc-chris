params.event_list = {'bumpTime'; 'bumpDir'};
params.extra_time = [.4,.6];
params.include_ts = true;
params.include_start = true;
params.include_naming = true;
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';

load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Lando\20170917\CDS\Lando_COactpas_20170917_1_CDS_sorted_ConservativeSort.mat')
td20170917 = parseFileByTrial(cds, params);
td20170917 = td20170917(~isnan([td20170917.idx_goCueTime]));
td20170917 = getMoveOnsetAndPeak(td20170917, params);

clear cds
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Lando\20170903\CDS\Lando_CODelay_20170903_1_CDS_sorted_ConservativeSort.mat')
td20170903 = parseFileByTrial(cds, params);
td20170903 = td20170903(~isnan([td20170903.idx_goCueTime]));
td20170903 = getMoveOnsetAndPeak(td20170903, params);

clear cds
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Lando\20170320\CDS\Lando_COactpas_20170320_1_CDS_sorted_ConservativeSort.mat')
td20170320 = parseFileByTrial(cds, params);
td20170320 = td20170320(~isnan([td20170320.idx_goCueTime]));
td20170320 = getMoveOnsetAndPeak(td20170320, params);

clear cds
%%
param.arrays = {'cuneate'};
[processedTrial0917, neurons0917] = compiledCOActPasAnalysis(td20170917, param);

param.arrays = {'RightCuneate'};
[processedTrial0903, neurons0903] = compiledCOActPasAnalysis(td20170903, param);

param.arrays = {'RightCuneate', 'LeftS1'};
[processedTrial0320, neurons0320] = compiledCOActPasAnalysis(td20170320, param);
%%
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\LandoCONeurons.mat')
neuronsCO = [neuronsCO; neurons0320; neurons0903; neurons0917];
save('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\CompiledNeurons\LandoCONeurons.mat', 'neuronsCO')
