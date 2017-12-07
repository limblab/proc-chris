figure
subplot(2,1,1)
for i = 1:length(trial.cuneate_ts{1})
    hold on
    plot([trial.cuneate_ts{1}(i), trial.cuneate_ts{1}(i)], [0,1])
    
end
subplot(2,1,2)
plot(trial.cuneate_spikes(:,1))
