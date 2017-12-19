clear all
load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_TD.mat')
tdBin = binTD(td,5);
tdAct = trimTD(td, {'idx_movement_on'}, 'idx_endTime');
params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
params.array = 'cuneate';
params.out_signals = 'cuneate_spikes';
params.distribution = 'normal';
params.out_signal_names= tdAct.cuneate_unit_guide;
tablePDs = getTDPDs(tdAct, params);

save('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_PDTuningActiveNormal.mat', 'tablePDs');
%%
load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_TD.mat')
tdBin = binTD(td,5);

tdAct = trimTD(td, {'idx_movement_on'}, 'idx_endTime');
params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
params.array = 'RightCuneate';
params.out_signals = 'RightCuneate_spikes';
params.distribution = 'normal';
params.out_signal_names= tdAct.RightCuneate_unit_guide;
tablePDs = getTDPDs(tdAct, params);

save('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_PDTuningActiveNormal.mat', 'tablePDs');

%%
load('media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TD.mat')
td = getMoveOnsetAndPeak(td);
tdBin = binTD(td,5);

tdAct = trimTD(td, {'idx_movement_on'}, 'idx_endTime');
params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
params.array = 'RightCuneate';
params.out_signals = 'RightCuneate_spikes';
params.distribution = 'normal';
params.out_signal_names= tdAct.RightCuneate_unit_guide;
tablePDs = getTDPDs(tdAct, params);
%%
load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_PDTuningActiveNormal.mat');
coActPasPDs = tablePDs;
load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_PDTuningActiveNormal.mat');
coActPasPDs =[coActPasPDs; tablePDs];

%%
cutoff =pi/6;
num1 = [1:11,15];
day1=  coActPasPDs(1:19,:);
for i =height(tablePDs)
   curve = coActPasPDs(i,:);
   coActPasPDs.velTuned(i) = isTuned(curve.velPD,curve.velPDCI, cutoff);
end
totalTuned = sum(coActPasPDs.velTuned(num1));
percentTuned = totalTuned/length(num1);

