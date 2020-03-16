function [h5, p5, ci5, stats5] = spindleFunctionTemp(cds, unitNum, window )

xBound = window;

timeVec = 0:.02:max(cds.analog{1,1}.t);
stimOn = zeros(length(cds.analog{1,1}.Sync),1);
stimSig = cds.analog{1,1}.Sync;
unit = unitNum;
% for i = 1:length(stimOn)
%     if stimSig(i)>100
%         for  j = 1:20
%             stimOn(i-j+10) = 1;
%         end
%     end
% end
for j = unit
    spikesAll = [cds.units(j).spikes.ts([cds.units(j).spikes.ts]> xBound(1) & [cds.units(j).spikes.ts]<xBound(2))];
    for k = 1:length(timeVec)-1
        spikeRate(k,j) = sum([cds.units(j).spikes.ts]> timeVec(k) & [cds.units(j).spikes.ts]<timeVec(k+1))*50;
    end
    spikes = [cds.units(j).spikes.ts([cds.units(j).spikes.ts]> xBound(1) & [cds.units(j).spikes.ts]<xBound(2))];
    
    figure
    subplot(2,1,1)
    yyaxis left
    plot(cds.analog{1,1}.t, cds.analog{1, 1}.Sync)
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
stimOn(7376:2000:55395) = 1;
tmp = 7376:55375;
t = cds.analog{1,1}.t;
tmp1 = reshape(tmp, 2000,[]);
stimDiff = diff(stimOn);
stimWindow(:,1) = t(tmp1(1,:)');
stimWindow(:,2) = t(tmp1(end,:)');

unit  = cds.units(j);
spikes = unit.spikes;
binSize = .05;
rate(:,1) = binSize:binSize:cds.meta.duration;
rate(:,2) = histcounts(spikes.ts, [0:binSize:cds.meta.duration])';
for i =1:length(stimWindow(:,1))
    fr(i,:) = rate(rate(:,1) > stimWindow(i,1) & rate(:,1) < stimWindow(i,2),2);
end
figure
subplot(2,1,1)
imagesc(flipud(fr(:,2:end).*20))
ylabel('Trial #')
yticklabels({'20', '15', '10', '5'})


set(gca,'TickDir','out', 'box', 'off')
xticks([])

subplot(2,1,2)
plot(.1:.05:2, mean(fr(:,2:end))*20)
ylabel('Firing Rate (Hz)')

yyaxis right
plot([0,2], [0,200])
set(gca,'TickDir','out', 'box', 'off')
xticks([0,1,2])
xticklabels({'0', '1.0', '2.0'})
xlabel('Time relative to vibration onset (sec)')
ylabel('Vibration Frequency (Hz)')


end

