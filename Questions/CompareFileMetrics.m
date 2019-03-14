%% Load all files for comparison
clear all
close all

butterArray = 'cuneate';
landoArray = 'cuneate';
crackleArray = 'cuneate';

arrayBLC = {butterArray, landoArray, crackleArray};

monkeyButter = 'Butter';
monkeyLando = 'Lando';
monkeyCrackle = 'Crackle';

monkeyBLC = {'Butter', 'Lando', 'Crackle'};

dateButter = '20190129';
dateLando = '20170917';
dateCrackle = '20190312';

dateBLC = {'20190129','20170917', '20190312'};

mappingLogB = getSensoryMappings(monkeyButter);
mappingLogL = getSensoryMappings(monkeyLando);
mappingLogC = getSensoryMappings(monkeyCrackle);

tdBLC{1} =getTD(monkeyButter, dateButter, 'CO',2);
tdBLC{2} = getTD(monkeyLando, dateLando, 'COactpas');
tdBLC{3} = getTD(monkeyCrackle, dateCrackle, 'CO',2);
%%
for i = 1:3
    
    td = tdBLC{i};
    statTab(i,1).Monkey= monkeyBLC{i};
    statTab(i,1).Date = dateBLC{i};
    statTab(i,1).Duration = td(end).trial_start_time + length(td(end).pos(:,1))*td(end).bin_size;
    statTab(i,1).NumTrials = length(td);
    statTab(i,1).NumRewards = length(getTDidx(td, 'result', 'R'));
    statTab(i,1).PercentSuccess= statTab(i,1).NumRewards/ length(td);
    statTab(i,1).NumUnits = length(td(1).([arrayBLC{i}, '_unit_guide'])(:,1));
    
    tdMove = trimTD(td, 'idx_movement_on', 'idx_endTime');
    statTab(i,1).MeanHandSpeedMove = mean(rownorm(cat(1, tdMove.vel)));
    tdBump = td(~isnan([td.idx_bumpTime]));
    tdBump = trimTD(tdBump, 'idx_bumpTime', {'idx_bumpTime', floor(0.13/td(1).bin_size)});
    statTab(i,1).MeanHandSpeedBump = mean(rownorm(cat(1, tdBump.vel)));
    firing = cat(1, tdMove.([arrayBLC{i}, '_spikes']))./td(1).bin_size;
    meanFiring = mean(firing);
    statTab(i,1).MeanFR = mean(meanFiring);
    statTab(i,1).StdFR = std(meanFiring);
    results = compiledCODecoding(td);
    statTab(i,1).PosMeanR2Decoding= results.PosMean; 
    statTab(i,1).PosMeanLowR2Decoding = results.PosMeanLow; 
    statTab(i,1).PosMeanHighR2Decoding = results.PosMeanHigh; 
    statTab(i,1).VelMeanR2Decoding = results.VelMean; 
    statTab(i,1).VelMeanLowR2Decoding = results.VelMeanLow; 
    statTab(i,1).VelMeanHighR2Decoding = results.VelMeanHigh; 
    statTab(i,1).SpeedMeanR2Decoding = results.SpeedMean;
    statTab(i,1).SpeedMeanLowR2Decoding = results.SpeedLow;
    statTab(i,1).SpeedMeanHighR2Decoding = results.SpeedHigh; 
    
    results = compiledCOEncoding(td);
    statTab(i,1).FullEnc = results.FullEnc;
    statTab(i,1).FullNoPosEnc = results.FullNoPosEnc;
    statTab(i,1).FullNoVelEnc = results.FullNoVelEnc;
    statTab(i,1).FullNoForceEnc= results.FullNoForceEnc;
    statTab(i,1).FullNoSpeedEnc = results.FullNoSpeedEnc;
    statTab(i,1).VelEnc = results.VelEnc;
    statTab(i,1).PosEnc = results.PosEnc;
    statTab(i,1).SpeedEnc = results.SpeedEnc;
    statTab(i,1).VelSpeedEnc = results.VelSpeedEnc;
    statTab(i,1).AccEnc = results.AccEnc;
end
%%
disp(struct2table(statTab))