monkey = 'Butter';
date = '20180405';
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'RW');

getSensoryMappings(monkey);

td1 = removeBadTrials(td);
param.windowAct = {'idx_movement_on'; 'idx_endTime'};
td_act = trimTD(td1, 'idx_movement_on', 'idx_endTime');
td_pas = trimTD(td1, 'idx_startTime', 'idx_movement_on');
tdPeak = trimTD(td1, 'idx_peak_speed', 'idx_peak_speed');
param.in_signals      = 'vel';
%%
close all
tdActVel = cat(1, tdPeak.vel);
[theta, mag] = cart2pol(tdActVel(:,1), tdActVel(:,2));
theta= rad2deg(theta);
mean1 = circ_mean(theta, mag);
increment  = 30;

[smoothed, edges] = smoothCircle(theta, mag, increment);
polarplot(deg2rad(edges), smoothed, 'LineWidth', 2)

%%
figure
hold on
for i = 1:length(tdActVel)
    plot([0,tdActVel(i,1)], [0, tdActVel(i,2)])
end
