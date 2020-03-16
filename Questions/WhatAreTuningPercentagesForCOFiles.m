clear all
close all
butterDate = '20190129';
snapDate = '20190829';
crackleDate = '20190418';
s1Date = '20190710';
monkeyS1 = 'Duncan';
hanDate = '20171122';
array = 'cuneate';

recompute = false;
doEncoding= false;
doDecoding = false;

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
neuronsCombined = [];
%%
if recompute | doEncoding  | doDecoding
for i = 1:5
    switch i
        case 1
            monkey= 'Butter';
            date = butterDate;
            number= 1;
            td = getTD(monkey, date, 'CO',2);
        case 2
            monkey = 'Snap';
            date = snapDate;
            number =2;
            td = getTD(monkey, date, 'CO',number);

        case 3
            monkey = 'Crackle';
            date = crackleDate;
            number =1;
            td = getTD(monkey, date, 'CO', number);
        case 4
            monkey = 'Duncan';
            date = s1Date;
            number = 1;
            td = getTD(monkey,date,'CObumpmove', number);
            array = 'leftS1';
            if strcmp(monkey, 'Duncan') 
                td(~isnan([td.idx_bumpTime]) & [td.idx_goCueTime]< [td.idx_bumpTime])=[];
                td([td.tgtDist]<8) = [];
            end
        case 5
            monkey = 'Han';
            date = hanDate;
            array = 'LeftS1Area2';
            number = 1;
            td = getTD(monkey, date, 'COactpas', number);
            

    end
    if ~strcmp(monkey, 'Han') & ~strcmp(monkey, 'Duncan')
        mappingFile = getSensoryMappings(monkey);
