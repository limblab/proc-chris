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
recomputeSpindles = true;
recomputeSpindlesPas = true;
num = 2;
%% Load file if needed
tdCN = getPaperFiles(num, 10);
tdCN = removeBadNeurons(tdCN, struct('remove_unsorted', false));
tdCN = removeUnsorted(tdCN);
array = getArrayName(tdCN);
% tdCN = removeGracileTD(tdCN);
% tdCN = removeNeuronsBySensoryMap(tdCN, struct('rfFilter', {{'handUnit', true; 'distal', true}})); 
% tdCN = removeNeuronsByNeuronStruct(tdCN, struct('flags', {{'~handPSTHMan'}}));
tdCN = smoothSignals(tdCN, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .02));
%% Data cleaning
tdCN = removeBadOpensim(tdCN);
[~,tdCN] = getTDidx(tdCN, 'result', 'R');
tdCN = tdToBinSize(tdCN, 10);

if ~isfield(tdCN, 'idx_movement_on')
    tdCN = getSpeed(tdCN);
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    tdCN = getMoveOnsetAndPeak(tdCN, params);
end

if num == 24
    rF = true;
else
    rF = false;
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
start_time_pas = {'idx_bumpTime', 0};
end_time_pas = {'idx_bumpTime', 13};

params.raeedFormat =false;

tdCNAct = tdCN(isnan([tdCN.idx_bumpTime]));
tdCNAct = trimTD(tdCNAct, start_time_act, end_time_act);
tdCNPas = tdCN(~isnan([tdCN.idx_bumpTime]));
tdCNPas = trimTD(tdCNPas, start_time_pas, end_time_pas);
if recomputeSpindles
    params.raeedFormat=  rF;
    [hVelCNAct, actCNSpinSim] = simulateSpindles(tdCNAct, params);
    [spinConvFiring, pdCNAct] = simulateSpindleConvergence(hVelCNAct, actCNSpinSim);
%     save(getSpindleSimFilepath(snapDate, start_time_act, end_time_act), 'pdCNAct','hVelCNAct','actCNSpinSim', 'spinConvFiring', '-v7.3');
elseif recomputeSpindlesPas
    [hVelCNPas, pasCNSpinSim] = simulateSpindles(tdCNPas, params);
    [spinConvFiringPas, pdCNPas] = simulateSpindleConvergence(hVelCNPas, pasCNSpinSim);
%     save(getSpindleSimFilepath(snapDate, start_time_pas, end_time_pas), 'pdCNPas','hVelCNPas','pasCNSpinSim', 'spinConvFiringPas', '-v7.3');
end
%%
load(getSpindleSimFilepath(snapDate, start_time_pas, end_time_pas));
[mad, major, angles] = plotConvergenceMetrics(pdCNPas);


windowAct = {'idx_movement_on_min', 0; 'idx_movement_on_min',40};
windowPas = {'idx_bumpTime', 0; 'idx_bumpTime', 13};
suffix = 'MappedNeurons';

