startLen = 1.0;
endLen = 1.5;
time = [0.001:.001:2]';
ramp = [startLen*ones(200, 1); linspace(startLen, endLen, 500)'; endLen*ones(500,1); linspace(endLen, startLen, 500)'; startLen*ones(300, 1)];
MuscLen = timeseries(ramp, time);
DynGam = timeseries(zeros(length(time),1),time);
StatGam = timeseries(zeros(length(time),1),time);

set_param('MuscleSpindleGUIModel', 'StopTime', '2');
simOut = sim('MuscleSpindleGUIModel');

figure
plot(Secondary.Time, Secondary.Data)
yyaxis right
plot(time, ramp, 'r')

figure
plot(Primary.Time, Primary.Data)
yyaxis right
plot(time, ramp, 'r')
