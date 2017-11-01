close all
xBound = [16, 16.1];

timeVec = 0:.02:max(cds.analog{1,1}.t);
stimOn = zeros(length(cds.analog{1,1}.KinectSyncPulse),1);
stimSig = cds.analog{1,1}.KinectSyncPulse;
unit = 148;
for i = 1:length(stimOn)
    if stimSig(i)>100
        for  j = 1:20
            stimOn(i-j+10) = 1;
        end
    end
end
for j = unit
    spikesAll = [cds.units(j).spikes.ts([cds.units(j).spikes.ts]> xBound(1) & [cds.units(j).spikes.ts]<xBound(2))];
    for k = 1:length(timeVec)-1
        spikeRate(k,j) = sum([cds.units(j).spikes.ts]> timeVec(k) & [cds.units(j).spikes.ts]<timeVec(k+1))*50;
    end
    spikes = [cds.units(j).spikes.ts([cds.units(j).spikes.ts]> xBound(1) & [cds.units(j).spikes.ts]<xBound(2))];
    
    figure
    subplot(2,1,1)
    yyaxis left
    plot(cds.analog{1,2}.t, cds.analog{1, 2}.SpindleStim)
    ylabel('Vibrator Voltage (mV)')
    hold on
    yyaxis right
    plot(timeVec(1:end-1), smooth(spikeRate(:,j)))
    xlim(xBound);
    
    for i = 1:length(spikes)
        subplot(2,1,2)
        line([spikes(i), spikes(i)], [0,.5])
        hold on
        ylim([-.5,1.5])
    end
    xlim(xBound)
    ylabel('Firing rate (Hz)')
end
stimDiff = diff(stimOn);
count = 0;
count1 = 1;
stimOffWindow(1,1) = 0;
for i = 1:length(stimDiff)
    if stimDiff(i) == 1
        count = count +1;
        stimWindow(count, 1) = cds.analog{1,2}.t(i);
        stimWindowInd(count,1) = i;
        stimOffWindow(count1,2) = cds.analog{1,2}.t(i);
        count1 = count1 +1;
    elseif stimDiff(i) == -1
        stimWindow(count,2) =  cds.analog{1,2}.t(i);
        stimWindowInd(count,2) = i;
        stimOffWindow(count1,1) = cds.analog{1,2}.t(i);
    end
end
onSpikes = [];
offSpikes= [];
for i = 1:length(stimWindow(:,1))
    avgFiring(i) = mean(spikeRate(timeVec> stimWindow(i,1) & timeVec <stimWindow(i,2),unit));
    onSpikes = [onSpikes;cds.units(j).spikes.ts([cds.units(j).spikes.ts]> stimWindow(i,1) & [cds.units(j).spikes.ts]<stimWindow(i,2))];
    preFiring(i) = mean(spikeRate(timeVec> stimWindow(i,1)- .3 & timeVec < stimWindow(i,1),unit));

end
for i = 1:length(stimOffWindow(:,1))
    offSpikes = [offSpikes;cds.units(j).spikes.ts([cds.units(j).spikes.ts]> stimOffWindow(i,1) & [cds.units(j).spikes.ts]<stimOffWindow(i,2))];
end
set(gca,'TickDir','out','box', 'off')
xlabel('Time (seconds)')

figure
yyaxis left
plot(cds.analog{1,2}.t, stimOn)
ylabel('Stimulation Voltage (V)')
hold on
yyaxis right
plot(timeVec(1:end-1), smooth(spikeRate(:,j)))
xlim(xBound);
ylabel('Firing rate (Hz)')

[h, p, ci, stats] = ttest(avgFiring, preFiring);

figure 
histogram(avgFiring, 5)
hold on
histogram(preFiring,5)

nonjumpOn = diff(onSpikes);
nonjumpOff = diff(offSpikes);

diffOn = nonjumpOn(nonjumpOn<.5);
diffOff = nonjumpOff(nonjumpOff<.5);

figure
histogram(diffOn)
hold on
histogram(diffOff)

spindleStim = [cds.analog{1,2}.t,cds.analog{1,1}.KinectSyncPulse];
psthBefore = 50;
psthAfter = 0;
psth = zeros(psthBefore+psthAfter,1);
for i= 1:length(onSpikes)
    first = find(onSpikes(i)<spindleStim(:,1), 1)-(psthBefore+psthAfter);
    psth =  psth + spindleStim(first-psthBefore:first+psthAfter-1,2)/length(onSpikes);
end
figure
p1 = plot(-1*psthBefore:-1, psth(end:-1:1));

p1.LineWidth = 2;
xlabel('Time Before Spike (ms)')
ylabel('Average Vibration Voltage (mV)')
figure
beforeTrialWindow = .50;
afterTrialWindow = 1.20;
spikesInWindow = cell(length(stimWindow),1);
spikeRateAvg = zeros(85, 1);
for i= 1:length(stimWindow)
    spikesInWindow{i} = [cds.units(j).spikes.ts([cds.units(j).spikes.ts]> stimWindow(i, 1) - beforeTrialWindow & [cds.units(j).spikes.ts]<stimWindow(i,1)+afterTrialWindow) - stimWindow(i,1)];
    spindleStimInWindow{i} = spindleStim(spindleStim(:,1)> stimWindow(i, 1)& spindleStim(:,1) < stimWindow(i,2),:);
    stimDiff = diff(spindleStimInWindow{i}(:,2));
    foundFirst = false;
    k = 0;
    while ~foundFirst
        k = k+1;
        if ( spindleStimInWindow{i}(k,2) >500 & stimDiff(k)>0 & stimDiff(k+1)<0)
            firstPeak(i) = spindleStimInWindow{i}(k+1,1) - stimWindow(i,1);
            foundFirst = true;
        end
    end
end
width = stimWindow(:,2) - stimWindow(:,1);
[sortedWidth, sorting] = sort(width, 1, 'ascend');
counter =0;
for i = sorting'
    counter = counter +1;
    spikesInWindow{i} = [cds.units(j).spikes.ts([cds.units(j).spikes.ts]> stimWindow(i, 1) - beforeTrialWindow & [cds.units(j).spikes.ts]<stimWindow(i,1)+afterTrialWindow) - stimWindow(i,1) - firstPeak(i)];
    h = subplot(2,1,1);
    for k = 1:length(spikesInWindow{i})
        line([spikesInWindow{i}(k), spikesInWindow{i}(k)], [counter,counter+.5], 'LineWidth', 1)
        hold on
        ylim([.5,16])
    end
    xlim([-.5, 1.3])
    p = patch([-1.*firstPeak(i)', sortedWidth(counter), sortedWidth(counter), -1.*firstPeak(i)'], [counter-.25, counter-.25, counter+.75, counter+.75], 'r');
    ylabel('Trial Number')
    set(h,'XTick',[],'XTickLabel',[]);
    set(p, 'FaceAlpha', .5, 'EdgeColor', 'none');
    set(gca,'TickDir','out','box', 'off')
    spikeRateAvg = spikeRateAvg + spikeRate(timeVec>stimWindow(i,1)-beforeTrialWindow& timeVec < stimWindow(i,1)+afterTrialWindow,j)/length(stimWindow);
end
subplot(2,1,2)
p1 = plot(linspace(-.5, 1.2,85), spikeRateAvg);
p1.LineWidth = 2;
ylim([0, 120])
xlim([-.5, 1.3])
ylabel('Firing Rate (Hz)')
xlabel('Time Relative to Vibration Start (seconds)')
set(gca,'TickDir','out','box', 'off')