close all
for i = 1:5
%     figure
%     temp1 = pdCNAct{1}(i,:);
%     temp1(temp1 == 0) =[];
%     polarhistogram(temp1, 18)
    figure
    
    polarhistogram(pdCNPas{1}(i,:), linspace(-pi, pi, 18))
    title(num2str(i))

    [madSim(i), majSim(i), minSim(i), gangleSim(i)] = computeConvMetrics(pdCNPas{1}(i,:));
    [madSimPasBoot(i,:), ksMadAPasSim(i), ksMadPasSimBoot(i,:)] = computeConvMetricswBootstrap(pdCNPas{1}(i,:)');

    
end
stdKSMadPasSimBoot = std(ksMadPasSimBoot');
%%
for i = [1,2,3,6,21,9]
    switch i
        case 1
            neuronsB1 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 2
            neuronsS1 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 3
            neuronsC1 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 4
            neuronsD = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 5
            neuronsH1 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 6
            neuronsB2 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 7 
            neuronsC2 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 8
            neuronsC3 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 9
            neuronsS2 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 10
            neuronsH2 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 11
            neuronsCh = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 12
            neuronsR = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 13
            neuronsB1 = getPaperNeurons(i, windowAct, windowPas,suffix);
        case 18
            neuronsC2 = getPaperNeurons(i, windowAct, windowPas, suffix);
        case 21
            neuronsC2 = getPaperNeurons(i, windowAct, windowPas, suffix);
    end
end

%%

neuronsB1 = fixCellArray(neuronsB1);
neuronsB2 = fixCellArray(neuronsB2);
neuronsC1 = fixCellArray(neuronsC1);
neuronsC2 = fixCellArray(neuronsC2);
% neuronsC3 = fixCellArray(neuronsC3);
neuronsS1 = fixCellArray(neuronsS1);
neuronsS2 = fixCellArray(neuronsS2);

neuronsB = joinNeuronTables({neuronsB1, neuronsB2});
neuronsS = joinNeuronTables({neuronsS1, neuronsS2});
neuronsC = joinNeuronTables({neuronsC1, neuronsC2});

neuronsS = fixCellArray(neuronsS);
neuronsC = fixCellArray(neuronsC);


neuronsCombined = joinNeuronTables({neuronsB, neuronsS, neuronsC});
%%
neuronsCN = removeNeuronStructTuning(neuronsCombined, struct('tuningCondition',{{'isSorted','isCuneate','sinTunedAct', 'sinTunedPas','handPSTHMan','~distal'}}));
actPDs = neuronsCN.actPD.velPD;
pasPDs = neuronsCN.pasPD.velPD;

[madCNAct, majCNAct, minCNAct, gangleCNAct] = computeConvMetrics(actPDs);
[madCNPas, majCNPas, minCNPas, gangleCNPas] = computeConvMetrics(pasPDs);
[madCNActBoot,  ksMadActCN, ksMadActCNBoot] = computeConvMetricswBootstrap(actPDs);
[madCNPasBoot,  ksMadPasCN, ksMadPasCNBoot] = computeConvMetricswBootstrap(pasPDs);
ciActCN = quantile(ksMadActCNBoot, [0.025,.5, 0.975]);
ciPasCN = quantile(ksMadPasCNBoot, [0.025,.5, 0.975]);

figure
polarhistogram(pasPDs,18)

%%
%%
load('D:\MonkeyData\CO\Han\20171201\neuronStruct\Han_20171201_COactpas_S1_idx_movement_on_min_0_idx_movement_on_min_40_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_NeuronStruct_MappedNeurons.mat')
pSwitch.cutoff = pi/2;
pSwitch.condition = 'act';
neurons.sinTunedAct = [neuronStructIsTuned(neurons, pSwitch)]';
pSwitch.condition = 'pas';
neurons.sinTunedPas = [neuronStructIsTuned(neurons, pSwitch)]';
neuronsS12 = fixCellArray(getPaperNeurons(5, windowAct, windowPas));
neurons = fixCellArray(neurons);

neuronsS1Comb = joinNeuronTables({neurons, neuronsS12});
neuronsS1 = removeNeuronStructTuning(neuronsS1Comb, struct('tuningCondition',{{'isSorted','sinTunedAct', 'sinTunedPas'}}));

actPDsS1 = neuronsS1.actPD.velPD;
pasPDsS1 = neuronsS1.pasPD.velPD;

figure
polarhistogram(pasPDsS1,18)

[madS1Act, majS1Act, minS1Act, gangleS1Act] = computeConvMetrics(actPDsS1);
[madS1Pas, majS1Pas, minS1Pas, gangleS1Pas] = computeConvMetrics(pasPDsS1);
[madS1ActBoot, ksMadActS1, ksMadActS1Boot] = computeConvMetricswBootstrap(actPDsS1);
[madS1PasBoot, ksMadPasS1, ksMadPasS1Boot] = computeConvMetricswBootstrap(pasPDsS1);

ciActS1 = quantile(ksMadActS1Boot, [0.025,.5, 0.975]);
ciPasS1 = quantile(ksMadPasS1Boot, [0.025,.5, 0.975]);
%%

[h1, p1]= ttest2(ksMadPasS1Boot, ksMadPasCNBoot)

%%
figure
shadedErrorBar(1:5, mean(ksMadPasSimBoot'), std(ksMadPasSimBoot')) 

title('Mean Absolute Deviation of Simulation and Empirical PD distributions')
xlabel('# of combined Muscles')
ylabel('Mean abs. deviation from uniformity')
set(gca,'TickDir','out', 'box', 'off')
ylim([0, 200])
figure
hold on
shadedErrorBar([1,2], [mean(ksMadPasCNBoot'), mean(ksMadPasCNBoot')], [std(ksMadPasCNBoot), std(ksMadPasCNBoot)])
shadedErrorBar([2,3], [mean(ksMadPasS1Boot'), mean(ksMadPasS1Boot')], [std(ksMadPasS1Boot), std(ksMadPasS1Boot)])
title('Mean Absolute Deviation of Simulation and Empirical PD distributions')
xlabel('# of combined Muscles')
ylabel('Mean abs. deviation from uniformity')
set(gca,'TickDir','out', 'box', 'off')
ylim([0, 200])


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