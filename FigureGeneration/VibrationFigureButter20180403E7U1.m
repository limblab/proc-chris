load('Butter20190403VibStructBrachialisE7U1.mat')

max1 = max(smooth(vib.vibUnit.firing));
times = vib.vibTimes;
figure
plot(vib.vibUnit.t, smooth(vib.vibUnit.firing))
hold on
for i = 1:length(vib.vibTimes(:,1))
    rectangle('Position', [times(i,1), 0 , times(i,2) - times(i,1), max1], 'FaceColor', [.5,.5,.5,.4])
end

xlabel('Time (seconds')
ylabel('Firing Rate (Hz)')
set(gca,'TickDir','out', 'box', 'off')
