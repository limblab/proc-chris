close all
clear all
monkey = 'Crackle';
date = '20190503';
td = getTD(monkey, date, 'CO', 1);
[~, td] =getTDidx(td, 'result','R');


td = smoothSignals(td, struct('signals', 'cuneate_spikes','calc_rate', true));
td = getMoveOnsetAndPeak(td, struct('start_idx', 'idx_goCueTime', 'end_idx', 'idx_endTime'));
td = binTD(td, 50);
td = removeBadNeurons(td, struct('remove_unsorted', true, 'min_fr', 1));

mapping = td(1).cuneate_naming;
unitGuide = td(1).cuneate_unit_guide;

%%
plotVibd = false;
vibrationChans = [0,9,13,3,25,14];

tdVibAll = td(~isnan([td.idx_vibOnTime]));
tdVibAll = tdVibAll([tdVibAll.idx_vibOnTime]< [tdVibAll.idx_vibOffTime]);
% tdVibAll = tdVibAll([tdVibAll.idx_vibOnTime] > [tdVibAll.idx_movement_on]);
tdVibAll = trimTD(tdVibAll, 'idx_vibOnTime', 'idx_vibOffTime');
tdNoVib = tdVibAll([tdVibAll.chanVibOn] == 0);
chansVibd = unique([tdVibAll.chanVibOn]);

velAll = cat(1, tdNoVib.vel);
firingAll = cat(1, tdNoVib.cuneate_spikes);
mkdir([getPathFromTD(td), filesep, 'plotting',filesep]); 

for indVib = 1:length(firingAll(1,:))

    for i = 2:length(chansVibd)
    close all

    elecNum(i) = map2elec(td, vibrationChans(i));
    indNum{i} = find(unitGuide(:, 1) == elecNum(i));
    tdVib{i} = tdVibAll([tdVibAll.chanVibOn] == chansVibd(i));
    firingVib{i} = cat(1, tdVib{i}.cuneate_spikes);
    velVib{i} = cat(1, tdVib{i}.vel);
    
    lmOff =fitlm(velAll, firingAll(:, indVib));
    lmVib =fitlm(velVib{i}, firingVib{i}(:,indVib));
    
    bX = lmOff.Coefficients.Estimate(2);
    bY = lmOff.Coefficients.Estimate(3);
    
    pdOff = atan2(bY, bX);
    pdMag = sqrt(bX^2 + bY^2);
    
    speedInPDOff = cos(pdOff)*velAll(:,1) + sin(pdOff)*velAll(:,2);
    speedInPDVib = cos(pdOff)*velVib{i}(:,1) + sin(pdOff)*velVib{i}(:,2);
    
    fh1 = figure();
    scatter(speedInPDOff, firingAll(:, indVib), 'filled');
    hold on
    scatter(speedInPDVib, firingVib{i}(:, indVib), 'filled');
    title(['Elec ',num2str(unitGuide(indVib, 1)), ' Unit ', num2str(unitGuide(indVib,2)), ' Vib ' , num2str(i),'mapName ', num2str(elec2map(td,unitGuide(indVib,1))), ' ind ', num2str(indVib)])
    legend({'AllFiring', 'VibFiring'})
    
    fh2 = figure();
    lm1 = fitlm(speedInPDOff, firingAll(:,indVib));
    lm2 = fitlm(speedInPDVib, firingVib{i}(:, indVib));
    
    plot(lm1);
    hold on
    plot(lm2);
    
    offCI = coefCI(lm1);
    vibCI = coefCI(lm2);
    slopeOff = lm1.Coefficients.Estimate(2);
    slopeVib = lm2.Coefficients.Estimate(2);
    
    fh3=figure();
    errorbar([1,2], [slopeOff, slopeVib], [slopeOff - offCI(2,1), slopeVib- vibCI(2,1)], [slopeOff - offCI(2,2), slopeVib-vibCI(2,2)]);
    xlim([0, 3])
    xticks([1,2])
    xticklabels({'VibOff', 'VibOn'})
    title('Slope of firing/velocity curve as a function of vibration')
    ylabel('Regression slope (hz/ (cm/s))')
    
    pause()

    end

end





