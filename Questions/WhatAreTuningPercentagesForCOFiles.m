clear all
close all
butterDate = '20190129';
snapDate = '20190829';
crackleDate = '20190418';
s1Date = '20190710';
monkeyS1 = 'Duncan';
hanDate = '20171122';
array = 'cuneate';

numBootstraps = 10;

recompute = false;
recomputeBasic = false;
doEncoding=false;
doDecoding = false;
doSensitivity =false;
doCP = false;
doCosine = false;
doSensitivityWindows = false; 
doSensitivityAll = false;
doVelAccSensitivity = false;
visualizeSensitivity = false;
doIncreaseCalc = false;
plotWindowEffects = false;
doSensitivityAllSameZ =false;

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
neuronsCombined = [];
%%
if recompute
for i = 1:3
    
    param1.windowAct =windowAct;
    param1.windowPas =windowPas;
    param1.numBoots = numBootstraps;
    param1.windowInds = true;
    [td, date] = getPaperFiles(i, 10);
    neuronsCO = getPaperNeurons(i, windowAct, windowPas);
    monkey = td(1).monkey;
    filds = fieldnames(td);
    array = filds(contains(filds, '_spikes'),:);
    array = array{1}(1:end-7);
    if ~strcmp(monkey, 'Han') & ~strcmp(monkey, 'Duncan') & ~strcmp(monkey, 'Chips')
        mappingFile = getSensoryMappings(monkey);
        mappingFile = findDistalArm(mappingFile);
        mappingFile = findHandCutaneousUnits(mappingFile);
        mappingFile = findProximalArm(mappingFile);
        mappingFile = findMiddleArm(mappingFile);
        mappingFile = findCutaneous(mappingFile);
    end
    td =tdToBinSize(td, 10);

    if ~isfield(td, 'idx_movement_on')
        td = getSpeed(td);
        params.start_idx =  'idx_goCueTime';
        params.end_idx = 'idx_endTime';
        td = getMoveOnsetAndPeak(td, params);
    end

    param1.windowAct =windowAct;
    param1.windowPas =windowPas;

    td = normalizeTDLabels(td);
    dirsM = [td.target_direction];
    f1 = mod(dirsM, pi/4) ~= 0;
    td(f1) = [];
    for p = 1:length(td)
        td(p).bumpDir= mod(td(p).bumpDir, 360);
    end
    td(isnan([td.idx_movement_on]))= [];
    %%
    if recomputeBasic

        param.arrays = {array};
        param.in_signals = {'vel'};
        param.train_new_model = true;
        param.array = array;
        params.cutoff = pi/3;
        guideT = td(1).([array, '_unit_guide']);
        params.start_idx =  'idx_goCueTime';
        params.end_idx = 'idx_endTime';
        params.array = array;
        param.windowAct= windowAct;
        param.windowPas =windowPas;
        param.date = date;


        %%
        
        [processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td, param);
        neuronsNew = fitCOBumpPSTH(td, neuronsNew, params);
        param.sinTuned= neuronsNew.sinTunedAct | neuronsNew.sinTunedPas;
        neuronsCO = [neuronsNew];
        %%
        if ~strcmp(monkey, 'Han') & ~strcmp(monkey, 'Duncan') & ~strcmp(monkey, 'Chips') 
            neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);

        
        end
            [neuronsCO, mdl] = testForBimodality(neuronsCO);
            cutoffMan = .93;
            cutoffMean = .955;
            neuronsCO.handPSTHMan = [neuronsCO.bimodProjMan] < cutoffMan;
            neuronsCO.handPSTHMean = [neuronsCO.bimodProjMean] < cutoffMean;
    end
    if doCP
        neuronsCO = doChangepoint(neuronsCO, td);
    end
    if doCosine
        neuronsCO = cosineTuning(td, neuronsCO, param1);
        
    end
    if doEncoding
        [encoding{i}, ~, neuronsCO] = compiledCOEncoding(td,struct('array', array), neuronsCO);
        save('D:\MonkeyData\Encoding\EncodingMoveOnToEndLinModelNewFiles.mat', 'encoding');
    end

    if doSensitivity
       neuronsCO = doBasicSensitivity(neuronsCO, td, param1); 
       neuronsCO = doBootstrapSensitivity(neuronsCO, td, param1);
    end
    if doSensitivityAll
       disp('Doing Sensitivity Window Analysis with vel/acc')
       neuronsCO = doBootstrapSensitivityAll(neuronsCO, td, param1); 
    end
    if doSensitivityAllSameZ
        neuronsCO = doBootstrapSensitivityAllSameZ(neuronsCO, td, param1);
    end
    if doVelAccSensitivity
        disp('Doing Sensitivity Window Analysis with vel/acc')
       neuronsCO = doBootstrapSensitivityVelAcc(neuronsCO, td, param1);
    end
    if doSensitivityWindows
       disp('Doing Sensitivity Window Analysis')
       neuronsCO = doBootstrapSensitivityWindows(neuronsCO, td, param1); 
        
    end
    if doIncreaseCalc
        disp('Doing neuron increase calc')
        paramsInc = struct('windowAct', {windowAct}, 'windowPas', {windowPas});
        neuronsCO = doNeuronsIncreaseAllDirs(neuronsCO, td, paramsInc);
    end
    
    if plotWindowEffects
        neuronsCO = plotVelWindowing(neuronsCO, td, param1);
    end
    saveNeurons(neuronsCO,'MappedNeurons');

    if doDecoding
        if  ~strcmp(monkey, 'Han') & ~strcmp(monkey, 'Duncan') & ~strcmp(monkey, 'Chips')          
            td = removeBadNeurons(td, struct('remove_unsorted', false));
            td = removeUnsorted(td);
            td = removeGracileTD(td);
            td = removeNeuronsBySensoryMap(td, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
%             td = removeNeuronsByNeuronStruct(td, struct('flags', {{'~handPSTHMan'}}));
        end
        [decoding{i}, pred{i}] = compiledCODecoding(td, struct('array', array));
        save('D:\MonkeyData\Decoding\DecodingMoveOnToEndHanIncNewFiles.mat', 'decoding', 'pred');
    end
    if visualizeSensitivity
       neuronsCO = visualizeBasicSensitivity(neuronsCO, td, param1);
    end
end
end 
%%
for i = 1:12
    disp(['File number: ', num2str(i)])
    pSwitch.cutoff = pi/2;
    pSwitch.condition = 'act';
    neurons = getPaperNeurons(i, windowAct, windowPas);
    
    disp(num2str(sum(neurons.sinTunedAct)))
    disp(num2str(sum(neuronStructIsTuned(neurons, pSwitch))))
    neurons.sinTunedAct = [neuronStructIsTuned(neurons, pSwitch)]';
    disp(num2str(sum(neurons.sinTunedAct)))
    
    
    pSwitch.condition = 'pas';
    disp(num2str(sum(neurons.sinTunedPas)))
    disp(num2str(sum(neuronStructIsTuned(neurons, pSwitch))))
    neurons.sinTunedPas = [neuronStructIsTuned(neurons, pSwitch)]';
    disp(num2str(sum(neurons.sinTunedPas)))
    
    saveNeurons(neurons,'MappedNeurons');
    monkey = neurons(1,:).monkey;
    if visualizeSensitivity
        if ~strcmp(monkey, 'Han') & ~strcmp(monkey, 'Duncan') & ~strcmp(monkey, 'Chips')
        params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
        
        else
            params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
            'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
            'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
            'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
            'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
            'tuningCondition', {{'isSorted','tuned','sinTunedAct|sinTunedPas'}});
        end
       params.date = 'all';

