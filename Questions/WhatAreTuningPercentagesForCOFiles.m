clear all
close all

recompute =false;
windowAct= {'idx_movement_on_min', 0; 'idx_movement_on_min',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
suffix = 'MappedNeurons';

if recompute
    for i = [4,5]
        
        windowAct= {'idx_movement_on_min', 0; 'idx_movement_on_min',13}; %Default trimming windows active
        windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
        neurons = generatePaperNeurons(i,windowAct, windowPas, 'MappedNeurons');
        windowAct= {'idx_movement_on_min', 0; 'idx_movement_on_min',40}; %Default trimming windows active
        windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
        neurons = generatePaperNeurons(i, windowAct, windowPas, 'MappedNeurons');
    end
end

 %%
nC = [];
for i =[1,2,3,6,21,9]
    disp(['File number: ', num2str(i)])
    pSwitch.cutoff = pi/2;
    pSwitch.condition = 'act';
    neurons = getPaperNeurons(i, windowAct, windowPas,suffix);
    td = getPaperFiles(i, 10);
    disp(num2str(sum(neurons.sinTunedAct)))
    disp(num2str(sum(neuronStructIsTuned(neurons, pSwitch))))
    neurons.sinTunedAct = [neuronStructIsTuned(neurons, pSwitch)]';
    disp(num2str(sum(neurons.sinTunedAct)))
    
    pSwitch.condition = 'pas';
    disp(num2str(sum(neurons.sinTunedPas)))
    disp(num2str(sum(neuronStructIsTuned(neurons, pSwitch))))
    neurons.sinTunedPas = [neuronStructIsTuned(neurons, pSwitch)]';
    disp(num2str(sum(neurons.sinTunedPas)))
    params.windowAct = windowAct;
    params.windowPas = windowPas;
    
    td = getSpeed(td);
    td = getMoveOnsetAndPeakBackTrace(td);
    td = getMoveOnsetAndPeak(td);
    td = removeUnsorted(td);
    array = getArrayName(td);
    td = smoothSignals(td, struct('signals', [array,'_spikes'], 'calc_rate',true, 'width', .02));
%     neurons = doSensitivityGammaTest(td, neurons,params, i);
%     neurons = computePosBoundedVelSens(td, neurons, params,i);
%     neurons= doBasicSensitivitySplit(neurons, td, params);
%     neurons = doChangepointDelta(neurons, td);
%     neurons = getFStats(neurons, td, params);
%     neurons = doSensitivityPizza(neurons, td, params);
%     td = cutPositionTrialsTD(td);
%     params.windowAct = {'idx_movement_on_min',0; 'idx_positionPas',0};
%     neurons = doSensitivityInPDOnly(neurons, td, params);
%     plotSensitivityInPDOnly(neurons);
%     plotSensitivityByDataPoint(neurons)
%     neurons = getBootstrappedTuningCurvesAroundPeak(td, neurons);
%     saveNeurons(neurons,'MappedNeurons');
    monkey = neurons(1,:).monkey;
    neurons = fixCellArray(neurons);
    if i ==1
        nC = neurons;
    else
        nC = joinNeuronTables({neurons, nC});
    end
end
%%
% nC = checkActPasPDSimiliarity(nC);
% paramsProp.tuningCondition = {'isSorted','isCuneate','tuned','proprio', 'daysDiff2', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'};
% paramsCut.tuningCondition = {'isSorted','isCuneate','tuned','cutaneous', 'daysDiff2', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'};

% paramsProp.tuningCondition = {'isSorted','isCuneate','tuned','proprio', 'daysDiff2', 'sinTunedAct','sinTunedPas', 'handPSTHMan','~handUnit','~distal'};
% paramsCut.tuningCondition = {'isSorted','isCuneate','tuned','cutaneous', 'daysDiff2', 'sinTunedAct','sinTunedPas', 'handPSTHMan','~handUnit','~distal'};

% paramsProp.tuningCondition = {'isSorted','isCuneate','tuned','proprio', 'daysDiff2', 'handPSTHMan','~handUnit','~distal'};
% paramsCut.tuningCondition = {'isSorted','isCuneate','tuned','cutaneous', 'daysDiff2','handPSTHMan','~handUnit','~distal'};

% plotSensitivityPizza(nC, paramsProp)
% plotSensitivityPizza(nC, paramsCut)
% plotSensitivityInPDOnly(nC, paramsProp)
% plotSensitivityInPDOnly(nC, paramsCut)
%%
suffix = 'MappedNeurons';

for i = [1,2,3,6,21,9, 4,5]
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
paramsProp = struct('plotUnitNum', true,'plotModDepth', false, 'plotActVsPasPD', false, ...
'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
'tuningCondition', {{'isSorted','isCuneate','tuned', 'proprio','daysDiff3', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});

% plotSensitivity(nC, paramsProp)
% plotSensitivityGamma(nC, paramsProp)
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

neuronsD = fixCellArray(neuronsD);
neuronsH1 = fixCellArray(neuronsH1);
% neuronsH2 = fixCellArray(neuronsH2);
% neuronsCh = fixCellArray(neuronsCh);
% neuronsArea2 =  joinNeuronTables({neuronsD,neuronsH1,neuronsH2,neuronsCh});
% 
% load([getBasePath(),'Encoding\EncodingMoveOnToEndLinModel.mat']);
% load([getBasePath(), 'Decoding\DecodingMoveOnToEndHanInc.mat'])
%%

paramsProp = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
'tuningCondition', {{'isSorted','isCuneate','tuned', 'proprio','daysDiff3', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
paramsProp.useWindowed = true;
paramsProp.date= 'all';
% paramsProp.minVal = minSens;
paramsProp.useMins = false;
nProp = neuronStructPlot(neuronsCombined, paramsProp);
plotSensitivityPosWindowed(neuronsCombined, paramsProp)
%%
% close all
% sorted = neuronsCombined(logical([neuronsCombined.isSorted]),:);
% encodingB = encoding{1};
% encodingS = encoding{2};
% encodingC = encoding{3};
% encodingH = encoding{4};



%% Fig 3B. Act vs Pas PD
%%
params = struct('plotUnitNum', false,'plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','handPSTHMan','~distal'}});
params.date = 'all';
nBNonHand = neuronStructPlot([neuronsB], params);

nCNonHand = neuronStructPlot([neuronsC], params);

nSNonHand = neuronStructPlot([neuronsS], params);
%% Active vs passive PD comparison
close all
params = struct('plotUnitNum', true,'plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true,...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', true, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotModDepthClassicBoots', true,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct', 'sinTunedPas','handPSTHMan','~distal'}});
params.date = 'all';

nBPDComp = neuronStructPlot([neuronsB], params);

nCPDComp = neuronStructPlot([neuronsC], params);

nSPDComp = neuronStructPlot([neuronsS], params);

neuronsCNPDComp =  joinNeuronTables({neuronsB,neuronsC,neuronsS});

nCNPDComp = neuronStructPlot(neuronsCNPDComp, params);

%% ActPas Dif vs CI
n1 = nCNPDComp;
act1 = n1.actPD.velPD;
actCI = n1.actPD.velPDCI;
pas1 = n1.pasPD.velPD;
pasCI = n1.pasPD.velPDCI;
actWidth = angleDiff(actCI(:,1), actCI(:,2), true, false);
pasWidth = angleDiff(pasCI(:,1), pasCI(:,2), true, false);
totWidth = actWidth+pasWidth;
actPasDif = angleDiff(act1, pas1, true, false);

figure
scatter(totWidth, actPasDif)
lm1 = fitlm(totWidth, actPasDif)
figure
plot(lm1)
%%
figure
histogram(rad2deg(pasWidth))
title('CI width pas')
median(rad2deg(totWidth))
%% Sensitivity vs. PD
figure
scatter(act1, n1.sAct, 32, 'filled')
hold on
scatter(pas1, n1.sPas, 32, 'r', 'filled')
set(gca,'TickDir','out', 'box', 'off')
xlabel('Preferred Direction (rads')
ylabel('Sensitivity (Hz/(cm/s))')
legend({'Active', 'Passive'})

%%
close all
params = struct('plotUnitNum', true,'plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true,...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotModDepthClassicBoots', true,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedPas','handPSTHMan','~distal'}});
params.date = 'all';
neuronsForSpindleComp = neuronStructPlot(neuronsCNPDComp, params);
%%
close all
pdDist = nCNPDComp.actPD.velPD;
pdDistPas = nCNPDComp.pasPD.velPD;
[mad, major, minor, angles] = computeConvMetrics(pdDist);
[madP, majorP, minorP, anglesP] = computeConvMetrics(pdDistPas);
%%
% paramsArea2 = struct('plotUnitNum', false,'plotModDepth', true, 'plotActVsPasPD', true, ...
%     'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
%     'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
%     'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
%     'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
%     'tuningCondition', {{'isSorted','sinTunedAct', 'sinTunedPas'}});
% paramsArea2.date = 'all';
% 
% 
% nS1PDComp = neuronStructPlot(neuronsArea2, paramsArea2);
%%
% load('D:\MonkeyData\CO\Snap\20190829\neuronStruct\Snap08292020SpindleModel.mat');
% neurons = addMusclePDsToNeuronStruct(neurons);

%%
close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct','handPSTHMan','~distal'}});

params.date = 'all';
% neuronsC.encoding =[];
% neuronsS.encoding = [];
neuronsB = fixCellArray(neuronsB);
neuronsC = fixCellArray(neuronsC);
neuronsS = fixCellArray(neuronsS);
nTemp = joinNeuronTables({neuronsB,neuronsC, neuronsS});
nTemp = fixCellArray(nTemp);

nAll = neuronStructPlot(nTemp, params);
nBActNonHand =neuronStructPlot(neuronsB, params);
nCActNonHand = neuronStructPlot(neuronsC, params);
nSActNonHand = neuronStructPlot(neuronsS, params);
%%
close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif',true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','daysDiff3','isSpindle','~distal','handPSTHMan'}});

