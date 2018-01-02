% clear all
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_TD.mat')
% tdBin = binTD(td,5);
% tdAct = trimTD(tdBin, {'idx_movement_on'}, 'idx_endTime');
% params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
% params.array = 'cuneate';
% params.out_signals = 'cuneate_spikes';
% params.distribution = 'normal';
% params.out_signal_names= tdAct.cuneate_unit_guide;
% tablePDs = getTDPDs(tdAct, params);
% 
% save('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_PDTuningActiveNormal.mat', 'tablePDs');
% %%
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_TD.mat')
% 
% tdBin = binTD(td,5);
% tdAct = trimTD(tdBin, {'idx_movement_on'}, 'idx_endTime');
% params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
% params.array = 'area2';
% params.out_signals = 'area2_spikes';
% params.distribution = 'normal';
% params.out_signal_names= tdAct.area2_unit_guide;
% tablePDsArea2 = getTDPDs(tdAct, params);
% 
% save('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_PDTuningActiveNormalArea2.mat', 'tablePDs');
% %%
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_TD.mat')
% td = getMoveOnsetAndPeak(td);
% tdBin = binTD(td,5);
% 
% tdAct = trimTD(tdBin, {'idx_movement_on'}, 'idx_endTime');
% params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
% params.array = 'RightCuneate';
% params.out_signals = 'RightCuneate_spikes';
% params.distribution = 'normal';
% params.out_signal_names= tdAct.RightCuneate_unit_guide;
% tablePDs = getTDPDs(tdAct, params);
% 
% save('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_PDTuningActiveNormal.mat', 'tablePDs');
% 
% %%
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TD.mat')
% td = getMoveOnsetAndPeak(td);
% tdBin = binTD(td,5);
% 
% tdAct = trimTD(tdBin, {'idx_movement_on'}, 'idx_endTime');
% params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
% params.array = 'RightCuneate';
% params.out_signals = 'RightCuneate_spikes';
% params.distribution = 'normal';
% params.out_signal_names= tdAct.RightCuneate_unit_guide;
% tablePDs = getTDPDs(tdAct, params);
% 
% save('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_PDTuningActiveNormal.mat', 'tablePDs')
% %%
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TD.mat')
% td = getMoveOnsetAndPeak(td);
% tdBin = binTD(td,5);
% 
% tdAct = trimTD(tdBin, {'idx_movement_on'}, 'idx_endTime');
% params.window= {'idx_movement_on', 0 ;'idx_endTime', 0};
% params.array = 'LeftS1';
% params.out_signals = 'LeftS1_spikes';
% params.distribution = 'normal';
% params.out_signal_names= tdAct.LeftS1_unit_guide;
% tablePDs = getTDPDs(tdAct, params);
% 
% save('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TDArea2.mat', 'tablePDs')
% %%
% close all
% cutoff = pi/8;
% fh1 = figure ;
% hold on
% % load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_PDTuningActiveNormal.mat')
% % [fh1, percentTunedAll{1}, coActPasTuningAll{1}] = plotTuningDist(tablePDs, fh1, 'r' , cutoff );
% 
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_PDTuningActiveNormal.mat')
% [fh1, percentTunedAll{2}, coActPasTuningAll{2}] = plotTuningDist(tablePDs, fh1, 'b', cutoff);
% 
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_PDTuningActiveNormal.mat')
% [fh1, percentTunedAll{3}, coActPasTuningAll{3}] = plotTuningDist(tablePDs, fh1, 'k',cutoff);
% title('Cuneate Tuned Preferred Directions')
% 
% fh2 = figure;
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TDArea2.mat');
% [fh1, percentTunedAll{1}, coActPasTuningAll{1}] = plotTuningDist(tablePDs, fh2, 'r' ,cutoff);
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_PDTuningActiveNormalArea2.mat')
% [fh1, percentTunedAll{1}, coActPasTuningAll{1}] = plotTuningDist(tablePDs, fh2, 'b', cutoff);
% title('Area 2 Tuned Preferred Directions')
% 
% %%
% clear all
% close all
% disp('Working')
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_TD.mat')
% 
% params.date1 = '09172017';
% params.array = 'cuneate';
% 
% [fh3, outStruct(1)] = getCOActPasStats(td,params);
% disp('Done 1')
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_TD.mat')
% params.date1 = '09032017';
% params.array = 'RightCuneate';
% [fh4, outStruct(2)] = getCOActPasStats(td,params);
% disp('Done 2')
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TD_noMotionTracking.mat')
% params.date1 = '03202017';
% params.array = 'RightCuneate';
% [fh5, outStruct(3)] = getCOActPasStats(td,params);
% disp('Done 3')
% inStruct.date = 'CombinedDates 03202017, 09032017, 09172017';
% inStruct.array= outStruct(1).array;
% inStruct.angBump = cat(2,outStruct.angBump);
% inStruct.angMove = cat(2,outStruct.angMove);
% inStruct.tuned = cat(2,outStruct.tuned);
% inStruct.pasActDif = cat(2,outStruct.pasActDif);
% inStruct.dcBump = cat(2, outStruct.dcBump);
% inStruct.dcMove = cat(2,outStruct.dcMove);
% inStruct.modDepthMove = cat(2,outStruct.modDepthMove);
% inStruct.modDepthBump = cat(2, outStruct.modDepthBump);
% 
% 
% coActPasPlotting(inStruct)
% [h, p, stats1] = ttest(inStruct.dcBump, inStruct.dcMove)
% %%
% close all
% clear all
% disp('Working')
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_TD.mat')
% 
% params.date1 = '09172017';
% params.array = 'area2';
% 
% [fh3, outStructS1(1)] = getCOActPasStats(td,params);
% disp('Done 1')
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_TD.mat')
% params.date1 = '09032017';
% params.array = 'LeftS1';
% [fh4, outStructS1(2)] = getCOActPasStats(td,params);
% disp('Done 2')
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TD_noMotionTracking.mat')
% params.date1 = '03202017';
% params.array = 'LeftS1';
% [fh5, outStructS1(1)] = getCOActPasStats(td,params);
% disp('Done 3')
% 
% inStructS1.date = 'CombinedDates 03202017, 09032017, 09172017';
% inStructS1.array= outStructS1(1).array;
% inStructS1.angBump = cat(2,outStructS1.angBump);
% inStructS1.angMove = cat(2,outStructS1.angMove);
% inStructS1.tuned = cat(2,outStructS1.tuned);
% inStructS1.pasActDif = cat(2,outStructS1.pasActDif);
% inStructS1.dcBump = cat(2, outStructS1.dcBump);
% inStructS1.dcMove = cat(2,outStructS1.dcMove);
% inStructS1.modDepthMove = cat(2,outStructS1.modDepthMove);
% inStructS1.modDepthBump = cat(2, outStructS1.modDepthBump);
% 
% 
% coActPasPlotting(inStructS1)
% [h, p, stats1] = ttest(inStructS1.dcBump, inStructS1.dcMove)
% 
% [h,p, stats1] = ttest(outStructS1(2).dcBump, outStructS1(2).dcMove)
% 
% 
% %%
params.cutoff = pi/4;
params.arrays= {'LeftS1', 'RightCuneate'};
params.windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
params.windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
params.distribution = 'normal';
params.date = '03202017';
params.arrays = {'LeftS1', 'RightCuneate'};


processed09172017 = compiledCOActPasAnalysis(td, params);

%%
chanNames = cds.units(~cellfun(@isempty,([strfind({cds.units.array},'RightCuneate')])));

sortedUnits = chanNames([chanNames.ID]>0 & [chanNames.ID]<255);
elecNames = unique([sortedUnits.chan]);
screenNames = {sortedUnits.label};
for i= 1:length(sortedUnits)
   labelNames(i) = str2num(screenNames{i}(5:end)); 
end

labels = unique(labelNames);

conversionChart = [elecNames', labels'];
processed03202017(2).namingConversion  = conversionChart;