%        neurons = visualizeBasicSensitivity(neurons, td, param1);
       
       [nNeg(i), nPos(i), nNoDif(i)] = plotSensitivity(neurons, params);
       [nNegAll(i), nPosAll(i), nNoDifAll(i)] = plotSensitivityAll(neurons, params);
       [nNegWin(i,:), nPosWin(i,:), nNoDifWin(i,:)] = plotSensitivityWindows(neurons, params);
    end
end
%%
for i = 1:12
    switch i
        case 1
            neuronsB1 = getPaperNeurons(i, windowAct, windowPas);
        case 2
            neuronsS1 = getPaperNeurons(i, windowAct, windowPas);
        case 3
            neuronsC1 = getPaperNeurons(i, windowAct, windowPas);
        case 4
            neuronsD = getPaperNeurons(i, windowAct, windowPas);
        case 5
            neuronsH1 = getPaperNeurons(i, windowAct, windowPas);
        case 6
            neuronsB2 = getPaperNeurons(i, windowAct, windowPas);
        case 7 
            neuronsC2 = getPaperNeurons(i, windowAct, windowPas);
        case 8
            neuronsC3 = getPaperNeurons(i, windowAct, windowPas);
        case 9
            neuronsS2 = getPaperNeurons(i, windowAct, windowPas);
        case 10
            neuronsH2 = getPaperNeurons(i, windowAct, windowPas);
        case 11
            neuronsCh = getPaperNeurons(i, windowAct, windowPas);
        case 12
            neuronsR = getPaperNeurons(i, windowAct, windowPas);
    end
end



neuronsB1 = fixCellArray(neuronsB1);
neuronsB2 = fixCellArray(neuronsB2);
neuronsC1 = fixCellArray(neuronsC1);
neuronsC2 = fixCellArray(neuronsC2);
neuronsC3 = fixCellArray(neuronsC3);
neuronsS1 = fixCellArray(neuronsS1);
neuronsS2 = fixCellArray(neuronsS2);

neuronsB = joinNeuronTables({neuronsB1, neuronsB2});
neuronsS = joinNeuronTables({neuronsS1, neuronsS2});
neuronsC = joinNeuronTables({neuronsC1, neuronsC3});

neuronsS = fixCellArray(neuronsS);
neuronsC = fixCellArray(neuronsC);


neuronsCombined = joinNeuronTables({neuronsB, neuronsS, neuronsC});

neuronsD = fixCellArray(neuronsD);
neuronsH1 = fixCellArray(neuronsH1);
neuronsH2 = fixCellArray(neuronsH2);
neuronsCh = fixCellArray(neuronsCh);
neuronsArea2 =  joinNeuronTables({neuronsD,neuronsH1,neuronsH2,neuronsCh});

load([getBasePath(),'Encoding\EncodingMoveOnToEndLinModel.mat']);
load([getBasePath(), 'Decoding\DecodingMoveOnToEndHanInc.mat'])

%%
close all
sorted = neuronsCombined(logical([neuronsCombined.isSorted]),:);
encodingB = encoding{1};
encodingS = encoding{2};
encodingC = encoding{3};
encodingH = encoding{4};



%% Fig 3B. Act vs Pas PD
%%
params = struct('plotUnitNum', false,'plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','handPSTHMan','~distal'}});

nBNonHand = neuronStructPlot([neuronsB], params);

nCNonHand = neuronStructPlot([neuronsC], params);

nSNonHand = neuronStructPlot([neuronsS], params);
%% Active vs passive PD comparison
params = struct('plotUnitNum', true,'plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true,...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct', 'sinTunedPas','handPSTHMan','~distal'}});
params.date = 'all';

nBPDComp = neuronStructPlot([neuronsB], params);

nCPDComp = neuronStructPlot([neuronsC], params);

nSPDComp = neuronStructPlot([neuronsS], params);

neuronsCNPDComp =  joinNeuronTables({neuronsB,neuronsC,neuronsS});

nCNPDComp = neuronStructPlot(neuronsCNPDComp, params);

paramsArea2 = struct('plotUnitNum', false,'plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','sinTunedAct', 'sinTunedPas'}});
paramsArea2.date = 'all';


nS1PDComp = neuronStructPlot(neuronsArea2, paramsArea2);



%%
close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', true, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct','handPSTHMan','~distal'}});

