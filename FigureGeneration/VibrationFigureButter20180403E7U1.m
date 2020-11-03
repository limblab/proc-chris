load('D:\MonkeyData\CO\Butter\20180403\neuronStruct\Butter20190403VibStructBrachialisE7U1.mat')
close all
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
    firstSpike(i) = min(shifted);
end
%%
figure
histogram(firstSpike, 0:0.001:0.05, 'Normalization', 'probability')
xlabel('Neuron spike lag to vibration peak (ms)')
ylabel('Proportion of spikes')
xticklabels({'0','','10','','20','','30','','40','','50'})
    

set(gca,'TickDir','out', 'box', 'off')
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