%         keyboard
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

    
    td = normalizeTDLabels(td);
    dirsM = [td.target_direction];
    f1 = mod(dirsM, pi/4) ~= 0;
    td(f1) = [];
    for p = 1:length(td)
        td(p).bumpDir= mod(td(p).bumpDir, 360);
    end
    td(isnan([td.idx_movement_on]))= [];
    %%
    if recompute

        param.arrays = {array};
        param.in_signals = {'vel'};
        param.train_new_model = true;
        param.array = array;
        params.cutoff = pi/4;

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
        if ~strcmp(monkey, 'Han') & ~strcmp(monkey, 'Duncan')
            neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
            [neuronsCO, mdl] = testForBimodality(neuronsCO);
            cutoffMan = .93;
            cutoffMean = .955;
            neuronsCO.handPSTHMan = [neuronsCO.bimodProjMan] < cutoffMan;
            neuronsCO.handPSTHMean = [neuronsCO.bimodProjMean] < cutoffMean;
        
        end
        if doEncoding
            [encoding{i}, ~, neuronsCO] = compiledCOEncoding(td,struct('array', array), neuronsCO);
            save('C:\Users\wrest\Documents\MATLAB\MonkeyData\Encoding\EncodingMoveOnToEndLinModel.mat', 'encoding');
        end
    end
    saveNeurons(neuronsCO,'MappedNeurons');

    if doDecoding
        if i ~=4 & i ~=5            
            td = removeBadNeurons(td, struct('remove_unsorted', false));
            td = removeUnsorted(td);
            td = removeGracileTD(td);
            td = removeNeuronsBySensoryMap(td, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
            td = removeNeuronsByNeuronStruct(td, struct('flags', {{'~handPSTHMan'}}));
        end
        [decoding{i}, pred{i}] = compiledCODecoding(td, struct('array', array));
        save('C:\Users\wrest\Documents\MATLAB\MonkeyData\Decoding\DecodingMoveOnToEndHanInc.mat', 'decoding', 'pred');
    end

end
end

%%
neuronsB = getNeurons('Butter', butterDate,'CObump','cuneate',[windowAct; windowPas]);
neuronsS = getNeurons('Snap', snapDate, 'CObump','cuneate',[windowAct; windowPas]);
neuronsC = getNeurons('Crackle', crackleDate, 'CObump','cuneate',[windowAct; windowPas]);
neuronsD = getNeurons(monkeyS1, s1Date,'CObump','leftS1',[windowAct; windowPas]);
neuronsH = getNeurons('Han', hanDate, 'COactpas', 'LeftS1Area2', [windowAct;windowPas]);


%% Split based on tuning curve
close all
vecStr = 'bimodProjMan';

cutoffMan = .93;
cutoffMean = .955;

neuronsS.handPSTHMan = [neuronsS.bimodProjMan] < cutoffMan;
neuronsB.handPSTHMan = [neuronsB.bimodProjMan] < cutoffMan;
neuronsC.handPSTHMan = [neuronsC.bimodProjMan] < cutoffMan;

neuronsS.handPSTHMean = [neuronsS.bimodProjMean] < cutoffMean;
neuronsB.handPSTHMean = [neuronsB.bimodProjMean] < cutoffMean;
neuronsC.handPSTHMean = [neuronsC.bimodProjMean] < cutoffMean;

neuronsCombined = [neuronsB; neuronsS; neuronsC];
neuronsS1 = [neuronsD;neuronsH];

load('C:\Users\wrest\Documents\MATLAB\MonkeyData\Encoding\EncodingMoveOnToEndLinModel.mat');
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\Decoding\DecodingMoveOnToEndHanInc.mat')
%%

%%
close all
sorted = neuronsCombined(logical([neuronsCombined.isSorted]),:);
% sorted([sorted.modDepthMove] <1 & [sorted.modDepthBump] < 1,:) = [];

bFlag = [neuronsB.modDepthMove] >1 & [neuronsB.modDepthBump] >1  & ~[neuronsB.handUnit];
bFlag(~[neuronsB.isSorted]& ~[neuronsB.isCuneate]) = [];
sFlag = [neuronsS.modDepthMove] >1 & [neuronsS.modDepthBump] >1  & ~[neuronsS.handUnit];
sFlag(~[neuronsS.isSorted]& ~[neuronsS.isCuneate]) = [];
cFlag = [neuronsC.modDepthMove] >1 & [neuronsC.modDepthBump] >1  & ~[neuronsC.handUnit];
cFlag(~[neuronsC.isSorted]& ~[neuronsC.isCuneate]) = [];

s1Flag = [neuronsS1.isSorted];


neuronsB= sorted(strcmp(sorted.monkey, 'Butter'),:);
neuronsS = sorted(strcmp(sorted.monkey, 'Snap'),:);
neuronsC = sorted(strcmp(sorted.monkey, 'Crackle'),:);




encodingB = encoding{1};
encodingS = encoding{2};
encodingC = encoding{3};
encodingH = encoding{4};


% encodingB(neuronsCombined(neuronsCombined.isCuneate & strcmp(neuronsCombined.monkey, 'Butter'),:).ID ==0 ) = [];
% % encodingS(strcmp(neuronsCombined.monkey, 'Snap'), :) = [];
% % encodingC(strcmp(neuronsCombined.monkey, 'Crackle', :)= [];
%%
close all
clear params


% lims = [1.2, 2];
% lims = [.9,1];
lims = [.8,1];
figure
subplot(3,1,1)
histogram(neuronsS(logical(neuronsS.sameDayMap & neuronsS.handUnit),:).(vecStr),30,'Normalization', 'probability')
hold on
histogram(neuronsS(logical(neuronsS.sameDayMap & ~neuronsS.handUnit),:).(vecStr),30,'Normalization', 'probability')
xlim(lims)
subplot(3,1,2)
histogram(neuronsB(logical(neuronsB.sameDayMap & neuronsB.handUnit),:).(vecStr), 5,'Normalization', 'probability')
hold on
histogram(neuronsB(logical(neuronsB.sameDayMap & ~neuronsB.handUnit),:).(vecStr),30,'Normalization', 'probability')
xlim(lims)
subplot(3,1,3)
histogram(neuronsC(logical(neuronsC.sameDayMap & neuronsC.handUnit),:).(vecStr),5,'Normalization', 'probability')
hold on
histogram(neuronsC(logical(neuronsC.sameDayMap & ~neuronsC.handUnit),:).(vecStr),30,'Normalization', 'probability')
xlim(lims)
%% Figure 3A. PD dists 
close all

params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD',false, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', true, 'plotSensEllipse', true,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct', 'sinTunedPas'}});

nS= neuronStructPlot(neuronsS, params)

nB = neuronStructPlot(neuronsB, params)

nC = neuronStructPlot(neuronsC, params)


%% Fig 3B. Act vs Pas PD
close all
params = struct('plotUnitNum', true,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', true, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct','handPSTHMan','~distal'}});

params.examplePDs = [74,1];
nBActNonHand = neuronStructPlot([neuronsB], params);

