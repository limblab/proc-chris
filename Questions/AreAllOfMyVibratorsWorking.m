close all
clear all
monkey = 'Crackle';
date = '20190426';
td = getTD(monkey, date, 'CO', 1);
[~, td] =getTDidx(td, 'result','R');


td = smoothSignals(td, struct('signals', 'cuneate_spikes','calc_rate', true));
td = getMoveOnsetAndPeak(td, struct('start_idx', 'idx_goCueTime', 'end_idx', 'idx_endTime'));
td = binTD(td, 50);
td = removeBadNeurons(td, struct('remove_unsorted', true, 'min_fr', 1));

mapping = td(1).cuneate_naming;
unitGuide = td(1).cuneate_unit_guide;

%%
plotVibd = true;
vibrationChans = [0,9,13,3,25,14];

tdVibAll = td(~isnan([td.idx_vibOnTime]));
tdVibAll = tdVibAll([tdVibAll.idx_vibOnTime]< [tdVibAll.idx_vibOffTime]);
tdVibAll = trimTD(tdVibAll, 'idx_vibOnTime', 'idx_vibOffTime');
tdNoVib = tdVibAll([tdVibAll.chanVibOn] == 0);
chansVibd = unique([tdVibAll.chanVibOn]);

velAll = cat(1, tdNoVib.vel);
firingAll = cat(1, tdNoVib.cuneate_spikes);
mkdir([getPathFromTD(td), filesep, 'plotting',filesep]); 

