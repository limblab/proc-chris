% clear all
% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170728\Lando_RW_hold_20170728_001_TD.mat');
% clear all

array = 'cuneate';
date = '20180703';
task= 'RWIso';

% trial_data = parseFileByTrial(cds);
% [tdIdx,td] = getTDidx(trial_data, 'result', 'R');
% params.go_cue_name ='idx_goCueTime';
% params.end_name = 'idx_endTime';
% params.do_onset = false;
td1 = binTD(td, 5);
td1 = removeBadTrials(td1);
td1 = removeBadNeurons(td1);
% td1 = getRWMovements(td1, params);
% td1 = removeBadTrials(td1);
% td_act = trimTD(td1, 'idx_movement_on', 'idx_endTime');
% td_pas = trimTD(td1, 'idx_trial_start', 'idx_movement_on');


%% 
pos = cat(1, td1.pos);
vel = cat(1,td1.vel);
velAct = cat(1, td_act.vel);
figure
histogram(rownorm(vel), 'Normalization', 'probability');
hold on
histogram(rownorm(velAct),'Normalization', 'probability')

%%
close all

paramHeat.array = 'cuneate';
paramHeat.unitsToPlot = 1:length(td(1).([paramHeat.array,'_spikes'])(1,:));
paramHeat.numBounds = 8;
paramHeat.xLimits = [-10,10];
paramHeat.yLimits = [-42, -22];
paramHeat.useJointPCA = false;
paramHeat.plotError = false;
paramHeatAct = paramHeat;
paramHeatPas = paramHeat;
[f1, spikingInBounds, varInBounds] = neuralHeatmap(td_act,paramHeat);
[f2, spikingInBoundsPas, varInBoundsPas] = neuralHeatmap(td_pas, paramHeatPas);

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
% td1 = binTD(tdRw, 5);
% % td1 = removeBadTrials(td1);
% td1 = removeBadNeurons(td1);
paramPDs.out_signals = 'cuneate_spikes';
paramPDs.out_signal_names= td1(1).cuneate_unit_guide;
paramPDs.move_corr = 'force';
paramPDs.num_boot =100;
actPDTable = getTDPDs(td1, paramPDs);
% [curvesAct, binsAct] = getTuningCurves(td1,struct('out_signals',{paramPDs.out_signals},'out_signal_names',{td1(1).RightCuneate_unit_guide},'num_bins',8));
% save(['D:\Data\MonkeyData\PDTables\PDTable','_', task, '_', date, '.mat'], 'actPDTable','curvesAct', 'binsAct', 'date', 'task')

%%
close all
isTuned_params = struct('move_corr','force','CIthresh',pi/3);
isTunedAct = checkIsTuned(actPDTable,isTuned_params);
actPDTableTuned = actPDTable(isTunedAct,:);

curvesActTuned = curvesAct(isTunedAct,:);

colorsAct = linspecer(length(isTunedAct(isTunedAct)));
h1 = figure;
hold on

maxDist = max(max(curvesActTuned.CIhigh));
for i = 1:sum(isTunedAct)
    figure(h1)
    plotTuning(binsAct,actPDTableTuned(i,:),curvesActTuned(i,:),maxDist,colorsAct(i,:),'-', 'forceDir')
end

figure(h1)
title('Active PDs')

move_cor = 'forceDir';
plotAllTuning({curvesActTuned},{actPDTableTuned}, binsAct,[],[], move_cor)