params.examplePDs = [40,3];
nCActNonHand = neuronStructPlot([neuronsC], params);

params.examplePDs = [5,2];
nSActNonHand = neuronStructPlot([neuronsS], params);
%%

params.date = 'all';
nAll = neuronStructPlot([neuronsB; neuronsC; neuronsS], params);

params1 = struct('plotUnitNum', true,'plotModDepth', true, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', true, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', true, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted', 'sinTunedAct','sinTunedPas'}});

params1.examplePDs = [];
params1.date = 'all';
nS1Act = neuronStructPlot(neuronsS1,params1);

temp1 = compareUniformity(nAll, nS1Act)

params1.tuningCondition = {'isSorted','sinTunedAct', 'sinTunedPas'};
nS1Pas = neuronStructPlot(neuronsS1,params1);

[tabC] = compareUniformity(nCActNonHand, nS1Act);
[tabS] = compareUniformity(nSActNonHand, nS1Act);
[tabB] = compareUniformity(nBActNonHand, nS1Act);

[tabCom] = compareUniformity([nBActNonHand; nCActNonHand; nSActNonHand], nS1Act);

%%
close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', true, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedPas','sinTunedAct', 'handPSTHMan','~distal'}});

params.examplePDs = [74,1];
nBActNonHand = neuronStructPlot([neuronsB], params);

params.examplePDs = [40,3];
nCActNonHand = neuronStructPlot([neuronsC], params);

params.examplePDs = [5,2];
nSActNonHand = neuronStructPlot([neuronsS], params);

params.date = 'all';
nAll = neuronStructPlot([neuronsB; neuronsC; neuronsS], params);
%%

params1 = struct('plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', false, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'useNewSensMetric', false, 'plotSensEllipse', false,...
    'tuningCondition', {{'isSorted','sinTunedAct'}});

params1.examplePDs = [];
nS1Act = neuronStructPlot(neuronsS1,params1);

params1.tuningCondition = {'isSorted', 'sinTunedPas'};
nS1Pas = neuronStructPlot(neuronsS1,params1);
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
writetable(statTab, 'C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Compiled\neuronStats.xlsx','WriteRowNames', true)

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
writetable(statTab, 'C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Compiled\neuronStatsPercent.xlsx','WriteRowNames', true)
%%
x = sorted(logical([sorted.isCuneate]),:);
y = neuronsS1;

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
nH = neuronStructPlot(neuronsH, params);
y = [nD;nH];
%%

close all
full = x.encoding.FullEnc(:,2);
fullB = nB.encoding.FullEnc(:,2);
fullC =  nC.encoding.FullEnc(:,2);
fullS =  nS.encoding.FullEnc(:,2);
fullH =  nH.encoding.FullEnc(:,2);
fullD =  nD.encoding.FullEnc(:,2);

fullMVelB = nB.encoding.FullNoVelEnc(:,2);
fullMVelC = nC.encoding.FullNoVelEnc(:,2);
fullMVelS = nS.encoding.FullNoVelEnc(:,2);
fullMVelH = nH.encoding.FullNoVelEnc(:,2);
fullMVelD = nD.encoding.FullNoVelEnc(:,2);

fullMPosB = nB.encoding.FullNoPosEnc(:,2);
fullMPosC = nC.encoding.FullNoPosEnc(:,2);
fullMPosS = nS.encoding.FullNoPosEnc(:,2);
fullMPosH = nH.encoding.FullNoPosEnc(:,2);
fullMPosD = nD.encoding.FullNoPosEnc(:,2);



fullH(isnan(fullH)) = 0;
full(isnan(full))= 0;
fullB(isnan(fullB))= 0;
fullC(isnan(fullC))= 0;
fullS(isnan(fullS))= 0;
fullH(isnan(fullH))= 0;
fullD(isnan(fullD))= 0;


fullH(fullH<0) = 0;
full(full<0)= 0;
fullB(fullB<0)= 0;
fullC(fullC<0)= 0;
fullS(fullS<0)= 0;
fullH(fullH<0)= 0;
fullD(fullD<0)= 0;

bootci(100, @mean, full)
bootci(100, @mean, fullB)
bootci(100, @mean, fullC)
bootci(100, @mean, fullS)
bootci(100, @mean, fullH)
bootci(100, @mean, fullD)

mean(full)
mean(fullH)
bootci(100, @mean, full)
bootci(100, @mean, fullH)

