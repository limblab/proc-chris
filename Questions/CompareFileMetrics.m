%% Load all files for comparison
clear all
close all

butterArray = 'cuneate';
landoArray = 'cuneate';
crackleArray = 'cuneate';
chipsArray = 'LeftS1Area2';
hanArray = 'S1';

arrayBLC = {butterArray, landoArray, crackleArray, chipsArray, hanArray};

monkeyButter = 'Butter';
monkeyLando = 'Lando';
monkeyCrackle = 'Crackle';
monkeyChips = 'Chips';
monkeyHan = 'Han';

monkeyBLC = {'Butter', 'Lando', 'Crackle', monkeyChips, monkeyHan};

dateButter = '20190129';
dateLando = '20170917';
dateCrackle = '20190315';
dateChips = '20170913';
dateHan= '20171116';

dateBLC = {'20190129','20170917', '20190315', dateChips, dateHan};

mappingLogB = getSensoryMappings(monkeyButter);
mappingLogL = getSensoryMappings(monkeyLando);
mappingLogC = getSensoryMappings(monkeyCrackle);



%%
for i = 1:5
    switch i
        case 1
            td = getTD(monkeyButter,dateButter, 'CO',2);
        case 2
            td = getTD(monkeyLando, dateLando, 'COactpas');
        case 3
            td = getTD(monkeyCrackle, dateCrackle, 'CO',1);
        case 4
            td = getTD(monkeyChips, dateChips, 'CO');
        case 5 
            td = getTD(monkeyHan, dateHan, 'CO');
            params.alias = 'acc';
            params.signals = 'vel';
            td = getDifferential(td, params);
    end
    td = tdToBinSize(td, 50);
    array = arrayBLC{i};
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    params.Array= arrayBLC{i};
    params.array = arrayBLC{i};
    td = getMoveOnsetAndPeak(td, params);
    statTab(i,1).Monkey= monkeyBLC{i};
    statTab(i,1).Date = dateBLC{i};
%     statTab(i,1).Duration = td(end).trial_start_time + length(td(end).pos(:,1))*td(end).bin_size;
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
    results = compiledCODecoding(td, params);
    statTab(i,1).PosMeanR2Decoding= results.PosMean; 
    statTab(i,1).PosMeanLowR2Decoding = results.PosMeanLow; 
    statTab(i,1).PosMeanHighR2Decoding = results.PosMeanHigh; 
    statTab(i,1).VelMeanR2Decoding = results.VelMean; 
    statTab(i,1).VelMeanLowR2Decoding = results.VelMeanLow; 
    statTab(i,1).VelMeanHighR2Decoding = results.VelMeanHigh; 
    statTab(i,1).SpeedMeanR2Decoding = results.SpeedMean;
    statTab(i,1).SpeedMeanLowR2Decoding = results.SpeedLow;
    statTab(i,1).SpeedMeanHighR2Decoding = results.SpeedHigh; 
    params.doCuneate = strcmp(array, 'cuneate');
    results = compiledCOEncoding(td, params);
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
save('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Compiled\compiledFileMetrics.mat', 'statTab');
%%
close all
disp(struct2table(statTab))
decodeMat = [[statTab(:).PosMeanR2Decoding]', [statTab(:).VelMeanR2Decoding]', [statTab(:).SpeedMeanR2Decoding]'];
c = categorical({'Butter','Lando', 'Crackle', 'Chips (area2)', 'Han (area2)'});
figure2();
bar(c, decodeMat)
set(gca,'TickDir','out', 'box', 'off')
legend('Pos R2', 'Vel R2', 'Speed R2')
title('Decoding performance with all neurons')

figure2();
subplot(5, 1,1)

histogram(statTab(1).FullEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Butter')
xlim([0,1])

subplot(5, 1,2)
histogram(statTab(2).FullEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Lando')
xlim([0,1])

subplot(5, 1,3)
histogram(statTab(3).FullEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Crackle')
xlim([0,1])

subplot(5, 1,4)
histogram(statTab(4).FullEnc,0:.05:1.00)
set(gca,'TickDir','out', 'box', 'off')
title('Chips (area 2)')
xlim([0,1])

subplot(5, 1,5)
histogram(statTab(5).FullEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Han (area 2)')
suptitle('Encoding performance with full model')
xlim([0,1])



figure2();
subplot(5, 1,1)
histogram(statTab(1).VelEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Butter')
xlim([0,1])

subplot(5, 1,2)
histogram(statTab(2).VelEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Lando')
xlim([0,1])

subplot(5, 1,3)
histogram(statTab(3).VelEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Crackle')
xlim([0,1])

subplot(5, 1,4)
histogram(statTab(4).VelEnc,0:.05:1.00)
set(gca,'TickDir','out', 'box', 'off')
title('Chips (area 2)')
xlim([0,1])

subplot(5, 1,5)
histogram(statTab(5).VelEnc,0:.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
title('Han (area 2)')
suptitle('Encoding performance with Vel model')
xlim([0,1])
