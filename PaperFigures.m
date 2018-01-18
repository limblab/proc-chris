clear all
load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TD_wNaming.mat')
params.cutoff = pi/4;
params.arrays ={'LeftS1','RightCuneate'};
params.windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
params.windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
params.distribution = 'normal';
params.date = '03202017';
params.train_new_model = true;
params.cuneate_flag = true;

processedTrial03202017 = compiledCOActPasAnalysis(td, params);
%%
load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_TD_wNaming.mat')
params.cutoff = pi/4;
params.arrays ={'LeftS1','RightCuneate'};
params.windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
params.windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
params.distribution = 'normal';
params.date = '09032017';
params.train_new_model = true;
params.cuneate_flag = true;

processedTrial09032017 = compiledCOActPasAnalysis(td, params);
%% 
load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_TD_wNaming.mat')
params.cutoff = pi/4;
params.arrays ={'area2','cuneate'};
params.windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
params.windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
params.distribution = 'normal';
params.date = '09172017';

params.train_new_model = true;
params.cuneate_flag = true;

processedTrial09172017 = compiledCOActPasAnalysis(td, params);

%%
%%
clear cuneateCompiledProcessed
clear s1CompiledProcessed
cuneateCompiledProcessed(1) = processedTrial03202017(2).actPasStats;
cuneateCompiledProcessed(2) = processedTrial09032017(2).actPasStats;
cuneateCompiledProcessed(3) = processedTrial09172017(2).actPasStats;

s1CompiledProcessed(1) = processedTrial03202017(1).actPasStats;

inStruct.date = 'CombinedDates 03202017, 09032017, 09172017';
inStruct.array= cuneateCompiledProcessed(1).array;
inStruct.angBump = cat(2,cuneateCompiledProcessed.angBump);
inStruct.angMove = cat(2,cuneateCompiledProcessed.angMove);
inStruct.tuned = cat(2,cuneateCompiledProcessed.tuned);
inStruct.pasActDif = cat(2,cuneateCompiledProcessed.pasActDif);
inStruct.dcBump = cat(2, cuneateCompiledProcessed.dcBump);
inStruct.dcMove = cat(2,cuneateCompiledProcessed.dcMove);
inStruct.modDepthMove = cat(2,cuneateCompiledProcessed.modDepthMove);
inStruct.modDepthBump = cat(2, cuneateCompiledProcessed.modDepthBump);

coActPasPlotting(inStruct)

inStructS1.date = 'CombinedDates 03202017, 09032017, 09172017';
inStructS1.array= s1CompiledProcessed(1).array;
inStructS1.angBump = cat(2,s1CompiledProcessed.angBump);
inStructS1.angMove = cat(2,s1CompiledProcessed.angMove);
inStructS1.tuned = cat(2,s1CompiledProcessed.tuned);
inStructS1.pasActDif = cat(2,s1CompiledProcessed.pasActDif);
inStructS1.dcBump = cat(2, s1CompiledProcessed.dcBump);
inStructS1.dcMove = cat(2,s1CompiledProcessed.dcMove);
inStructS1.modDepthMove = cat(2,s1CompiledProcessed.modDepthMove);
inStructS1.modDepthBump = cat(2, s1CompiledProcessed.modDepthBump);
coActPasPlotting(inStructS1)