params.date = 'all';
nProp = neuronStructPlot(nTemp, params);
nProp = removeQuestionableMaps(nProp);
close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','daysDiff3','cutaneous','~distal','handPSTHMan'}});

params.date = 'all';
nCut = neuronStructPlot(nTemp, params);
nCut = removeQuestionableMaps(nCut);
propBase = [nProp.preMove.mean];
cutBase = [nCut.preMove.mean];

figure
subplot(3,1,1)
histogram(propBase,0:10:100)
hold on
histogram(cutBase, 0:10:100)

[h1, p1] = kstest2(propBase, cutBase)
mean(propBase)
mean(cutBase)
set(gca,'TickDir','out', 'box', 'off')
xlabel('Mean Premovement Firing Rate (Hz)')
ylabel('# of neurons')
legend({'Spindle-receiving', 'Cutaneous'})

pdProp = [nProp.actPD.velPD];
ciProp = [nProp.actPD.velPDCI];
pdPropBump = [nProp.pasPD.velPD];
ciPropBump = [nProp.pasPD.velPDCI];
pdCutBump = [nCut.pasPD.velPD];
ciCutBump = [nCut.pasPD.velPDCI];

widthProp = angleDiff(ciProp(:,2), ciProp(:,1), true, false);

pdCut = [nCut.actPD.velPD];
ciCut = [nCut.actPD.velPDCI];
widthCut = angleDiff(ciCut(:,2), ciCut(:,1), true, false);