vel = x.encoding.VelEnc(:,2);
velB = nB.encoding.VelEnc(:,2);
velC =  nC.encoding.VelEnc(:,2);
velS = nS.encoding.VelEnc(:,2);
velH =  nH.encoding.VelEnc(:,2);
velD = nD.encoding.VelEnc(:,2);

pos = x.encoding.PosEnc(:,2);
posB = nB.encoding.PosEnc(:,2);
posC =  nC.encoding.PosEnc(:,2);
posS =  nS.encoding.PosEnc(:,2);
posH =  nH.encoding.PosEnc(:,2);
posD = nD.encoding.PosEnc(:,2);

acc = x.encoding.AccEnc(:,2);
accB = nB.encoding.AccEnc(:,2);
accC =  nC.encoding.AccEnc(:,2);
accS =  nS.encoding.AccEnc(:,2);
accH =  nH.encoding.AccEnc(:,2);
accD =nD.encoding.AccEnc(:,2);

speed = x.encoding.SpeedEnc(:,2);
speedB = nB.encoding.SpeedEnc(:,2);
speedC = nC.encoding.SpeedEnc(:,2);
speedS =  nS.encoding.SpeedEnc(:,2);
speedH = nH.encoding.SpeedEnc(:,2);
speedD = nD.encoding.SpeedEnc(:,2);

