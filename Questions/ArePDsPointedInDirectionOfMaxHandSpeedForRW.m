clear all
% monkey = 'Butter';
% date = '20180405';
monkey = 'Lando';
date = '20170728';
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'RW_hold');

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
increment  = 10;

[smoothed, edges] = smoothCircle(theta, mag, increment);
meanSpeed = mean(smoothed);
plot(deg2rad(edges), smoothed, 'LineWidth', 2)
circ = -pi:.01:pi;
hold on
plot(circ, meanSpeed*ones(length(circ),1), 'LineWidth', 2)

%%
figure
hold on
for i = 1:length(tdActVel)
    plot([0,tdActVel(i,1)], [0, tdActVel(i,2)])
end
%%
% load('Butter_04-05-2018_RW_cuneate_NeuronStruct.mat')
load('Lando_07-28-2017_RW_NeuronStruct.mat')

params.cutoff = pi/4;
neurons.sinTunedCIMetric = neuronStructIsTuned(neurons, params)';

neuronsTuned = neurons(find(neurons.sinTunedCIMetric & neurons.isSorted & neurons.isCuneate), :);
% fh1 = figure;
plotRWNeuronsPD(neuronsTuned);
hold on
yyaxis right
plot(deg2rad(edges), smoothed, 'LineWidth', 2)
circ = -pi:.01:pi;
plot(circ, meanSpeed*ones(length(circ),1), 'LineWidth', 2)
ylabel('Average Hand Speed during movement (cm/s)')
xlabel('Direction (rads)')
set(gca,'TickDir','out', 'box', 'off')


% histogram(neuronsTuned.PD.velPD,20)

% plotRWNeuronsTuningCurve(neuronsTuned,'b', fh1)
% plotRWNeuronsTuningCurve(neuronsTuned,'r', fh1)

% plotRWNeuronsModDepth(neurons0703Tuned)
% plotRWNeuronsModDepth(neurons0405Tuned)
% 
% plotRWNeuronsPD(neurons0703Tuned)
% plotRWNeuronsPD(neurons0405Tuned)