subplot(3,1,2)
histogram(rad2deg(widthProp), 0:10:180)
hold on
histogram(rad2deg(widthCut), 0:10:180)
set(gca,'TickDir','out', 'box', 'off')
xlabel('Preferred Direction Confidence Interval')
ylabel('# of neurons')
ttest2(widthProp, widthCut)

subplot(3,1,3)
cosSpindle = nProp.r2CosineMove;
cosCut = nCut.r2CosineMove;
histogram(cosSpindle,0:0.05:1.0)
hold on
histogram(cosCut,0:0.05:1.0)
set(gca,'TickDir','out', 'box', 'off')
xlabel('Cosine Fit (R2)')
ylabel('# of neurons')

[h, p] = kstest2(cosSpindle, cosCut)
[h, p] = kstest2(widthProp, widthCut)

%%
% propBaseBump = [nProp.preBump.mean];
% cutBaseBump = [nCut.preBump.mean];
cosSpindleBump = nProp.r2CosineBump;
cosCutBump = nCut.r2CosineBump;
cosCutBump(isnan(cosCutBump)) = [];
widthPropBump = angleDiff(ciPropBump(:,2), ciPropBump(:,1), true, false);
widthCutBump = angleDiff(ciCutBump(:,2), ciCutBump(:,1), true, false);


