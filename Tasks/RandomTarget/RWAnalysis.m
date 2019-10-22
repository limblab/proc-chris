% clear all
clearvars -except tdCO1
close all
array = 'cuneate';
monkey = 'Snap';
date = '20191010';
plotPos = true;
plotSpeeds = true;
plotResponses =true;


if ~exist('tdCO1')
    tdCO1 = getTD(monkey, date, 'RW',1);
end
tdRW = tdToBinSize(tdCO1,10);

if ~isfield(tdRW, 'idx_movement_on')
    tdRW = getSpeed(tdRW);
    params.go_cue_name = 'idx_goCueTime';
    params.end_name           =  'idx_endTime';

    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    tdRW=  getRWMovements(tdRW, params);

    tdRW = getMoveOnsetAndPeak(tdRW, params);
end

% 
tdRW = removeUnsorted(tdRW);

tdRW = removeGracileTD(tdRW);

tdRW = tdRW(~isnan([tdRW.idx_movement_on]));

td_act = trimTD(tdRW, 'idx_movement_on', 'idx_endTime');
td_pas = trimTD(tdRW, 'idx_trial_start', 'idx_movement_on');

[trialProcessed, neuronNew] = compiledRWAnalysis(td_act);
param.array = 'cuneate';
param.sinTuned= neuronNew.isTuned;
param.in_signals      = 'vel';

%%
mappingLog = getSensoryMappings('Snap');
neuronsRW = [neuronNew];
neuronsRW = insertMappingsIntoNeuronStruct(neuronsRW,mappingLog);

saveNeurons(neuronsRW)
%%
actPDTable = neuronsRW(find(neuronsRW.isSorted & neuronsRW.isCuneate),:).PD;
gracilePDTable = neuronsRW(find(neuronsRW.isSorted & neuronsRW.isGracile),:).PD;

% for i = 1:length(actPasPDTable)

fh1 = figure;
[~,~,~,tunedPDs] = plotTuningDist(actPDTable,fh1, 'k', pi/2);
fh2 = figure;
[~,~,~,tunedPDs] = plotTuningDist(gracilePDTable,fh2, 'k', pi/2);

meanDir = rad2deg(circ_mean(tunedPDs));
%% 
pos = cat(1, tdRW.pos);
vel = cat(1,td_pas.vel);

velAct = cat(1, td_act.vel);
figure
histogram(rownorm(vel), 'Normalization', 'probability')
hold on
histogram(rownorm(velAct),'Normalization', 'probability')

%%
close all

paramHeat.array = array;
paramHeat.unitsToPlot = 1:length(td_pas(1).([paramHeat.array,'_spikes'])(1,:));
paramHeat.numBounds = 6;
paramHeat.xLimits = [-10,10];
paramHeat.yLimits = [-42, -22];
paramHeat.useJointPCA = false;
paramHeat.plotError = false;
paramHeatAct = paramHeat;
paramHeatPas = paramHeat;
paramHeatPas.velocityCutoffHigh =10;
[f1, spikingInBounds, varInBounds] = neuralHeatmap(td_pas,paramHeat);
% [f2, spikingInBoundsPas, varInBoundsPas] = neuralHeatmap(td1, paramHeatPas);

% for i = 1:16
%     paramHeat.unitsToPlot = i;
%     paramHeat.array = 'cuneate';
%     paramHeat.numBounds = 6;
%     paramHeat.xLimits = [-10,10];
%     paramHeat.yLimits = [-42, -22];
%     paramHeat.useJointPCA = false;
%     paramHeat.plotError = true;
%     paramHeat.xLimits = [-10,10];
%     paramHeat.yLimits = [-42 -22];
%     paramHeat.useJointPCA = false;
%     f1 = neuralHeatmap(td_pas, paramHeat);
%     a1 = gca;
%     c1 = get(gca, 'clim');
%     f2 = neuralHeatmap(td_act, paramHeat);
%     a2 = gca;
%     c2 = get(gca, 'clim');
%     minC = min([c1, c2]);
%     maxC = max([c1, c2]);
%     set(a1, 'clim', [minC, maxC]);
%     set(a2, 'clim', [minC, maxC]);
%     
% end


%%
[curvesAct] = getTuningCurves(td_act,struct('out_signals',{paramPDs.out_signals},'out_signal_names',{td_act(1).cuneate_unit_guide},'num_bins',8));
% save(['C:\Users\csv057\Documents\MATLAB\MonkeyData\RW\Butter\20180405\neuronStruct\PDTable','_', task, '_', date, '.mat'], 'actPDTable','curvesAct', 'binsAct', 'date', 'task')
%%
close all
isTuned_params = struct('move_corr','vel','CIthresh',pi/3, 'out_signals', 'cuneate_spikes');
isTunedAct = actPDTable.velTuned;
isTunedAct=  isTunedAct & isGracile
actPDTableTuned = actPDTable(isTunedAct,:);

curvesActTuned = curvesAct(isTunedAct,:);

colorsAct = linspecer(length(isTunedAct(isTunedAct)));
h1 = figure;
hold on
%%
maxDist = max(max(curvesActTuned.velCurveCIhigh));
for i = 1:sum(isTunedAct)
    figure(h1)
    plotTuning(actPDTableTuned(i,:), curvesActTuned(i,:),maxDist,colorsAct(i,:),'-')
end

title('Active PDs')
%%
plotAllTuning({curvesActTuned},{actPDTableTuned})