for i = 2:length(chansVibd)
    elecNum(i) = map2elec(td, vibrationChans(i));
    indNum{i} = find(unitGuide(:, 1) == elecNum(i));
    tdVib{i} = tdVibAll([tdVibAll.chanVibOn] == chansVibd(i));
    firingVib{i} = cat(1, tdVib{i}.cuneate_spikes);
    velVib{i} = cat(1, tdVib{i}.vel);
    
    if plotVibd 
    for indVib = 1:length(indNum{i})
    close all

    fh1 = figure();
    scatter(rownorm(velAll), firingAll(:, indNum{i}(indVib)), 'filled');
    hold on
    scatter(rownorm(velVib{i}), firingVib{i}(:, indNum{i}(indVib)), 'filled');
    title(['Elec ',num2str(unitGuide(indNum{i}(indVib), 1)), ' Unit ', num2str(unitGuide(indNum{i}(indVib),2)), ' Vib ' , num2str(i),'mapName ', num2str(elec2map(td,unitGuide(indNum{i}(indVib),1))), ' ind ', num2str(indNum{i}(indVib))])
    legend({'AllFiring', 'VibFiring'})
    
    lmOff =fitlm(velAll, firingAll(:, indNum{i}(indVib)));
    lmVib =fitlm(velVib{i}, firingVib{i}(:, indNum{i}(indVib)));
    
    fh2 = figure();
    plot(lmOff)
    hold on
    plot(lmVib)
    offCI = coefCI(lmOff);
    vibCI = coefCI(lmVib);
    slopeOff = lmOff.Coefficients.Estimate(2);
    slopeVib = lmVib.Coefficients.Estimate(2);
    
    fh3=figure();
    errorbar([1,2], [slopeOff, slopeVib], [slopeOff - offCI(2,1), slopeVib- vibCI(2,1)], [slopeOff - offCI(2,2), slopeVib-vibCI(2,2)]);
    xlim([0, 3])
    xticks([1,2])
    xticklabels({'VibOff', 'VibOn'})
    title('Slope of firing/velocity curve as a function of vibration')
    ylabel('Regression slope (hz/ (cm/s))')
    
    if offCI(2, 2) < slopeVib | offCI(2,1) > slopeVib | vibCI(2, 2) < slopeOff | vibCI(2,1) > slopeOff
        saveas(fh1, [getPathFromTD(td), filesep, 'plotting',filesep,monkey, '_',date, 'FiringRates_Elec_',num2str(unitGuide(indNum{i}(indVib), 1)), '_Unit_', num2str(unitGuide(indNum{i}(indVib),2)), '_Vib_' , num2str(i),'_mapName_', num2str(elec2map(td,unitGuide(indNum{i}(indVib),1))),'.png'])
        saveas(fh2, [getPathFromTD(td), filesep, 'plotting',filesep,monkey, '_',date, 'LM_Elec_',num2str(unitGuide(indNum{i}(indVib), 1)), '_Unit_', num2str(unitGuide(indNum{i}(indVib),2)), '_Vib_' , num2str(i),'_mapName_', num2str(elec2map(td,unitGuide(indNum{i}(indVib),1))),'.png'])
        saveas(fh3, [getPathFromTD(td), filesep, 'plotting',filesep,monkey, '_',date, 'CIs_Elec_',num2str(unitGuide(indNum{i}(indVib), 1)), '_Unit_', num2str(unitGuide(indNum{i}(indVib),2)), '_Vib_' , num2str(i),'_mapName_', num2str(elec2map(td,unitGuide(indNum{i}(indVib),1))),'.png'])
    end
    pause()

    end
    else
    for indVib = 1:length(firingAll(1,:))
    close all

    fh1 = figure();
    scatter(rownorm(velAll), firingAll(:, indVib), 'filled');
    hold on
    scatter(rownorm(velVib{i}), firingVib{i}(:, indVib), 'filled');
    title(['Elec ',num2str(unitGuide(indVib, 1)), ' Unit ', num2str(unitGuide(indVib,2)), ' Vib ' , num2str(i),'mapName ', num2str(elec2map(td,unitGuide(indVib,1))), ' ind ', num2str(indVib)])
    legend({'AllFiring', 'VibFiring'})
    
    lmOff =fitlm(rownorm(velAll), firingAll(:, indVib));
    lmVib =fitlm(rownorm(velVib{i}), firingVib{i}(:,indVib));
    
    fh2 = figure();
    plot(lmOff)
    hold on
    plot(lmVib)
    offCI = coefCI(lmOff);
    vibCI = coefCI(lmVib);
    slopeOff = lmOff.Coefficients.Estimate(2);
    slopeVib = lmVib.Coefficients.Estimate(2);
    
    fh3=figure();
    errorbar([1,2], [slopeOff, slopeVib], [slopeOff - offCI(2,1), slopeVib- vibCI(2,1)], [slopeOff - offCI(2,2), slopeVib-vibCI(2,2)]);
    xlim([0, 3])
    xticks([1,2])
    xticklabels({'VibOff', 'VibOn'})
    title('Slope of firing/velocity curve as a function of vibration')
    ylabel('Regression slope (hz/ (cm/s))')
    
    if (offCI(2, 2) < vibCI(2,1) | offCI(2,1) > vibCI(2,2) | vibCI(2, 2) < offCI(2,1) | vibCI(2,1) > offCI(2,2)) & (offCI(1,1) > vibCI(1,2) | offCI(1,2) < vibCI(1,1) | vibCI(1,1) > offCI(1,2) | vibCI(1,2) < offCI(1,1))
        saveas(fh1, [getPathFromTD(td), filesep, 'plotting',filesep,monkey, '_',date, 'FiringRates_Elec_',num2str(unitGuide(indVib, 1)), '_Unit_', num2str(unitGuide(indVib,2)), '_Vib_' , num2str(i),'_mapName_', num2str(elec2map(td,unitGuide(indVib,1))),'.png'])
        saveas(fh2, [getPathFromTD(td), filesep, 'plotting',filesep,monkey, '_',date, 'LM_Elec_',num2str(unitGuide(indVib, 1)), '_Unit_', num2str(unitGuide(indVib,2)), '_Vib_' , num2str(i),'_mapName_', num2str(elec2map(td,unitGuide(indVib,1))),'.png'])
        saveas(fh3, [getPathFromTD(td), filesep, 'plotting',filesep,monkey, '_',date, 'CIs_Elec_',num2str(unitGuide(indVib, 1)), '_Unit_', num2str(unitGuide(indVib,2)), '_Vib_' , num2str(i),'_mapName_', num2str(elec2map(td,unitGuide(indVib,1))),'.png'])
        
    end
    end
    end
end