params.date = 'all';
nTemp = [neuronsB;neuronsC; neuronsS];
nTemp = fixCellArray(nTemp);
neuronsB = fixCellArray(neuronsB);
neuronsC = fixCellArray(neuronsC);
neuronsS = fixCellArray(neuronsS);
nAll = neuronStructPlot(nTemp, params);
nBActNonHand =neuronStructPlot(neuronsB, params);
nCActNonHand = neuronStructPlot(neuronsC, params);
nSActNonHand = neuronStructPlot(neuronsS, params);

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
temp1  = [nBActNonHand; nCActNonHand; nSActNonHand];
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
% temp1 = compareUniformity(nAll, nArea2Act)

% params1.tuningCondition = {'isSorted','sinTunedAct', 'sinTunedPas'};
% nArea2Pas = neuronStructPlot(neuronsArea2,params1);

% [tabCom] = compareUniformityMeanAbsDev([nBActNonHand; nCActNonHand; nSActNonHand], nArea2Act);
% 

%%
figure
subplot(4,1,2)
modDepths = [nBNonHand.modDepthMove; nCNonHand.modDepthMove; nSNonHand.modDepthMove];
groups = [zeros(height(nBNonHand),1); ones(height(nCNonHand),1); 2*ones(height(nSNonHand),1)];
boxplot(modDepths, groups)
title('Mod Depths')
ylabel('Modulation Depths (Hz)')
medModDepth = median(modDepths);

set(gca,'TickDir','out', 'box', 'off')
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

subplot(4,1,3)
sens = [mean(nBActNonHand.sActAllBoot ,2); mean(nCActNonHand.sActAllBoot ,2); mean(nSActNonHand.sActAllBoot ,2)];
boxplot(sens, groupsAct)
title('Sensitivity')
ylabel('Sensitivity (Hz/(cm/s))')
xticklabels('')
preMoveMed = median(preMove);
set(gca,'TickDir','out', 'box', 'off')
medSens = median(sens);

latB = [nBNonHand.cpAvg{:}];
latC = [nCNonHand.cpAvg{:}];
latS = [nSNonHand.cpAvg{:}];


latB = [latB];
latC = [latC];
latS = [latS];

latB = [latB];
latC = [latC];
latS = [latS];


latB = [latB];
latC = [latC];
latS = [latS];

latB(latB==0) = [];
latC(latC==0) = [];
latS(latS==0) = [];

medLatB = median(latB);
medLatS = median(latS);
medLatC = median(latC);

groupsAct = [zeros(length(latB),1); ones(length(latC),1); 2*ones(length(latS),1)];
lat = ([latB';latC';latS']-30)*10;
subplot(4,1,4)
boxplot(lat, groupsAct)
ylim([-200, 150])
xticklabels({'Bu', 'Cr', 'Sn'})
set(gca,'TickDir','out', 'box', 'off')
title('Response Latency')
ylabel('Time relative to move onset (ms')
suptitle('Cuneate Neuron Tuning Stats')
medLatAll = median(lat);
%%
premoveFR25 = quantile(preMove, .25);
premoveFR75 = quantile(preMove, .75);

modDepthFR25 = quantile(modDepths, .25);
modDepthFR75 = quantile(modDepths, .75);

lat25 = quantile(lat, .25);
lat75 = quantile(lat, .75);

sens25 = quantile(sens,.25);
sens75 = quantile(sens, .75);

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
mapped1 = sorted(logical(sorted.isCuneate & [sorted.sameDayMap]),:);
%%
clear stats
stats(1).total = height(sorted);
stats(1).cuneate = sum(sorted.isCuneate);
stats(1).tuned = sum(sorted.isCuneate & sorted.tuned);
stats(1).cuneateTuned = sum(sorted.isCuneate & (sorted.fMove <0.01 | sorted.fBump <0.01));
stats(1).moveTuned = sum(sorted.isCuneate & sorted.fMove < 0.01);
stats(1).bumpTuned = sum(sorted.isCuneate & sorted.fBump < 0.01);
stats(1).sinTunedAct = sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedAct);
stats(1).sinTunedPas = sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedPas);
stats(1).sinTunedBoth = sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedPas & sorted.sinTunedPas);
stats(1).spindle = sum(sorted.isCuneate & sorted.isSpindle & sorted.sameDayMap);
stats(1).proximal = sum(sorted.isCuneate & sorted.proximal& sorted.sameDayMap);
stats(1).midArm = sum(sorted.isCuneate & sorted.midArm& sorted.sameDayMap);
stats(1).distal = sum(sorted.isCuneate & sorted.distal& sorted.sameDayMap);
stats(1).handUnit = sum(sorted.isCuneate & sorted.handUnit& sorted.sameDayMap);
stats(1).skin = sum(sorted.isCuneate & sorted.cutaneous & sorted.sameDayMap);
stats(1).proprioceptive = sum(sorted.isCuneate & sorted.proprio & sorted.sameDayMap);
stats(1).mapped = sum(sorted.isCuneate & sorted.sameDayMap);

neuronsB = neuronsB(logical(neuronsB.isSorted),:);
stats(2).total = height(neuronsB);
stats(2).cuneate = sum(neuronsB.isCuneate);
stats(2).tuned = sum(neuronsB.isCuneate & neuronsB.tuned);
stats(2).cuneateTuned = sum(neuronsB.isCuneate & (neuronsB.fMove <0.01 | neuronsB.fBump <0.01));
stats(2).moveTuned = sum(neuronsB.isCuneate & neuronsB.fMove < 0.01);
stats(2).bumpTuned = sum(neuronsB.isCuneate & neuronsB.fBump < 0.01);
stats(2).sinTunedAct = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedAct);
stats(2).sinTunedPas = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedPas);
stats(2).sinTunedBoth = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedPas & neuronsB.sinTunedPas);
stats(2).spindle = sum(neuronsB.isCuneate & neuronsB.isSpindle & neuronsB.sameDayMap);
stats(2).proximal = sum(neuronsB.isCuneate & neuronsB.proximal& neuronsB.sameDayMap);
stats(2).midArm = sum(neuronsB.isCuneate & neuronsB.midArm& neuronsB.sameDayMap);
stats(2).distal = sum(neuronsB.isCuneate & neuronsB.distal& neuronsB.sameDayMap);
stats(2).handUnit = sum(neuronsB.isCuneate & neuronsB.handUnit& neuronsB.sameDayMap);
stats(2).skin = sum(neuronsB.isCuneate & neuronsB.cutaneous & neuronsB.sameDayMap);
stats(2).proprioceptive = sum(neuronsB.isCuneate & neuronsB.proprio & neuronsB.sameDayMap);
stats(2).mapped = sum(neuronsB.isCuneate & neuronsB.sameDayMap);