%%
meanCosSpindle = mean(cosSpindle)
meanCosSpindleBump = mean(cosSpindleBump)
meanCosCut = mean(cosCut)
meanCosCutBump = mean(cosCutBump)

meanWidthProp = rad2deg(mean(widthProp))
meanWidthPropBump = rad2deg(mean(widthPropBump))
meanWidthCut = rad2deg(mean(widthCut))
meanWidthCutBump = rad2deg(mean(widthCutBump))

meanBaseProp = mean(propBase)
meanBaseCut = mean(cutBase)
%%
% params1 = struct('plotUnitNum', true,'plotModDepth', false, 'plotActVsPasPD', true, ...
%     'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
%     'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
%     'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
%     'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
%     'tuningCondition', {{'isSorted', 'sinTunedAct', 'sinTunedPas'}});
% 
% params1.examplePDs = [];
% params1.date = 'all';
% % neuronStructPlot(neuronsH1,params1)
% % neuronStructPlot(neuronsH2,params1)
% % nD1= neuronStructPlot(neuronsD,params1)
% %nCh1 = neuronStructPlot(neuronsCh, params1)
% 
% nArea2Act = neuronStructPlot(neuronsArea2,params1);
%%

close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif',true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct','sinTunedPas','daysDiff2','isSpindle','tuned','~distal','handPSTHMan'}});

params.date = 'all';
nProp = neuronStructPlot(nTemp, params);
% close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct','sinTunedPas','daysDiff2','cutaneous','~distal','handPSTHMan'}});

params.date = 'all';
nCut = neuronStructPlot(nTemp, params);

temp1  = joinNeuronTables({nBActNonHand; nCActNonHand; nSActNonHand});
actNonHandMod = [temp1.modDepthMove, temp1.modDepthBump];
[r2Mod, corCoeffMod] = getUnityR2(actNonHandMod(:,1), actNonHandMod(:,2));
corCoeffMod = corCoeffMod(1,2);
neuronsT = temp1;
actPDs =rad2deg(neuronsT.actPD.velPD);
actPDsHigh = rad2deg(neuronsT.actPD.velPDCI(:,2));
actPDsLow = rad2deg(neuronsT.actPD.velPDCI(:,1));
pasPDs = rad2deg(neuronsT.pasPD.velPD);
pasPDsHigh = rad2deg(neuronsT.pasPD.velPDCI(:,2));
pasPDsLow = rad2deg(neuronsT.pasPD.velPDCI(:,1));

pds = [actPDs, pasPDs];
[actPDs, pasPDs, actPDsHigh, actPDsLow, pasPDsHigh, pasPDsLow] = shiftPDsToLine(actPDs, pasPDs, actPDsHigh,actPDsLow, pasPDsHigh, pasPDsLow);

