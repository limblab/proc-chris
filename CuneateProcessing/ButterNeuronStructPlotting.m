tunedNeurons = neuronsCO(logical([neuronsCO.sinTunedAct]),:);
figure
scatter(rad2deg(tunedNeurons.pasPD.velPD), rad2deg(tunedNeurons.actPD.velPD),'k', 'filled')
hold on
plot([-180, 180], [-180, 180], 'r--', 'LineWidth', 1)
xlim([-180, 180])
ylim([-180, 180])
set(gca,'TickDir','out', 'box', 'off')