neuronsS = neuronsS(logical(neuronsS.isSorted),:);
stats(3).total = height(neuronsS);
stats(3).cuneate = sum(neuronsS.isCuneate);
stats(3).tuned = sum(neuronsS.isCuneate & neuronsS.tuned);
stats(3).cuneateTuned = sum(neuronsS.isCuneate & (neuronsS.fMove <0.01 | neuronsS.fBump <0.01));
stats(3).moveTuned = sum(neuronsS.isCuneate & neuronsS.fMove < 0.01);
stats(3).bumpTuned = sum(neuronsS.isCuneate & neuronsS.fBump < 0.01);
stats(3).sinTunedAct = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedAct);
stats(3).sinTunedPas = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedPas);
stats(3).sinTunedBoth = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedPas & neuronsS.sinTunedPas);
stats(3).spindle = sum(neuronsS.isCuneate & neuronsS.isSpindle & neuronsS.sameDayMap);
stats(3).proximal = sum(neuronsS.isCuneate & neuronsS.proximal& neuronsS.sameDayMap);
stats(3).midArm = sum(neuronsS.isCuneate & neuronsS.midArm& neuronsS.sameDayMap);
stats(3).distal = sum(neuronsS.isCuneate & neuronsS.distal& neuronsS.sameDayMap);
stats(3).handUnit = sum(neuronsS.isCuneate & neuronsS.handUnit& neuronsS.sameDayMap);
stats(3).skin = sum(neuronsS.isCuneate & neuronsS.cutaneous & neuronsS.sameDayMap);
stats(3).proprioceptive = sum(neuronsS.isCuneate & neuronsS.proprio & neuronsS.sameDayMap);
stats(3).mapped = sum(neuronsS.isCuneate & neuronsS.sameDayMap);

neuronsC = neuronsC(logical(neuronsC.isSorted),:);
stats(4).total = height(neuronsC);
stats(4).cuneate = sum(neuronsC.isCuneate);
stats(4).tuned = sum(neuronsC.isCuneate & neuronsC.tuned);
stats(4).cuneateTuned = sum(neuronsC.isCuneate & (neuronsC.fMove <0.01 | neuronsC.fBump <0.01));
stats(4).moveTuned = sum(neuronsC.isCuneate & neuronsC.fMove < 0.01);
stats(4).bumpTuned = sum(neuronsC.isCuneate & neuronsC.fBump < 0.01);
stats(4).sinTunedAct = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedAct);
stats(4).sinTunedPas = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedPas);
stats(4).sinTunedBoth = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedPas & neuronsC.sinTunedPas);
stats(4).spindle = sum(neuronsC.isSpindle & neuronsC.isCuneate & neuronsC.sameDayMap);
stats(4).proximal = sum(neuronsC.proximal & neuronsC.isCuneate& neuronsC.sameDayMap);
stats(4).midArm = sum(neuronsC.midArm & neuronsC.isCuneate& neuronsC.sameDayMap);
stats(4).distal = sum(neuronsC.distal & neuronsC.isCuneate& neuronsC.sameDayMap);
stats(4).handUnit = sum(neuronsC.handUnit & neuronsC.isCuneate& neuronsC.sameDayMap);
stats(4).skin = sum(neuronsC.cutaneous & neuronsC.isCuneate & neuronsC.sameDayMap);
stats(4).proprioceptive = sum(neuronsC.proprio & neuronsC.isCuneate & neuronsC.sameDayMap);
stats(4).mapped = sum(neuronsC.isCuneate & neuronsC.sameDayMap);

statTab = struct2table(stats, 'RowNames', {'Combined', 'Butter', 'Snap', 'Crackle'});
writetable(statTab, 'D:\MonkeyData\CO\Compiled\neuronStats.xlsx','WriteRowNames', true)

%%
clear stats
stats(1).total = height(sorted);
stats(1).cuneate = sum(sorted.isCuneate);
stats(1).tuned = 100*sum(sorted.isCuneate & sorted.tuned)/stats(1).cuneate;
stats(1).cuneateTuned = 100*round(sum(sorted.isCuneate & (sorted.fMove <0.01 | sorted.fBump <0.01))/stats(1).cuneate,2);
stats(1).moveTuned = 100*round(sum(sorted.isCuneate & sorted.fMove < 0.01)/stats(1).cuneate,2);
stats(1).bumpTuned = 100*round(sum(sorted.isCuneate & sorted.fBump < 0.01)/stats(1).cuneate,2);
stats(1).sinTunedAct = 100*round(sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedAct)/stats(1).cuneate,2);
stats(1).sinTunedPas = 100*round(sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedPas)/stats(1).cuneate,2);
stats(1).sinTunedBoth = 100*round(sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedPas & sorted.sinTunedPas)/stats(1).cuneate,2);
stats(1).mapped = sum(sorted.isCuneate & sorted.sameDayMap);
stats(1).spindle = 100*round(sum(sorted.isCuneate & sorted.isSpindle & sorted.sameDayMap)/ stats(1).mapped,2);
stats(1).proximal = 100*round(sum(sorted.isCuneate & sorted.proximal& sorted.sameDayMap)/ stats(1).mapped,2);
stats(1).midArm = 100*round(sum(sorted.isCuneate & sorted.midArm& sorted.sameDayMap)/ stats(1).mapped,2);
stats(1).distal = 100*round(sum(sorted.isCuneate & sorted.distal& sorted.sameDayMap)/ stats(1).mapped,2);
stats(1).handUnit = 100*round(sum(sorted.isCuneate & sorted.handUnit& sorted.sameDayMap)/ stats(1).mapped,2);
stats(1).skin = 100*round(sum(sorted.isCuneate & sorted.cutaneous & sorted.sameDayMap)/ stats(1).mapped,2);
stats(1).proprioceptive = 100*round(sum(sorted.isCuneate & sorted.proprio & sorted.sameDayMap)/ stats(1).mapped,2);

