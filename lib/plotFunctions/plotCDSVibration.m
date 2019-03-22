function f1 = plotCDSVibration(cds, params)
rampStart =21.45;
rampEnd = rampStart+10;
freqStart = 10;
freqEnd = 210;

if nargin > 1, assignParams(who,params); end % overwrite parameters
freqVec = linspace(10, 210, 10000);
freqSweep = [[rampStart-20+.001:.001:rampStart+10]', vertcat(freqVec',freqVec',freqVec')];
f1 = figure;
% sp1 = subplot(2, 1,1);
plot(freqSweep(:,1), freqSweep(:,2))
% plot(cds.analog{1}.t, cds.analog{1}.Vibration)

% view([90, -90])
% xlim([20,34])
ylim([0, 250])
colormap viridis
set(gca,'TickDir','out', 'box', 'off')


units = cds.units([cds.units.ID] >0 & [cds.units.ID]<255);
% subplot(2,1,2)

hold on
% figure
vec = 0.1:.1:cds.analog{1}.t(end);
for i = 6
    rates(i,:) = histcounts(units(i).spikes.ts, [0,vec]);
    plot(vec, smooth(rates(i,:),10)*20)
    hold on
end
% xlim([20, 34])
set(gca,'TickDir','out', 'box', 'off')

end