[r2PD, corrCoeffPD] = getUnityR2(actPDs, pasPDs);
corrCoeffPD = corrCoeffPD(1,2);

%%
close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif',true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct|sinTunedPas','daysDiff3','proprio','tuned','~distal','handPSTHMan'}});

params.date = 'all';
nProp = neuronStructPlot(nTemp, params);


temp1  = nProp;
actNonHandModP = [temp1.modDepthMove, temp1.modDepthBump];
[r2ModP, corCoeffModP] = getUnityR2(actNonHandModP(:,1), actNonHandModP(:,2));
corCoeffModP = corCoeffModP(1,2);

neuronsT = nProp;
actPDs =rad2deg(neuronsT.actPD.velPD);
actPDsHigh = rad2deg(neuronsT.actPD.velPDCI(:,2));
actPDsLow = rad2deg(neuronsT.actPD.velPDCI(:,1));
pasPDs = rad2deg(neuronsT.pasPD.velPD);
pasPDsHigh = rad2deg(neuronsT.pasPD.velPDCI(:,2));
pasPDsLow = rad2deg(neuronsT.pasPD.velPDCI(:,1));

pds = [actPDs, pasPDs];
[actPDs, pasPDs, actPDsHigh, actPDsLow, pasPDsHigh, pasPDsLow] = shiftPDsToLine(actPDs, pasPDs, actPDsHigh,actPDsLow, pasPDsHigh, pasPDsLow);

[r2PD, corrCoeffPDP] = getUnityR2(actPDs, pasPDs);
corrCoeffPDP = corrCoeffPDP(1,2);

%%
% temp1 = compareUniformity(nAll, nArea2Act)

% params1.tuningCondition = {'isSorted','sinTunedAct', 'sinTunedPas'};
% nArea2Pas = neuronStructPlot(neuronsArea2,params1);

% [tabCom] = compareUniformityMeanAbsDev([nBActNonHand; nCActNonHand; nSActNonHand], nArea2Act);
% 

%%
groups = [zeros(height(nBNonHand),1); ones(height(nCNonHand),1); 2*ones(height(nSNonHand),1)];