stats(2).total = height(neuronsB);
stats(2).cuneate = sum(neuronsB.isCuneate);
stats(2).tuned = 100*round(sum(neuronsB.isCuneate & neuronsB.tuned)/stats(2).cuneate,2);
stats(2).cuneateTuned = 100*round(sum(neuronsB.isCuneate & (neuronsB.fMove <0.01 | neuronsB.fBump <0.01))/stats(2).cuneate,2);
stats(2).moveTuned = 100*round(sum(neuronsB.isCuneate & neuronsB.fMove < 0.01)/stats(2).cuneate,2);
stats(2).bumpTuned = 100*round(sum(neuronsB.isCuneate & neuronsB.fBump < 0.01)/stats(2).cuneate,2);
stats(2).sinTunedAct = 100*round(sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedAct)/stats(2).cuneate,2);
stats(2).sinTunedPas = 100*round(sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedPas)/stats(2).cuneate,2);
stats(2).sinTunedBoth = 100*round(sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedPas & neuronsB.sinTunedPas)/stats(2).cuneate,2);
stats(2).mapped = sum(neuronsB.isCuneate & neuronsB.sameDayMap);
stats(2).spindle = 100*round(sum(neuronsB.isCuneate & neuronsB.isSpindle & neuronsB.sameDayMap)/stats(2).mapped,2);
stats(2).proximal = 100*round(sum(neuronsB.isCuneate & neuronsB.proximal& neuronsB.sameDayMap)/stats(2).mapped,2);
stats(2).midArm = 100*round(sum(neuronsB.isCuneate & neuronsB.midArm& neuronsB.sameDayMap)/stats(2).mapped,2);
stats(2).distal = 100*round(sum(neuronsB.isCuneate & neuronsB.distal& neuronsB.sameDayMap)/stats(2).mapped,2);
stats(2).handUnit = 100*round(sum(neuronsB.isCuneate & neuronsB.handUnit& neuronsB.sameDayMap)/stats(2).mapped,2);
stats(2).skin = 100*round(sum(neuronsB.isCuneate & neuronsB.cutaneous & neuronsB.sameDayMap)/stats(2).mapped,2);
stats(2).proprioceptive = 100*round(sum(neuronsB.isCuneate & neuronsB.proprio & neuronsB.sameDayMap)/stats(2).mapped,2);

stats(3).total = height(neuronsS);
stats(3).cuneate = sum(neuronsS.isCuneate);
stats(3).tuned = 100*round(sum(neuronsS.isCuneate & neuronsS.tuned)/stats(3).cuneate,2);
stats(3).cuneateTuned = 100*round(sum(neuronsS.isCuneate & (neuronsS.fMove <0.01 | neuronsS.fBump <0.01))/stats(3).cuneate,2);
stats(3).moveTuned = 100*round(sum(neuronsS.isCuneate & neuronsS.fMove < 0.01)/stats(3).cuneate,2);
stats(3).bumpTuned = 100*round(sum(neuronsS.isCuneate & neuronsS.fBump < 0.01)/stats(3).cuneate,2);
stats(3).sinTunedAct = 100*round(sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedAct)/stats(3).cuneate,2);
stats(3).sinTunedPas = 100*round(sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedPas)/stats(3).cuneate,2);
stats(3).sinTunedBoth = 100*round(sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedPas & neuronsS.sinTunedPas)/stats(3).cuneate,2);
stats(3).mapped = sum(neuronsS.isCuneate & neuronsS.sameDayMap);
stats(3).spindle = 100*round(sum(neuronsS.isCuneate & neuronsS.isSpindle & neuronsS.sameDayMap)/stats(3).mapped,2);
stats(3).proximal = 100*round(sum(neuronsS.isCuneate & neuronsS.proximal& neuronsS.sameDayMap)/stats(3).mapped,2);
stats(3).midArm = 100*round(sum(neuronsS.isCuneate & neuronsS.midArm& neuronsS.sameDayMap)/stats(3).mapped,2);
stats(3).distal = 100*round(sum(neuronsS.isCuneate & neuronsS.distal& neuronsS.sameDayMap)/stats(3).mapped,2);
stats(3).handUnit = 100*round(sum(neuronsS.isCuneate & neuronsS.handUnit& neuronsS.sameDayMap)/stats(3).mapped,2);
stats(3).skin = 100*round(sum(neuronsS.isCuneate & neuronsS.cutaneous & neuronsS.sameDayMap)/stats(3).mapped,2);
stats(3).proprioceptive = 100*round(sum(neuronsS.isCuneate & neuronsS.proprio & neuronsS.sameDayMap)/stats(3).mapped,2);

