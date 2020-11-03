clear all
close all
% load('D:\MonkeyData\CO\Han\20171122\TD\Han_COactpas_20171122_TD10ms.mat')
% tdS1 = td;
% tdS1 = removeBadOpensim(tdS1);
% tdS1 = tdToBinSize(tdS1, 10);
% 
% if ~isfield(tdS1, 'idx_movement_on')
%     tdS1 = getSpeed(tdS1);
%     params.start_idx =  'idx_goCueTime';
%     params.end_idx = 'idx_endTime';
%     tdS1 = getMoveOnsetAndPeak(tdS1, params);
% end
% 
% 
% start_time_pas = {'idx_bumpTime', 0};
% end_time_pas = {'idx_bumpTime', 13};
% tdS1Pas = tdS1(~isnan([tdS1.idx_bumpTime]));
% tdS1Pas = trimTD(tdS1Pas, start_time_pas, end_time_pas);
% [hVelS1Pas, pasS1SpinSim] = simulateSpindles(tdS1Pas);
% 
% dirBM = 'target_direction';
% start_time_act = {'idx_movement_on', 0};
% end_time_act = {'idx_movement_on', 13};
% tdS1Act = tdS1(isnan([tdS1.idx_bumpTime]));
% tdS1Act = trimTD(tdS1Act, start_time_act, end_time_act);
% [hVelS1Act, actS1SpinSim] = simulateSpindles(tdS1Act);

%%
snapDate = '20190829';
monkey = 'Snap';
recomputeSpindles = false;
mapping = getSensoryMappings(monkey);
%% Load file if needed
tdCN = getPaperFiles(2, 10);
tdCN = removeBadNeurons(tdCN, struct('remove_unsorted', false));
tdCN = removeUnsorted(tdCN);
tdCN = removeGracileTD(tdCN);
tdCN = removeNeuronsBySensoryMap(tdCN, struct('rfFilter', {{'handUnit', true; 'distal', true}})); 
tdCN = removeNeuronsByNeuronStruct(tdCN, struct('flags', {{'~handPSTHMan'}}));
tdCN = smoothSignals(tdCN, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));
%% Data cleaning
tdCN = removeBadOpensim(tdCN);
tdCN = tdToBinSize(tdCN, 10);

if ~isfield(tdCN, 'idx_movement_on')
    tdCN = getSpeed(tdCN);
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    tdCN = getMoveOnsetAndPeak(tdCN, params);
end

% start_time_pas = {'idx_bumpTime', 0};
% end_time_pas = {'idx_bumpTime', 13};
% tdCNPas = tdCN(~isnan([tdCN.idx_bumpTime]));
% tdCNPas = trimTD(tdCNPas, start_time_pas, end_time_pas);
% [hVelCNPas,pasCNSpinSim] = simulateSpindles(tdCNPas);
% [spinConvFiringCNPas, pdCNPas] = simulateSpindleConvergence(hVelCNPas, pasCNSpinSim);

dirBM = 'target_direction';
start_time_act = {'idx_movement_on', 0};
end_time_act = {'idx_movement_on', 13};
tdCNAct = tdCN(isnan([tdCN.idx_bumpTime]));
tdCNAct = trimTD(tdCNAct, start_time_act, end_time_act);
if recomputeSpindles
    [hVelCNAct, actCNSpinSim] = simulateSpindles(tdCNAct);
    [spinConvFiring, pd] = simulateSpindleConvergence(hVelCNAct, actCNSpinSim);
    save(getSpindleSimFilepath(snapDate, start_time_act, end_time_act), 'pd', 'spinConvFiring', '-v7.3');
end
load(getSpindleSimFilepath(snapDate, start_time_act, end_time_act));
[mad, major, angles] = plotConvergenceMetrics(pd);

%%
close all
for i = 1:10
    figure
    polarhistogram(pdCNAct{1}(i,:), 18)
%     figure
%     polarhistogram(pdCNPas{1}(i,:), 18)
end

%%
% forcesInput = [58.2, 38.7, 135.6, 135.6, 116.1, 406.5, 44.8, 174.3, 129.0, 129.0, 129.0, 154.8, 116.1,290.4,135.0, 135.6,116.1,135.6];
% params.forcesInput = mean(forcesInput)*ones(1,18);
% 
% start_time_pas = {'idx_bumpTime', 0};
% end_time_pas = {'idx_bumpTime', 13};
% tdCNPas = tdCN(~isnan([tdCN.idx_bumpTime]));
% tdCNPas = trimTD(tdCNPas, start_time_pas, end_time_pas);
% [hVelCNPasMus,pasCNSpinSimMus] = simulateSpindles(tdCNPas, params);
% [spinConvFiringCNPasMus, pdCNPasMus] = simulateSpindleConvergence(hVelCNPasMus, pasCNSpinSimMus);
% 
% 
% dirBM = 'target_direction';
% start_time_act = {'idx_movement_on', 0};
% end_time_act = {'idx_movement_on', 13};
% tdCNAct = tdCN(isnan([tdCN.idx_bumpTime]));
% tdCNAct = trimTD(tdCNAct, start_time_act, end_time_act);
% [hVelCNActMus, actCNSpinSimMus] = simulateSpindles(tdCNAct, params);
% [spinConvFiringCNActMus, pdCNActMus] = simulateSpindleConvergence(hVelCNActMus, actCNSpinSimMus);
%%

%%
for j = 1:10
for i = plotNums
    figure
    polarhistogram(pdCNPas{j}(i,:), numBins)
    title(['Pas ', num2str(i)])
    
    ph1Pas = polarhistogram(pdCNPas{j}(i,:), numBins, 'FaceColor', 'b', 'FaceAlpha', 1);
    edges = ph1Pas.BinEdges;
    edgeCenters = (edges(2:end)+edges(1:end-1))/2;
    rhoPas = ph1Pas.BinCounts;

    maDPas(i) = norm((rhoPas-mean(rhoPas))/mean(rhoPas),1);
    [xCart, yCart] = pol2cart(edgeCenters, rhoPas);
    ellPas{i} = fit_ellipse(xCart, yCart);
    if ~isempty(ellPas{i}) & ~isempty(ellPas{i}.long_axis)
        majorPas(i,j) = ellPas{i}.long_axis;
        minorPas(i,j) = ellPas{i}.short_axis;
        anglesPas(i,j) = rad2deg(ellPas{i}.phi);
    end
end
end

%%
save('Workspace.mat')

numToPlot = 1:8;
anglesPas1 = -1*anglesPas' +90;
anglesAct1 = -1*anglesAct' +90;
figure
plot(numToPlot, anglesAct1(numToPlot))
ylabel('Angle of Major Axis')
yyaxis right
plot(numToPlot, maDAct(numToPlot))
xlabel('# of muscles combined')
ylabel('Mean Absolute Deviation from Uniformity')
set(gca,'TickDir','out', 'box', 'off')