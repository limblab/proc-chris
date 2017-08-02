function plotPredCurves(td)
% Plots actual and predicted tuning curves for ext and musc models

%% Get tuning curves
vel_dl = cat(1,td.vel);
opensim = cat(1,td.opensim);
opensim = opensim(:,contains(td(1).opensim_names,'bicep_lh'));
opensim_vel = gradient(opensim,td(1).bin_size);

[dl_curves,bins] = getTuningCurves(vel_dl,opensim_vel);

%% Plot tuning curves
figure
for neuron_idx = 1:height(dl_curves)
    clf;
    maxFR = max([dl_curves(neuron_idx,:).CIhigh]);
    subplot(2,1,2)
    plotTuning(bins,[],dl_curves(neuron_idx,:),maxFR,[1 0 0]);
    title 'actual curves'
    subplot(2,1,1)
    title(['Neuron ' num2str(neuron_idx)])

    waitforbuttonpress;
end
