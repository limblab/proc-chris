close all
clear all
load('D:\MonkeyData\CO\Butter\20180403\neuronStruct\Butter20190403VibStructBrachialisE7U1.mat')

vib = vib1;
max1 = max(smooth(vib.vibUnit.firing));
times = vib.vibTimes;
figure
plot(vib.vibUnit.t, smooth(vib.vibUnit.firing))
hold on
for i = 1:length(vib.vibTimes(:,1))
    rectangle('Position', [times(i,1), 0 , times(i,2) - times(i,1), max1], 'FaceColor', [.5,.5,.5,.4])
end
xlim([7.1,10])
xlabel('Time (seconds')
ylabel('Firing Rate (Hz)')
set(gca,'TickDir','out', 'box', 'off')

for i = 1:length(vib.vibOn.vibPeaks)
    pTime = vib.vibOn.vibPeaks(i);
    firing = vib.vibUnit.ts;
    shifted = firing-pTime;
    shifted(shifted<0) = [];
    firstSpike{i} = shifted;
end
%%
 vec = 0.005:0.00025:0.01;
allSpikes = vertcat(firstSpike{:});
allSpikes(allSpikes>0.01)=[];
figure
histogram(allSpikes, 0:0.0005:0.010, 'Normalization', 'probability')
wave2 = histcounts(allSpikes, 0:0.0005:0.01);

xlabel('Neuron spike lag to vibration peak (ms)')
ylabel('Spikes')

%%
radSpikes = (allSpikes./0.01)*2*pi;
figure
polarhistogram(radSpikes, 20 , 'Normalization', 'probability')
thetaticks(rad2deg([0, pi/5, 2*pi/5, 3*pi/5, 4*pi/5, pi, 6*pi/5, 7*pi/5, 8*pi/5, 9*pi/5]))

%%
% xticklabels({'0','','4','','8','','12'})
maxW = max(wave);
halfMax = floor(maxW/2);
halfMaxLow = find([wave(2:end),0] > halfMax & [wave < halfMax], 1)-1;
wave = wave(end:-1:1);
halfMaxHigh = length(wave)- find([wave(2:end),0] > halfMax & [wave < halfMax], 1)+1;

set(gca,'TickDir','out', 'box', 'off')
figure
plot(vec(1:end-1), wave)
hold on
plot([vec(halfMaxLow), vec(halfMaxLow)], [0, maxW])
plot([vec(halfMaxHigh), vec(halfMaxHigh)], [0, maxW])
numInWindow = sum(allSpikes> vec(halfMaxLow) & allSpikes< vec(halfMaxHigh));
pctInWindow = numInWindow/length(allSpikes);
%%
firingVibOn = [];
figure
for i = 1:length(times(:,1))
    time1 = times(i,1);
    time2 = times(i,2);
    firingWin = firing(firing>time1 & firing<time2) - time1;
    firingVibOn = [firingVibOn;firing(firing>time1 & firing<time2)];
    scatter(firingWin,.005*i*ones(length(firingWin),1), 'k.')
    hold on
end

xlim([-.1, 1.1])
ylim([0, .04])

%%
firingVibOff = setdiff(firing, firingVibOn);
isiDist = diff(firingVibOn);
isiDistOff = diff(firingVibOff);
figure
histogram(isiDist, 0:.001:0.05, 'Normalization', 'probability')
hold on
histogram(isiDistOff, 0:0.001:0.05, 'Normalization', 'probability')
xlabel('Interspike Interval')
ylabel('Probability')
legend('Vibration On','Vibration off')
set(gca,'TickDir','out', 'box', 'off')