stats(4).total = height(neuronsC);
stats(4).cuneate = sum(neuronsC.isCuneate);
stats(4).tuned = 100*round(sum(neuronsC.isCuneate & neuronsC.tuned)/stats(4).cuneate,2);
stats(4).cuneateTuned = 100*round(sum(neuronsC.isCuneate & (neuronsC.fMove <0.01 | neuronsC.fBump <0.01))/stats(4).cuneate,2);
stats(4).moveTuned = 100*round(sum(neuronsC.isCuneate & neuronsC.fMove < 0.01)/stats(4).cuneate,2);
stats(4).bumpTuned = 100*round(sum(neuronsC.isCuneate & neuronsC.fBump < 0.01)/stats(4).cuneate,2);
stats(4).sinTunedAct = 100*round(sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedAct)/stats(4).cuneate,2);
stats(4).sinTunedPas = 100*round(sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedPas)/stats(4).cuneate,2);
stats(4).sinTunedBoth = 100*round(sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedPas & neuronsC.sinTunedPas)/stats(4).cuneate,2);
stats(4).mapped = sum(neuronsC.isCuneate & neuronsC.sameDayMap);
stats(4).spindle = 100*round(sum(neuronsC.isSpindle & neuronsC.isCuneate & neuronsC.sameDayMap)/stats(4).mapped,2);
stats(4).proximal = 100*round(sum(neuronsC.proximal & neuronsC.isCuneate& neuronsC.sameDayMap)/stats(4).mapped,2);
stats(4).midArm = 100*round(sum(neuronsC.midArm & neuronsC.isCuneate& neuronsC.sameDayMap)/stats(4).mapped,2);
stats(4).distal = 100*round(sum(neuronsC.distal & neuronsC.isCuneate& neuronsC.sameDayMap)/stats(4).mapped,2);
stats(4).handUnit = 100*round(sum(neuronsC.handUnit & neuronsC.isCuneate& neuronsC.sameDayMap)/stats(4).mapped,2);
stats(4).skin = 100*round(sum(neuronsC.cutaneous & neuronsC.isCuneate & neuronsC.sameDayMap)/stats(4).mapped,2);
stats(4).proprioceptive = 100*round(sum(neuronsC.proprio & neuronsC.isCuneate & neuronsC.sameDayMap)/stats(4).mapped,2);

statTab = struct2table(stats, 'RowNames', {'Combined', 'Butter', 'Snap', 'Crackle'});
writetable(statTab, 'D:\MonkeyData\CO\Compiled\neuronStatsPercent.xlsx','WriteRowNames', true)
%%
x = sorted(logical([sorted.isCuneate]),:);
y = neuronsArea2;

neuronsB= x(strcmp(x.monkey, 'Butter'),:);
neuronsS = x(strcmp(x.monkey, 'Snap'),:);
neuronsC = x(strcmp(x.monkey, 'Crackle'),:);
%%
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', true, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','tuned' 'handPSTHMan','~distal'}});
params.date = 'all';
nC = neuronStructPlot(neuronsC, params);
nB = neuronStructPlot(neuronsB, params);
nS = neuronStructPlot(neuronsS, params);
x = [nC; nB; nS];

params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', false, 'useModDepths', true, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','sinTunedAct', 'sinTunedPas'}});

nD = neuronStructPlot(neuronsD, params);
nH = neuronStructPlot(neuronsH1, params);
y = [nD;nH];
%%

%%
%%
close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false, 'plotMaxSens', false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', false,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
sorted = fixCellArray(sorted);

params.date = 'all';
nSensInc = neuronStructPlot(sorted, params);

params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});

params.date = 'all';



paramsS1T = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', false,...
    'tuningCondition', {{'isSorted','tuned','sinTunedAct|sinTunedPas'}});

neuronStructPlot(sorted, params);

neuronsB1S = neuronStructPlot(neuronsB1,params);
neuronsB2S = neuronStructPlot(neuronsB2,params);
neuronsBAll = joinNeuronTables({neuronsB1S, neuronsB2S});

neuronsC1S = neuronStructPlot(neuronsC1,params);
neuronsC2S = neuronStructPlot(neuronsC2,params);
% neuronsC3S = neuronStructPlot(neuronsC3,params);
neuronsCAll  = joinNeuronTables({neuronsC1S, neuronsC2S});

neuronsS1S = neuronStructPlot(neuronsS1,params);
neuronsS2S = neuronStructPlot(neuronsS2,params);
neuronsSAll = joinNeuronTables({neuronsS1S, neuronsS2S});


neuronsInc = joinNeuronTables({neuronsB1S, neuronsB2S, neuronsC1S, neuronsC2S, neuronsS1S, neuronsS2S});

