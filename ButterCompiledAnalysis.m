% load('C:\Users\wrest\Documents\MATLAB\SensoryMappings\Butter\ButterMapping20180611.mat')
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_4_TD_sorted-resort_resort.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Lando\20170917\TD\Lando_COactpas_20170917_TD_001.mat')

td20180329 =td;

param.arrays = {'cuneate'};
param.in_signals = {'vel'};
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td20180329, param);
%% 
param.array = 'cuneate';
% getCOActPasStats(td20180329, param);
neuronsCO = [neuronsNew];
neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
%%
% params.tuningCondition = {'isCuneate','isSorted','sinTunedAct'};
% neuronStructPlot(neuronsCO, params);
windowAct= {'idx_movement_on', 0; 'idx_movement_on',5}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',2};
tdBin = binTD(td20180329,5);
tdPas = tdBin(~isnan([tdBin.idx_bumpTime]));
tdAct = trimTD(tdBin, windowAct(1,:), windowAct(2,:));
tdPas = trimTD(tdPas, windowPas(1,:), windowPas(2,:));

velActTrial = cat(3, tdAct.vel);
velAct = squeeze(mean(velActTrial,1))';
meanVelAct = mean(velAct);

velPasTrial = cat(3, tdPas.vel);
velPas = squeeze(mean(velPasTrial,1))';

meanVelPas = mean(velPas);
scatter(velAct(:,1), velAct(:,2),'k')
hold on
xlim([-60,60])
ylim([-60,60])
axis equal
scatter(velPas(:,1), velPas(:,2), 'r')
scatter(meanVelAct(1), meanVelAct(2),100,'g', 'filled')
scatter(meanVelPas(1), meanVelPas(2),100,'g', 'filled')
ang1 = rad2deg(atan2(meanVelAct(2), meanVelAct(1)));
%%
actPDTable = neuronsCO.actPD;
fh1 = figure;
[~,~,~,tunedPDs] = plotTuningDist(actPDTable,fh1, 'k', pi/4);
meanDir = rad2deg(circ_mean(tunedPDs));