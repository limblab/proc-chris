
%%
td1 = binTD(td, 5);
% td1 = getPCA(td1, paramPCA);

td_pas = td1(~isnan([td1.idx_bumpTime]));
td_act = td1(isnan([td1.idx_bumpTime]));
td_act = rmfield(td_act, 'idx_bumpTime');
td_act = removeBadTrials(td_act);
td_act = getMoveOnsetAndPeak(td_act, params);
td_act = trimTD(td_act, 'idx_movement_on', {'idx_endTime',2});
td_pas =  trimTD(td_pas, {'idx_bumpTime', 0}, {'idx_bumpTime', 3});



%%
pos_act = cat(1, td_act.pos);
pos_pas = cat(1, td_pas.pos);
figure
scatter(pos_act(:,1), pos_act(:,2), 'r')
hold on
scatter(pos_pas(:,1), pos_pas(:,2), 'b')
%%
close all
td1 = td;
paramHeat.array = array;
paramHeat.unitsToPlot = 1:length(td(1).([paramHeat.array,'_spikes'])(1,:));
paramHeat.numBounds = 7;
paramHeat.xLimits = [-15,15];
paramHeat.yLimits = [-45, -20];
paramHeat.useJointPCA = false;
paramHeat.plotError = false;
[f1, spikingInBounds, varInBounds] = neuralHeatmap(td_act,paramHeat);

paramHeat.xLimits = [-4, 4];
paramHeat.yLimits = [-35,-29];
[f2, spikingInBounds2, varInBounds2] = neuralHeatmap(td_pas, paramHeat);

% 
% for i =  1:length(td(1).([paramHeat.array,'_spikes'])(1,:))
%     paramHeat.unitsToPlot = i;
%     paramHeat.array = 'cuneate';
%     paramHeat.numBounds = 6;
%     paramHeat.xLimits = [-15,15];
%     paramHeat.yLimits = [-45, -20];
%     paramHeat.useJointPCA = false;
%     paramHeat.plotError = false;
%     paramHeat.xLimits = [-15,15];
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
paramPDs.out_signals = [array, '_spikes'];
paramPDs.move_corr = 'vel';
actPDTable = getTDPDs(td_act, paramPDs);

%%
paramPDs.out_signals =[array, '_spikes'];
paramPDs.move_corr = 'vel';
pasPDTable = getTDPDs(td_pas, paramPDs);

%%
[curvesAct, binsAct] = getTuningCurves(td_act,struct('out_signals',{paramPDs.out_signals},'out_signal_names',{td_act(1).cuneate_unit_guide},'num_bins',4));
[curvesPas, binsPas] = getTuningCurves(td_pas, struct('out_signals', {paramPDs.out_signals},'out_signal_names',{td_act(1).cuneate_unit_guide}, 'num_bins',4));
%%
close all
isTuned_params = struct('move_corr','vel','CIthresh',pi/4);
isTunedAct = checkIsTuned(actPDTable,isTuned_params);
actPDTableTuned = actPDTable(isTunedAct,:);
isTunedPas = checkIsTuned(pasPDTable, isTuned_params);
pasPDTableTuned = pasPDTable(isTunedPas, :);

curvesActTuned = curvesAct(isTunedAct,:);
curvesPasTuned = curvesPas(isTunedPas,:);

colorsAct = linspecer(height(actPDTableTuned));
colorsPas = linspecer(height(pasPDTableTuned));
h1 = figure;
hold on
h2 = figure;
hold on
maxDist = max(max(max(curvesActTuned.CIhigh), max(curvesPasTuned.CIhigh)));
for i = 1:sum(isTunedAct)
    figure(h1)
    plotTuning(binsAct,actPDTableTuned(i,:),curvesActTuned(i,:),maxDist,colorsAct(i,:),'-')
end
for i = 1:sum(isTunedPas)
    figure(h2)
    plotTuning(binsAct,pasPDTableTuned(i,:),curvesPasTuned(i,:),maxDist,colorsPas(i,:),'--')
end
figure(h1)
title('Active PDs')
figure(h2)
title('Passive PDs')
%%

            % % plot tuning
%%
plotAllTuning({curvesAct, curvesPas}, {actPDTable, pasPDTable}, binsAct)