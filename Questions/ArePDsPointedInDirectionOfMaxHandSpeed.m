monkey = 'Butter';
date = '20180405';
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'RW');

getSensoryMappings(monkey);

td1 = removeBadTrials(td);
param.windowAct = {'idx_movement_on'; 'idx_endTime'};
td_act = trimTD(td1, 'idx_movement_on', 'idx_endTime');
td_pas = trimTD(td1, 'idx_startTime', 'idx_movement_on');
tdPeak = trimTD(td1, 'idx_peak_speed', {'idx_peak_speed',1});
param.in_signals      = 'vel';
%%
tdActVel = cat(1, tdPeak.vel);
windowWidth = 35;
polynomialOrder = 2;
smoothX = sgolayfilt(tdActVel(:,1), polynomialOrder, windowWidth);
smoothY = sgolayfilt(tdActVel(:,2), polynomialOrder, windowWidth);

%%
figure
hold on
for i = 1:length(tdActVel)
    plot([0,smoothX(i)], [0, smoothY(i)])
end
