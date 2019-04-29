close all
clear all
td = getTD('Crackle', '20190411', 'CO', 2);

td = td(~isnan([td.idx_vibOnTime]));
td = td(~isnan([td.idx_vibOffTime]));
[~, td] = getTDidx(td, 'result' ,'R');
td = removeBadNeurons(td, struct('remove_unsorted', true, 'min_fr', 1));
td = smoothSignals(td, struct('signals', 'cuneate_spikes','calc_rate', true));
td = binTD(td, 50);

td = td([td.idx_vibOffTime] > [td.idx_vibOnTime]);

tdControl = td([td.chanVibOn] == 0);
tdVib1 = td([td.chanVibOn] == 1);
tdVib2 = td([td.chanVibOn] == 3);
tdVib3 = td([td.chanVibOn] == 5);

tdControl = trimTD(tdControl, 'idx_vibOnTime', 'idx_vibOffTime');

tdVib1 = trimTD(tdVib1, 'idx_vibOnTime', 'idx_vibOffTime');
tdVib2 = trimTD(tdVib2, 'idx_vibOnTime', 'idx_vibOffTime');
tdVib3 = trimTD(tdVib3, 'idx_vibOnTime', 'idx_vibOffTime');


%%
tdVib = tdVib3;
unitGuide = tdVib.cuneate_unit_guide;
unitNum = 20;

velVib = cat(1, tdVib.vel);
firingVib = cat(1, tdVib.cuneate_spikes);



velOff = cat(1, tdControl.vel);
firingOff = cat(1, tdControl.cuneate_spikes);
for i = unitNum
    close all
figure();
scatter(rownorm(velVib), firingVib(:,i), 'Filled')

hold on
scatter(rownorm(velOff), firingOff(:,i), 'filled')

xlabel('Hand speed (cm/s)')
ylabel('Firing rate')
title(['Effect of hand speed on vibration-evoked firing Elec',num2str(unitGuide(i,1)), ' Unit ', num2str(unitGuide(i,2)) ])
legend('Vibration', 'No Vibration');
pause
end
%%
figure();
lmOff = fitlm(rownorm(velOff), firingOff(:,unitNum));
lmVib = fitlm(rownorm(velVib), firingVib(:,unitNum));

slopeOff = lmOff.Coefficients.Estimate(2);
slopeVib = lmVib.Coefficients.Estimate(2);

offCI = coefCI(lmOff);
vibCI = coefCI(lmVib);

plot(lmOff)
hold on
plot(lmVib)

figure()
errorbar([1,2], [slopeOff, slopeVib], [slopeOff - offCI(2,1), slopeVib- vibCI(2,1)], [slopeOff - offCI(2,2), slopeVib-vibCI(2,2)]);
xlim([0, 3])
xticks([1,2])
xticklabels({'VibOff', 'VibOn'})
title('Slope of firing/velocity curve as a function of vibration')
ylabel('Regression slope (hz/ (cm/s))')

%%
figure();
residOff = lmOff.Residuals.Raw;
residVib = lmVib.Residuals.Raw;
scatter(rownorm(velOff), residOff)
hold on
scatter(rownorm(velVib), residVib)
title('Residuals dont show bias with increasing speed')
xlabel('Hand speed (cm/s)')
ylabel('Model Error')
legend('VibOff', 'VibOn')
%%

meanFiringVib = mean(firingVib);
meanFiringOff = mean(firingOff);
c = categorical({'Vib on','Vib off'});

figure();
subplot(2, 1, 1)
bar(c,[meanFiringVib(unitNum), meanFiringOff(unitNum)])
ylabel('firing rate (hz)')
subplot(2, 1, 2)
bar(c,[mean(rownorm(velVib)), mean(rownorm(velOff))])
ylabel('Hand speed (cm/s)')
suptitle('Vibration effectively recruits cutaneous afferents')