difBoot = neuronsInc.sDifAllBoot;
sDifBoot = sort(difBoot')';
% sDifBootB = sort(neuronsBAll.sDifBoot);
% sDifBootC = sort(neuronsCAll.sDifBoot);
% sDifBootS = sort(neuronsSAll.sDifBoot);

sDifBootB = sort(neuronsB1S.sDifBoot);
sDifBootC = sort(neuronsC1S.sDifBoot);
sDifBootS = sort(neuronsS1S.sDifBoot);

nNeg = sum(quantile(sDifBoot', .025) > 0);
nPos = sum(quantile(sDifBoot', .975) < 0);
nNoDif = sum(quantile(sDifBoot', .025) < 0 & quantile(sDifBoot', 0.975)>0);

nNegB = sum(quantile(sDifBootB', .025) > 0);
nPosB = sum(quantile(sDifBootB', .975) < 0);
nNoDifB = sum(quantile(sDifBootB', .025) < 0 & quantile(sDifBootB', 0.975)>0);

nNegS = sum(quantile(sDifBootS', .025) > 0);
nPosS = sum(quantile(sDifBootS', .975) < 0);
nNoDifS = sum(quantile(sDifBootS', .025) < 0 & quantile(sDifBootS', 0.975)>0);

nNegC = sum(quantile(sDifBootC', .025) > 0);
nPosC = sum(quantile(sDifBootC', .975) < 0);
nNoDifC = sum(quantile(sDifBootC', .025) < 0 & quantile(sDifBootC', 0.975)>0);

% params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
%     'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
%     'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
%     'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
%     'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,'plotSensitivity', true,...
%     'tuningCondition', {{'isSorted','tuned', 'sinTunedAct|sinTunedPas'}});
% 
% params.date = 'all';
% neuronsArea2Sens  = neuronStructPlot(neuronsArea2, params);

%%


params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','isProprioceptive', 'sameDayMap','tuned','sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});

params.date = 'all';

neuronsB1S = neuronStructPlot(neuronsB1,params);
neuronsB2S = neuronStructPlot(neuronsB2,params);
neuronsC1S = neuronStructPlot(neuronsC1,params);
neuronsC2S = neuronStructPlot(neuronsC2,params);
neuronsS1S = neuronStructPlot(neuronsS1,params);
neuronsS2S = neuronStructPlot(neuronsS2,params);

butP1 = [neuronsB1S.sAct, neuronsB1S.sPas];
butP2 = [neuronsB2S.sAct, neuronsB2S.sPas];

craP1 = [neuronsC1S.sAct, neuronsC1S.sPas];
craP2 = [neuronsC2S.sAct, neuronsC2S.sPas];

snapP1 = [neuronsS1S.sAct, neuronsS1S.sPas];
snapP2 = [neuronsS2S.sAct, neuronsS2S.sPas];

neuronsIncProp = joinNeuronTables({neuronsB1S,neuronsB2S, neuronsC1S, neuronsC2S, neuronsS1S, neuronsS2S});

difBoot = neuronsIncProp.sDifBoot;
sDifBoot = sort(difBoot')';

nNegProp = sum(quantile(difBoot', .025) > 0);
nPosProp = sum(quantile(difBoot', .975) < 0);
nNoDifProp = sum(quantile(difBoot', .025) < 0 & quantile(difBoot', 0.975)>0);


params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotMaxSens', false,...
    'tuningCondition', {{'isSorted','isCuneate','cutaneous', 'sameDayMap','tuned','sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});

params.date = 'all';

neuronsB1S = neuronStructPlot(neuronsB1,params);
neuronsB2S = neuronStructPlot(neuronsB2,params);
neuronsC1S = neuronStructPlot(neuronsC1,params);
neuronsC2S = neuronStructPlot(neuronsC2,params);
neuronsS1S = neuronStructPlot(neuronsS1,params);

butC1 = [neuronsB1S.sAct, neuronsB1S.sPas];
butC2 = [neuronsB2S.sAct, neuronsB2S.sPas];

craC1 = [neuronsC1S.sAct, neuronsC1S.sPas];
craC2 = [neuronsC2S.sAct, neuronsC2S.sPas];

snapC1 = [neuronsS1S.sAct, neuronsS1S.sPas];

han = [neuronsH1.sAct, neuronsH1.sPas];
dun = [neuronsD.sAct, neuronsD.sPas];
neuronsIncCut = joinNeuronTables({neuronsB1S,neuronsB2S, neuronsC1S, neuronsC2S, neuronsS1S, neuronsS2S});
difBoot = neuronsIncCut.sDifBoot;

nNegCut = sum(quantile(difBoot', .025) > 0);
nPosCut = sum(quantile(difBoot', .975) < 0);
nNoDifProp = sum(quantile(difBoot', .025) < 0 & quantile(difBoot', 0.975)>0);

butP = [butP1;butP2];
snapP =[snapP1;snapP2];
craP = [craP1;craP2];

butC = [butC1; butC2];
snapC = [snapC1];
craC = [craC1;craC2];


colors = linspecer(3);
maxSens = max(max([butP; craP; snapP]));
figure
scatter(butP(:,2), butP(:,1), 32,colors(1,:), 'filled')
hold on
scatter(craP(:,2), craP(:,1),32,colors(2,:), 'filled')
scatter(snapP(:,2), snapP(:,1),32,colors(3,:), 'filled')
scatter(butC(:,2), butC(:,1), 32, colors(1,:))
scatter(craC(:,2), craC(:,1), 32, colors(2,:))
scatter(snapC(:,2), snapC(:,1), 32, colors(3,:))

plot([0, maxSens], [0, maxSens], 'k-')
set(gca,'TickDir','out', 'box', 'off')
leg = legend('Bu', 'Cr', 'Sn', 'Muscle', 'Cut');
title(leg, 'Monkey')
title('Cuneate Sensitivity SinTuned Mapped')

%%
close all
% keyboard
windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
visualizeSensitivity = true;
numBootstraps = 100;
minSens = 0.1;
tit1 = 'Act vs Passive Tuned Spindle';
path1 = 'D:\Figures\SensitivityChecks1\';

paramsCN = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
'tuningCondition', {{'isSorted','isCuneate','tuned', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
paramsCN.useWindowed = true;
paramsCN.minVal = minSens;
paramsCN.useMins = false;

paramsS1 = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
'tuningCondition', {{'isSorted', 'sinTunedAct|sinTunedPas', 'tuned'}});
paramsS1.useWindowed = true;
paramsS1.minVal = minSens;
paramsS1.useMins = false;
butter= [1,4];
snap = [2,6];
crackle = [3,5];

paramsCN.date = 'all';
paramsS1.date = 'all';
paramsS1.useMins = false;
neuronsArea2 = joinNeuronTables({getPaperNeurons(4, windowAct, windowPas),getPaperNeurons(5, windowAct, windowPas)});
count  =0;
for i = [1,2,3, 6,8,9]
    count = count+1;
    temp = getPaperNeurons(i, windowAct, windowPas);
    [nNegAllCNMonk(count), nPosAllCNMonk(count), nNoDifAllCNMonk(count)] = plotSensitivity(temp, paramsCN); 
    neuronsCN1{count} = fixCellArray(temp);
end
nNegAllButter = sum(nNegAllCNMonk(butter));
nPosAllButter = sum(nPosAllCNMonk(butter));

nNegAllCrackle = sum(nNegAllCNMonk(crackle));
nPosAllCrackle = sum(nPosAllCNMonk(crackle));

nNegAllSnap = sum(nNegAllCNMonk(snap));
nPosAllSnap = sum(nPosAllCNMonk(snap));
%%
neuronsCN = joinNeuronTables(neuronsCN1);
%[nNegCN, nPosCN, nNoDifCN] = plotSensitivity(neuronsCN, paramsCN);
[nNegAllCN, nPosAllCN, nNoDifAllCN, projAllCN, statAllCN] = plotSensitivityAll(neuronsCN, paramsCN);

%[nNegS1, nPosS1, nNoDifS1, projS1, statS1] = plotSensitivity(neuronsArea2, paramsS1);
[nNegAllS1, nPosAllS1, nNoDifAllS1, projAllS1, statAllS1] = plotSensitivityAll(neuronsArea2, paramsS1);
%%
figure
h= histogram(projAllCN(~statAllCN.NoDif),20, 'Normalization', 'probability');
edges = h.BinEdges;
hold on
histogram(projAllS1(~statAllS1.NoDif),edges, 'Normalization', 'probability')
legend({'CN', 'S1'})
title('Projection onto sensitivity axis')
xlabel('Attenuated <---   ---> Potentiated')
ylabel('# of units')
%%

%%

params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','proprio', 'daysDiff2', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
params.date = 'all';
params.useMins = true;
params.minVal = minSens;
neuronsSpindle = neuronStructPlot(neuronsCN, params);
[nNegSpin, nPosSpin, nNoDifSpin, projSpindle, statSpindle] = plotSensitivityAll(neuronsCN, params);


params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','cutaneous','daysDiff2', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit'}});
params.date = 'all';
params.useWindowed = true;
params.useMins = true;
params.minVal = minSens;
[nNegCut, nPosCut, nNoDifCut, projCut, statCut] = plotSensitivityAll(neuronsCN, params);

figure
h= histogram(projAllCut,10, 'Normalization', 'probability');
edges = h.BinEdges;
hold on
histogram(projAllSpindle,edges, 'Normalization', 'probability')
legend({'Cutaneous', 'Spindle'})
title('Projection onto sensitivity axis')
xlabel('Attenuated <---   ---> Potentiated')
ylabel('# of units')
% xlim([-10, 10])
set(gca,'TickDir','out', 'box', 'off')



spindleProj = projSpindle
cutProj = projAllCut
[~, pSpin]= ttest(spindleProj);
[~, pCut] =ttest(cutProj);
%%
figure
bar([nNegSpin, nNoDifSpin, nPosSpin; nNegCut, nNoDifCut, nPosCut])
xticklabels( {'Spindles', 'Cutaneous'})
legend('Active Tuned', 'No Difference', 'Passive Tuned')
set(gca,'TickDir','out', 'box', 'off')
ylabel('# of neurons')

figure
barMat = [nNegAllSpin, nNoDifAllSpin, nPosAllSpin; nNegAllCut, nNoDifAllCut, nPosAllCut; nNegAllS1, nNoDifAllS1, nPosAllS1];
norms = sum(barMat');
barMat(1,:) = barMat(1,:)/norms(1);
barMat(2,:) = barMat(2,:)/norms(2);
barMat(3,:) = barMat(3,:)/norms(3);
bar(barMat)
xticklabels( {'CN Spindles','CN Tactile',  'Area 2'})
legend('Active Tuned', 'No Difference', 'Passive Tuned')
set(gca,'TickDir','out', 'box', 'off')
ylabel('% of neurons')

paramsArea2 = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
    'tuningCondition', {{'isSorted','tuned',  'sinTunedAct|sinTunedPas'}});
paramsArea2.date = 'all';

neuronsArea2Sel = neuronStructPlot(neuronsArea2, paramsArea2);
figure
spinSAct = mean(neuronsSpindle.sActAllBoot,2);
spinSPas = mean(neuronsSpindle.sPasAllBoot,2);

s1SAct = mean(neuronsArea2Sel.sActAllBoot,2);
s1SPas = mean(neuronsArea2Sel.sPasAllBoot,2);
max1 = max([s1SAct;s1SPas;spinSAct;spinSPas]);
minFlagS1 = s1SAct<minSens & s1SPas<minSens;
minFlagCN = spinSAct<minSens & spinSPas<minSens;
scatter(spinSPas(~minFlagCN),spinSAct(~minFlagCN), 'filled')
hold on
scatter(s1SPas(~minFlagS1), s1SAct(~minFlagS1), 'filled')
plot([0, max1], [0, max1], 'k--')
legend('Proprioceptive CN', 'Area 2')
set(gca,'TickDir','out', 'box', 'off')
%%
figure
h= histogram(projAllS1,20, 'Normalization', 'probability');
edges = h.BinEdges;
hold on
histogram(projAllSpindle,edges, 'Normalization', 'probability')
legend({'Area 2', 'CN Spindle'})
title('Projection onto sensitivity axis')
xlabel('Attenuated <---   ---> Potentiated')
ylabel('# of units')
xlim([-10, 10])
set(gca,'TickDir','out', 'box', 'off')
%%


params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','proprio', 'daysDiff2', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
params.date = 'all';
params.useMins = true;
params.minVal = minSens;
neuronsSpindle = neuronStructPlot(neuronsCN, params);
[nNegAllSpin, nPosAllSpin, nNoDifAllSpin, projAllSpindle, statAllSpindle] = plotSensitivityAll(neuronsCN, params);


params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','cutaneous','daysDiff2', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit'}});
params.date = 'all';
params.useWindowed = true;
params.useMins = true;
params.minVal = minSens;
[nNegAllCut, nPosAllCut, nNoDifAllCut, projAllCut, statAllCut] = plotSensitivityAll(neuronsCN, params);

figure
h= histogram(projAllCut,10, 'Normalization', 'probability');
edges = h.BinEdges;
hold on
histogram(projAllSpindle,edges, 'Normalization', 'probability')
legend({'Cutaneous', 'Spindle'})
title('Projection onto sensitivity axis')
xlabel('Attenuated <---   ---> Potentiated')
ylabel('# of units')
% xlim([-10, 10])
set(gca,'TickDir','out', 'box', 'off')



spindleProj = projAllSpindle(~statAllSpindle.NoDif)
cutProj = projAllCut(statAllCut.NoDif)
[~, pSpin]= ttest(spindleProj);
[~, pCut] =ttest(cutProj);