%%
red = [.8, 0, 0];
pink = [255, 255, 255]/255;
colors_cn = [linspace(red(1),pink(1),4)', linspace(red(2),pink(2),4)', linspace(red(3),pink(3),4)'];

c1 = [0,0,.8];
c2 = [1,1,1];
colors_s1 = [linspace(c1(1),c2(1),3)', linspace(c1(2),c2(2),3)', linspace(c1(3),c2(3),3)'];

figure
p1 = cdfplot(fullB);
hold on
p2 = cdfplot(fullC);
p3 = cdfplot(fullS);
p4 = cdfplot(fullH);
p5 = cdfplot(fullD);

set(p1, 'Color', colors_cn(1,:));
set(p2, 'Color', colors_cn(2,:));
set(p3, 'Color', colors_cn(3,:));
set(p4, 'Color', colors_s1(1,:));
set(p5, 'Color', colors_s1(2,:));

xlabel('Pseudo-R2')
ylabel('Fraction of Units')
title('Full Model PR2 CDF')
leg = legend('Bu', 'Cr','Sn', 'Ha', 'Du');
title(leg, 'Monkey')
set(gca,'TickDir','out', 'box', 'off')
%%

pcntBadB = sum(fullB<.05)/length(fullB);
pcntBadC = sum(fullC<.05)/length(fullC);
pcntBadS = sum(fullS<.05)/length(fullS);
pcntBadH = sum(fullH<.05)/length(fullH);
pcntBadD = sum(fullD<.05)/length(fullD);
%%
figure
p1 = cdfplot(velB);
hold on
p2 = cdfplot(velC);
p3 = cdfplot(velS);
p4 = cdfplot(velH);
p5 = cdfplot(velD);

set(p1, 'Color', colors_cn(1,:));
set(p2, 'Color', colors_cn(2,:));
set(p3, 'Color', colors_cn(3,:));
set(p4, 'Color', colors_s1(1,:));
set(p5, 'Color', colors_s1(2,:));

xlabel('Pseudo-R2')
ylabel('Fraction of Units')
title('Vel Model PR2 CDF')
leg = legend('Bu', 'Cr','Sn', 'Ha', 'Du');
title(leg, 'Monkey')
set(gca,'TickDir','out', 'box', 'off')
%%
figure
p1 = cdfplot(posB);
hold on
p2 = cdfplot(posC);
p3 = cdfplot(posS);
p4 = cdfplot(posH);
p5 = cdfplot(posD);

set(p1, 'Color', colors_cn(1,:));
set(p2, 'Color', colors_cn(2,:));
set(p3, 'Color', colors_cn(3,:));
set(p4, 'Color', colors_s1(1,:));
set(p5, 'Color', colors_s1(2,:));

xlabel('Pseudo-R2')
ylabel('Fraction of Units')
title('Pos Model PR2 CDF')
leg = legend('Bu', 'Cr','Sn', 'Ha', 'Du');
title(leg, 'Monkey')
set(gca,'TickDir','out', 'box', 'off')

%%
close all
fullFlagB = fullB>.05;
fullFlagC = fullC>.05;
fullFlagS = fullS>.05;
fullFlagH = fullH>.05;
fullFlagD = fullD>.05;

red = [.8, 0, 0];
pink = [255, 255, 255]/255;
colors_cn = [linspace(red(1),pink(1),4)', linspace(red(2),pink(2),4)', linspace(red(3),pink(3),4)'];

c1 = [0,0,.8];
c2 = [1,1,1];
colors_s1 = [linspace(c1(1),c2(1),3)', linspace(c1(2),c2(2),3)', linspace(c1(3),c2(3),3)'];

% keyboard
figure
p1 = cdfplot(velB(fullFlagB)./fullB(fullFlagB));
set(p1, 'Color', colors_cn(1,:));
hold on
p2 = cdfplot(velC(fullFlagC)./fullC(fullFlagC));
set(p2, 'Color', colors_cn(2,:));

p3 = cdfplot(velS(fullFlagS)./fullS(fullFlagS));
set(p3, 'Color', colors_cn(3,:));

p4 = cdfplot(velH(fullFlagH)./fullH(fullFlagH));
set(p4, 'Color', colors_s1(1,:));

p5 = cdfplot(velD(fullFlagD)./fullD(fullFlagD));
set(p5, 'Color', colors_s1(2,:));
title('Vel Model/ Full Model PR2 CDF')
xlabel('Ratio of Vel model to Full model PR2')
ylabel('Fraction of Neurons')
xlim([0,1])
ylim([0,1])
set(gca,'TickDir','out', 'box', 'off')
leg = legend('Bu', 'Cr', 'Sn', 'Ha', 'Du');
title(leg, 'Monkey')

figure
p1 = cdfplot(posB(fullFlagB)./fullB(fullFlagB));
set(p1, 'Color', colors_cn(1,:));
hold on
p2 = cdfplot(posC(fullFlagC)./fullC(fullFlagC));
set(p2, 'Color', colors_cn(2,:));

p3 = cdfplot(posS(fullFlagS)./fullS(fullFlagS));
set(p3, 'Color', colors_cn(3,:));


p4 = cdfplot(posH(fullFlagH)./fullH(fullFlagH));
set(p4, 'Color', colors_s1(1,:));

p5 = cdfplot(posD(fullFlagD)./fullD(fullFlagD));
set(p5, 'Color', colors_s1(2,:));

title('Pos Model/ Full Model PR2 CDF ')
xlabel('Ratio of Pos model to Full model PR2')
ylabel('Fraction of Neurons')
xlim([0,1])
ylim([0,1])
set(gca,'TickDir','out', 'box', 'off')
leg = legend('Bu', 'Cr', 'Sn', 'Ha', 'Du');
title(leg, 'Monkey')


%%
close all
figure
scatter(velB, posB,[],colors_cn(1,:), 'filled')
hold on
scatter(velC, posC, [], colors_cn(2,:), 'filled')
scatter(velS, posS, [], colors_cn(3,:), 'filled')
plot([0,.8], [0,.8], 'k--')
title('Velocity model vs Position model CN')
xlabel('Vel PR2')
ylabel('Pos PR2')
set(gca,'TickDir','out', 'box', 'off')
leg = legend('Bu', 'Cr', 'Sn');
title(leg, 'Monkey')

figure
scatter(velH, posH,[],colors_s1(1,:), 'filled')
hold on
scatter(velD, posD, [], colors_s1(2,:), 'filled')
plot([0,.8], [0,.8], 'k--')
title('Velocity model vs Position model CN')
xlabel('Vel PR2')
ylabel('Pos PR2')
set(gca,'TickDir','out', 'box', 'off')
leg = legend('Ha', 'Du');
title(leg, 'Monkey')
%%
fBCI = bootci(1000, @mean, fullB)';
fSCI = bootci(1000, @mean, fullS)';
fCCI = bootci(1000, @mean, fullC)';
fHCI = bootci(1000, @mean, fullH)';
fDCI = bootci(1000, @mean, fullD)';
fCNCI = bootci(1000, @mean, [fullB; fullS; fullC])';
fS1CI = bootci(1000, @mean, [fullH; fullD])';
mFCN = mean([fullB; fullS; fullC]);
mFS1 = mean([fullH; fullD]);

fullArr = [mean(fullB), fBCI; mean(fullC), fCCI;mean(fullS), fSCI;...
    mean(fullH), fHCI;mean(fullD), fDCI;...
    mean([fullB; fullS; fullC]), fCNCI;...
    mean([fullH; fullD]), fS1CI];
fullTab = array2table(fullArr, 'RowNames', {'Butter', 'Crackle', 'Snap', 'Han', 'Duncan', 'CN', 'S1'});

%%
pRatBCI = bootci(1000, @mean, posB(fullFlagB)./fullB(fullFlagB))';
pRatSCI = bootci(1000, @mean,  posS(fullFlagS)./fullS(fullFlagS))';
pRatCCI = bootci(1000, @mean,  posC(fullFlagC)./fullC(fullFlagC))';
pRatHCI = bootci(1000, @mean,  posH(fullFlagH)./fullH(fullFlagH))';
pRatDCI = bootci(1000, @mean,  posD(fullFlagD)./fullD(fullFlagD))';
pRatCNCI = bootci(1000, @mean, [ posB(fullFlagB)./fullB(fullFlagB);  posC(fullFlagC)./fullC(fullFlagC);  posS(fullFlagS)./fullS(fullFlagS)])';
pRatS1CI = bootci(1000, @mean, [ posH(fullFlagH)./fullH(fullFlagH); posD(fullFlagD)./fullD(fullFlagD)])';
mRatPCN = mean([ posB(fullFlagB)./fullB(fullFlagB);  posS(fullFlagS)./fullS(fullFlagS);  posC(fullFlagC)./fullC(fullFlagC)]);
mRatPS1 = mean([ posH(fullFlagH)./fullH(fullFlagH); posD(fullFlagD)./fullD(fullFlagD)]);

posArr = [mean( posB(fullFlagB)./fullB(fullFlagB)), pRatBCI; mean(posC(fullFlagC)./fullC(fullFlagC)), pRatCCI;mean( posS(fullFlagS)./fullS(fullFlagS)), pRatSCI;...
    mean( posH(fullFlagH)./fullH(fullFlagH)), pRatHCI;mean( posD(fullFlagD)./fullD(fullFlagD)), pRatDCI;...
    mRatPCN, pRatCNCI;...
    mean(mRatPS1), pRatS1CI];
posRatTab = array2table(posArr, 'RowNames', {'Butter', 'Crackle', 'Snap', 'Han', 'Duncan', 'CN', 'S1'});
%%
vRatBCI = bootci(1000, @mean, velB(fullFlagB)./fullB(fullFlagB))';
vRatSCI = bootci(1000, @mean,  velS(fullFlagS)./fullS(fullFlagS))';
vRatCCI = bootci(1000, @mean,  velC(fullFlagC)./fullC(fullFlagC))';
vRatHCI = bootci(1000, @mean,  velH(fullFlagH)./fullH(fullFlagH))';
vRatDCI = bootci(1000, @mean,  velD(fullFlagD)./fullD(fullFlagD))';
vRatCNCI = bootci(1000, @mean, [ velB(fullFlagB)./fullB(fullFlagB);  velC(fullFlagC)./fullC(fullFlagC);  velS(fullFlagS)./fullS(fullFlagS)])';
vRatS1CI = bootci(1000, @mean, [ velH(fullFlagH)./fullH(fullFlagH); velD(fullFlagD)./fullD(fullFlagD)])';
mRatPCN = mean([ velB(fullFlagB)./fullB(fullFlagB);  velS(fullFlagS)./fullS(fullFlagS);  velC(fullFlagC)./fullC(fullFlagC)]);
mRatPS1 = mean([ velH(fullFlagH)./fullH(fullFlagH); velD(fullFlagD)./fullD(fullFlagD)]);

velArr = [mean( velB(fullFlagB)./fullB(fullFlagB)), vRatBCI; mean(velC(fullFlagC)./fullC(fullFlagC)), vRatCCI;mean( velS(fullFlagS)./fullS(fullFlagS)), vRatSCI;...
    mean( velH(fullFlagH)./fullH(fullFlagH)), vRatHCI;mean( velD(fullFlagD)./fullD(fullFlagD)), vRatDCI;...
    mRatPCN, vRatCNCI;...
    mean(mRatPS1), vRatS1CI];
velRatTab = array2table(velArr, 'RowNames', {'Butter', 'Crackle', 'Snap', 'Han', 'Duncan', 'CN', 'S1'});
%%
pBCI = bootci(1000, @mean, posB)';
pSCI = bootci(1000, @mean, posS)';
pCCI = bootci(1000, @mean, posC)';
pHCI = bootci(1000, @mean, posH)';
pDCI = bootci(1000, @mean, posD)';
pCNCI = bootci(1000, @mean, [posB; posS; posC])';
pS1CI = bootci(1000, @mean, [posH; posD])';
mPCN = mean([posB; posS; posC]);
mPS1 = mean([posH; posD]);

posArr = [mean(posB), pBCI; mean(posC), pCCI;mean(posS), pSCI;...
    mean(posH), pHCI;mean(posD), pDCI;...
    mean([posB; posS; posC]), pCNCI;...
    mean([posH; posD]), pS1CI];
posTab = array2table(posArr, 'RowNames', {'Butter', 'Crackle', 'Snap', 'Han', 'Duncan', 'CN', 'S1'});
%%
velB(velB <-1000) = [];
pBCI = bootci(1000, @mean, velB)';
pSCI = bootci(1000, @mean, velS)';
pCCI = bootci(1000, @mean, velC)';
pHCI = bootci(1000, @mean, velH)';
pDCI = bootci(1000, @mean, velD)';
pCNCI = bootci(1000, @mean, [velB; velS; velC])';
pS1CI = bootci(1000, @mean, [velH; velD])';
mPCN = mean([velB; velS; velC]);
mPS1 = mean([velH; velD]);

velArr = [mean(velB), pBCI; mean(velC), pCCI;mean(velS), pSCI;...
    mean(velH), pHCI;mean(velD), pDCI;...
    mean([velB; velS; velC]), pCNCI;...
    mean([velH; velD]), pS1CI];
velTab = array2table(velArr, 'RowNames', {'Butter', 'Crackle', 'Snap', 'Han', 'Duncan', 'CN', 'S1'});
%%
close all
c = categorical({'Monkey Bu','Monkey Sn','Monkey Cr', 'Monkey Ha (area 2)'});
figure
decB = decoding{1};
decS = decoding{2};
decC = decoding{3};
decH = decoding{4};
bar1 = [decB.PosMean, decB.VelMean, decB.SpeedMean;...
        decS.PosMean, decS.VelMean, decS.SpeedMean;...
        decC.PosMean, decC.VelMean, decC.SpeedMean;...
        decH.PosMean, decH.VelMean, decH.SpeedMean];
barTemp = bar1';
errX = [.775, 1,1.225, 1.775, 2, 2.225, 2.775, 3, 3.225, 3.775, 4,4.225];

errHigh =[decB.PosMeanHigh, decB.VelMeanHigh, decB.SpeedHigh,...
        decS.PosMeanHigh, decS.VelMeanHigh, decS.SpeedHigh,...
        decC.PosMeanHigh, decC.VelMeanHigh, decC.SpeedHigh,...
        decH.PosMeanHigh, decH.VelMeanHigh, decH.SpeedHigh]-barTemp(:)';
    
errLow = [decB.PosMeanLow, decB.VelMeanLow, decB.SpeedLow,...
        decS.PosMeanLow, decS.VelMeanLow, decS.SpeedLow,...
        decC.PosMeanLow, decC.VelMeanLow, decC.SpeedLow,...
        decH.PosMeanLow, decH.VelMeanLow, decH.SpeedLow]-barTemp(:)';
bar(bar1)
hold on
errorbar(errX, barTemp(:), errHigh, errLow, 'k.')
xticklabels({'Monkey Bu', 'Monkey Sn', 'Monkey Cr', 'Monkey Ha (area2)'})
predB = pred{1};
predS = pred{2};
predC = pred{3};
predH = pred{4};
set(gca,'TickDir','out', 'box', 'off')
legend('Pos', 'Vel', 'Speed')

%%
figure
scatter(predB{1}(:,1), predB{1}(:,2),'filled')
hold on
scatter(predS{1}(:,1), predS{1}(:,2),'filled')
scatter(predC{1}(:,1), predC{1}(:,2),'filled')
scatter(predH{1}(:,1), predH{1}(:,2),'filled')
title('Cross-validated Decoding')
xlabel('Predicted Velocity')
ylabel('Actual Velocity')
legend('Monkey Bu','Monkey Sn', 'Monkey Cr', 'Monkey Ha (area 2)'); 
set(gca,'TickDir','out', 'box', 'off')
