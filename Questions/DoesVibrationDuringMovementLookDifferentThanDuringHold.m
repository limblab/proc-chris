close all
clear all

td = getTD('Crackle', '20190408', 'CO', 2);
[~, td]= getTDidx(td, 'result', 'R');
td = td(~([td.chanVibOn] ~= [td.chanVibOff]));
td = smoothSignals(td, struct('signals', 'cuneate_spikes','calc_rate', true));
td = binTD(td, 50);

tdHold = td([td.idx_vibOffTime] < [td.idx_tgtOnTime] & [td.idx_vibOffTime] > [td.idx_vibOnTime]);
tdMove = td([td.idx_vibOnTime] > [td.idx_goCueTime]  & [td.idx_vibOffTime] > [td.idx_vibOnTime]);

%%

unitNum = 58;

tdHold = trimTD(tdHold, 'idx_vibOnTime', 'idx_vibOffTime');
tdMove = trimTD(tdMove, 'idx_vibOnTime', 'idx_vibOffTime');

holdFiring = cat(1, tdHold.cuneate_spikes);
moveFiring = cat(1, tdMove.cuneate_spikes);

moveVel = cat(1, tdMove.vel);
holdVel = cat(1, tdHold.vel);
scatter(rownorm(moveVel), moveFiring(:,unitNum));
hold on
scatter(rownorm(holdVel), holdFiring(:,unitNum));

meanHold = mean(holdFiring);
meanMove = mean(moveFiring);

%%
c = categorical({'MeanHold','MeanMove'});
figure();
bar(c,[meanHold(unitNum), meanMove(unitNum)])
ylabel('firing rate (hz)')
%%
figure();
firing = cat(1, td.cuneate_spikes);
speed = rownorm(cat(1, td.vel));
scatter(speed,firing(:,unitNum), 'filled');
firingMove = cat(1,tdMove.cuneate_spikes);
speedMove = rownorm(cat(1, tdMove.vel));
hold on
scatter(speedMove, firingMove(:,unitNum), 'filled')
%%
figure();
fit1 = fitlm(speed, firing(:,unitNum));
fit2 = fitlm(speedMove, firingMove(:,unitNum));
h1 = plot(fit1);
hold on
h2 = plot(fit2);

set(h1, 'color', 'k')
set(h2, 'color', 'b')

slopeAll = fit1.Coefficients.Estimate(2);
slopeVib = fit2.Coefficients.Estimate(2);

offCI = coefCI(fit1);
vibCI = coefCI(fit2);

figure()
errorbar([1,2], [slopeAll, slopeVib], [slopeAll - offCI(2,1), slopeVib- vibCI(2,1)], [slopeAll - offCI(2,2), slopeVib-vibCI(2,2)]);
xlim([0, 3])
xticks([1,2])
xticklabels({'VibOff', 'VibOn'})
title('Slope of firing/velocity curve as a function of vibration')
ylabel('Regression slope (hz/ (cm/s))')