figure
subplot(4,1,1)
preMove = [[nBNonHand.preMove.mean]'; [nCNonHand.preMove.mean]'; [nSNonHand.preMove.mean]'];
boxplot(preMove, groups)
title('Premovement Firing')
ylabel('Firing Rate (Hz)')
xticklabels('')
set(gca,'TickDir','out', 'box', 'off')
groupsAct = [zeros(height(nBActNonHand),1); ones(height(nCActNonHand),1); 2*ones(height(nSActNonHand),1)];
xticklabels('')
medPreMove = median(preMove);
ylim([0,150])

subplot(4,1,2)
modDepths = [nBNonHand.modDepthMovePeakCI(:,2); nCNonHand.modDepthMovePeakCI(:,2); nSNonHand.modDepthMovePeakCI(:,2)];
modDepthsB = [nBNonHand.modDepthBumpPeakCI(:,2); nCNonHand.modDepthBumpPeakCI(:,2); nSNonHand.modDepthBumpPeakCI(:,2)];
groups = [zeros(height(nBNonHand),1); ones(height(nCNonHand),1); 2*ones(height(nSNonHand),1)];
boxplot([modDepths]', groups)
title('Mod Depths')
ylabel('Modulation Depths (Hz)')
medModDepth = median(modDepths);
xticklabels('')
set(gca,'TickDir','out', 'box', 'off')
ylim([0,100])

subplot(4,1,3)
sens = [mean(nBActNonHand.sActBoot ,2); mean(nCActNonHand.sActBoot ,2); mean(nSActNonHand.sActBoot ,2)];
boxplot(sens, groupsAct)
title('Sensitivity')
ylabel('Sensitivity (Hz/(cm/s))')
xticklabels('')
preMoveMed = median(preMove);
set(gca,'TickDir','out', 'box', 'off')
medSens = median(sens);
% ylim([0,60])

latB = [nBNonHand.cpDifAvg{:}];
latC = [nCNonHand.cpDifAvg{:}];
latS = [nSNonHand.cpDifAvg{:}];
latBDir = [nBNonHand.cpDifAvg];
for i = 1:length(latBDir)
    latBMean(i) = mean(latBDir{i}(latBDir{i}~=0));
end

latB = [latB];
latC = [latC];
latS = [latS];

latB(latB==-500) = [];
latC(latC==-500) = [];
latS(latS==-500) = [];

medLatB = median(latB);
medLatS = median(latS);
medLatC = median(latC);

groupsAct = [zeros(length(latB),1); ones(length(latC),1); 2*ones(length(latS),1)];
lat = [latB';latC';latS'];
subplot(4,1,4)
boxplot(lat, groupsAct)
% ylim([-200, 150])
xticklabels({'Bu', 'Cr', 'Sn'})
set(gca,'TickDir','out', 'box', 'off')
title('Response Latency')
ylabel('Time relative to move onset (ms')
suptitle('Cuneate Neuron Tuning Stats')
medLatAll = median(lat);
% ylim([-200, 150])

figure

subplot(4,1,1)
preMove = [[nBNonHand.preMove.mean]'; [nCNonHand.preMove.mean]'; [nSNonHand.preMove.mean]'];
boxplot(preMove, groups)
title('Premovement Firing')
ylabel('Firing Rate (Hz)')
xticklabels('')
set(gca,'TickDir','out', 'box', 'off')
groupsAct = [zeros(height(nBActNonHand),1); ones(height(nCActNonHand),1); 2*ones(height(nSActNonHand),1)];
xticklabels('')
medPreMove = median(preMove);
ylim([0,150])

subplot(4,1,2)
modDepthsB = [nBNonHand.modDepthBumpPeakCI(:,2); nCNonHand.modDepthBumpPeakCI(:,2); nSNonHand.modDepthBumpPeakCI(:,2)];
groups = [zeros(height(nBNonHand),1); ones(height(nCNonHand),1); 2*ones(height(nSNonHand),1)];
boxplot(modDepthsB, groups)
title('Mod Depths Passive')
ylabel('Modulation Depths (Hz)')
medModDepthB = median(modDepthsB);
groupsAct = [zeros(height(nBActNonHand),1); ones(height(nCActNonHand),1); 2*ones(height(nSActNonHand),1)];
ylim([0,100])
set(gca,'TickDir','out', 'box', 'off')

subplot(4,1,3)
sensB = [mean(nBActNonHand.sPasBoot ,2); mean(nCActNonHand.sPasBoot ,2); mean(nSActNonHand.sPasBoot ,2)];
boxplot(sensB, groupsAct)
xticklabels('')
% ylim([0,60])
title('Sensitivity')
ylabel('Sensitivity (Hz/(cm/s))')
set(gca,'TickDir','out', 'box', 'off')
medSensB = median(sensB);

latB = [nBNonHand.cpDifBumpAvg{:}];
latC = [nCNonHand.cpDifBumpAvg{:}];
latS = [nSNonHand.cpDifBumpAvg{:}];
latBDir = [nBNonHand.cpDifBumpAvg];
for i = 1:length(latBDir)
    latBMean(i) = mean(latBDir{i}(latBDir{i}~=0));
end

latB = [latB];
latC = [latC];
latS = [latS];

latB(latB==-500) = [];
latC(latC==-500) = [];
latS(latS==-500) = [];

medLatB = median(latB);
medLatS = median(latS);
medLatC = median(latC);

groupsAct = [zeros(length(latB),1); ones(length(latC),1); 2*ones(length(latS),1)];
latBump = [latB';latC';latS'];
subplot(4,1,4)
boxplot(latBump, groupsAct)
% ylim([-200, 150])
xticklabels({'Bu', 'Cr', 'Sn'})
set(gca,'TickDir','out', 'box', 'off')
title('Response Latency')
ylabel('Time relative to move onset (ms')
suptitle('Cuneate Neuron Tuning Stats')
medLatAll = median(lat);
%%
edges = -100:10:200;
figure
histogram(lat, edges)
hold on
histogram(latBump, edges)
title('Histogram of latencies')
xlabel('Firing rate change time (ms)')
ylabel('# of neurons')
set(gca,'TickDir','out', 'box', 'off')
effMove= sum(lat<0)/length(lat);
effMus = sum(lat<-75)/length(lat);
%%
premoveMed = median(preMove);
premoveFR25 = quantile(preMove, .25);
premoveFR75 = quantile(preMove, .75);

modDepthMed = median(modDepths);
modDepthFR25 = quantile(modDepths, .25);
modDepthFR75 = quantile(modDepths, .75);

latMed = median(lat);
lat25 = quantile(lat, .25);
lat75 = quantile(lat, .75);

sensMed = median(sens);
sens25 = quantile(sens,.25);
sens75 = quantile(sens, .75);


modDepthBMed = median(modDepthsB);
modDepthBFR25 = quantile(modDepthsB, .25);
modDepthBFR75 = quantile(modDepthsB, .75);

latBMed = median(latB);
latB25 = quantile(latB, .25);
latB75 = quantile(latB, .75);

sensBMed = median(sensB);
sensB25 = quantile(sensB,.25);
sensB75 = quantile(sensB, .75);
%%


params1 = struct('plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', false, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'useNewSensMetric', false, 'plotSensEllipse', false,...
    'tuningCondition', {{'isSorted','sinTunedAct'}});

params1.examplePDs = [];
% nArea2Act = neuronStructPlot(neuronsArea2,params1);

params1.tuningCondition = {'isSorted', 'sinTunedPas'};
% nArea2Pas = neuronStructPlot(neuronsArea2,params1);
% mapped1 = sorted(logical(sorted.isCuneate & [sorted.sameDayMap]),:);
%%
nCombSingleSess = joinNeuronTables({neuronsB1(logical([neuronsB1.isSorted]),:),neuronsC1(logical([neuronsC1.isSorted]),:),neuronsS1(logical([neuronsS1.isSorted]),:)});
clear stats
statsComp1 = makeStatsStruct(nCombSingleSess);
statsB = makeStatsStruct(neuronsB1(logical([neuronsB1.isSorted]),:));
statsC = makeStatsStruct(neuronsC1(logical([neuronsC1.isSorted]),:));
statsS = makeStatsStruct(neuronsS1(logical([neuronsS1.isSorted]),:));

stats(1,:) = statsComp1;
stats(2,:) = statsB;
stats(3,:) = statsC;
stats(4,:) = statsS;

statTab = struct2table(stats, 'RowNames', {'Combined', 'Butter', 'Snap', 'Crackle'});
writetable(statTab, 'D:\MonkeyData\CO\Compiled\neuronStatsSingleSession.xlsx','WriteRowNames', true)

%%
clear stats
statsComp = makeStatsStruct(sorted);
statsB = makeStatsPercentStruct(neuronsB(logical([neuronsB.isSorted]),:));
statsC = makeStatsPercentStruct(neuronsC(logical([neuronsC.isSorted]),:));
statsS = makeStatsPercentStruct(neuronsS(logical([neuronsS.isSorted]),:));

stats(1,:) = statsComp;
stats(2,:) = statsB;
stats(3,:) = statsC;
stats(4,:) = statsS;

statTab = struct2table(stats, 'RowNames', {'Combined', 'Butter', 'Snap', 'Crackle'});
writetable(statTab, 'D:\MonkeyData\CO\Compiled\neuronStatsPercent.xlsx','WriteRowNames', true)
%%

%%
% keyboard
