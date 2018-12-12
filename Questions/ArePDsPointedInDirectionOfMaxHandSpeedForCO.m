% monkey = 'Lando';
% date = '20170917';
monkey = 'Butter';
date = '20180607';
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO');

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
increment  = 60;

[smoothed, edges] = smoothCircle(theta, mag, increment);
meanSpeed = mean(smoothed);
polarplot(deg2rad(edges), smoothed, 'LineWidth', 2)
circ = 0:.01:2*pi;
hold on
polarplot(0:.01:2*pi, meanSpeed*ones(length(circ),1), 'LineWidth', 2)

%%
figure
hold on
for i = 1:length(tdActVel)
    plot([0,tdActVel(i,1)], [0, tdActVel(i,2)])
end
axis equal
%%
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Neurons\Lando_03-20-2017_CObump_NeuronStruct.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Neurons\Butter_06-07-2018_CObump_NeuronStruct.mat')

params.cutoff = pi/4;
neurons.sinTunedCIMetric = neuronStructIsTuned(neurons, params)';

neuronsTuned = neurons(find(neurons.sinTunedCIMetric & neurons.isSorted), :);
fh1 = figure;

plotCONeuronsTuningCurve(neuronsTuned,'b', fh1)
%%
neuronPD = [neuronsTuned.actPD.velPD];
[pd, dispersion] = circ_vmpar(neuronPD);
% plotRWNeuronsTuningCurve(neuronsTuned,'r', fh1)

% plotRWNeuronsModDepth(neurons0703Tuned)
% plotRWNeuronsModDepth(neurons0405Tuned)
% 
% plotRWNeuronsPD(neurons0703Tuned)
% plotRWNeuronsPD(neurons0405Tuned)

