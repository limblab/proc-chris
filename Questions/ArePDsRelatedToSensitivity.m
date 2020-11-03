close all
clear all
windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
figure
scatter(-10, 0, 32, 'k', 'filled')
hold on
scatter(-10, 0, 32, 'r', 'filled')
legend('Active', 'Passive')
for i = [1:3, 6,8,9]
    neuronsCO = getPaperNeurons(i, windowAct, windowPas);
    params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
    'tuningCondition', {{'isSorted','isCuneate','proprio', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
    params.date = 'all';
    params.useMins = false;
    neuronsFiltered = neuronStructPlot(neuronsCO, params);

    scatter(neuronsFiltered.actPD.velPD,mean(neuronsFiltered.sActBoot,2), 32, 'k', 'filled','HandleVisibility','off')
    scatter(neuronsFiltered.pasPD.velPD,mean(neuronsFiltered.sPasBoot,2), 32, 'r', 'filled','HandleVisibility','off')

end
xlim([-pi, pi])
% ylim([0, 30])
xlabel('Preferred Direction')
ylabel('Sensitivity')
set(gca,'TickDir','out', 'box', 'off')
%%
clear all
windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

figure
hold on
for i = [1:3, 6,8,9]
    neuronsCO = getPaperNeurons(i, windowAct, windowPas);
    params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
    'tuningCondition', {{'isSorted','isCuneate','proprio', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
    params.date = 'all';
    params.useMins = false;
    neuronsFiltered = neuronStructPlot(neuronsCO, params);

    scatter(neuronsFiltered.actPD.velPD,mean(neuronsFiltered.sDifBoot,2), 32, 'k', 'filled','HandleVisibility','off')

end
xlim([-pi, pi])
% ylim([0, 30])
xlabel('Preferred Direction')
ylabel('Sensitivity')
set(gca,'TickDir','out', 'box', 'off')