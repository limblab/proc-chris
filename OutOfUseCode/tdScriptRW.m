
close all


params.event_list = {};
td = parseFileByTrial(cds, params);
for i = 1:length(td)
    figure
    subplot(2,1,1)
    c = linspace(1,10, length(td(i).pos(:,1)));
    scatter(td(i).pos(:,1), td(i).pos(:,2),[],c)
    subplot(2,1,2)
    plot(td(i).Cuneate_spikes(:,12))
end
%%
params1.trials = 37;
visData(td, params1)