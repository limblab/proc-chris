clear all
close all
butterDate = '20190129';
snapDate = '20190829';
crackleDate = '20190418';
hanDate = '20171122';
array = 'cuneate';
recompute = false;
doEncoding= false;
doDecoding = false;

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
neuronsCombined = [];
if recompute | doEncoding  | doDecoding
for i = 1:4
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
%             params.neuronsToKeep = [4,1;...
%                              5,2;...
%                              6,1;...
%                              9,1;...
%                              9,2;...
%                              13,1;...
%                              17,1;...
%                              18,2;...
%                              18,1;...
%                              19,1;...
%                              39,1;...
%                              40,1;...
%                              44,1;...
%                              44,2;...
%                              45,1;...
%                              49,1;...
%                              51,1;...
%                              53,1;...
%                              54,2;...
%                              55,1;...
%                              56,1;...
%                              64,1;...
%                              68,1;...
%                              76,1;...
%                              78,1;...
%                              78,2;...
%                              80,1;...
%                              80,2;...
%                              83,1;...
%                              84,1;...
%                              85,1;...
%                              86,1;...
%                              89,1;...
%                              92,1;...
%                              92,2;...
%                              94,2];
%                          td = removeUnsorted(td, params);
        case 3
            monkey = 'Crackle';
            date = crackleDate;
            number =1;
            td = getTD(monkey, date, 'CO', number);
        case 4
            monkey = 'Han';
            date = hanDate;
            number = 1;
            td = getTD(monkey,date,'COactpas', number);
            array = 'LeftS1Area2';

    end
    if ~strcmp(monkey, 'Han')
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

    
    td = normalizeTDLabels(td);
    dirsM = [td.target_direction];
    f1 = mod(dirsM, pi/4) ~= 0;
    td(f1) = [];
    %%
    if recompute
        windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
        windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
        param.arrays = {array};
        param.in_signals = {'vel'};
        param.train_new_model = true;
        param.array = array;

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
        if ~strcmp(monkey, 'Han')
            neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
        end
        if doEncoding
            [encoding{i}, ~, neuronsCO] = compiledCOEncoding(td,struct('array', array), neuronsCO);
%             save('C:\Users\wrest\Documents\MATLAB\MonkeyData\Encoding\EncodingMoveOnToEndHanInc.mat', 'encoding');
        end
        saveNeurons(neuronsCO,'MappedNeurons');
    end

    if doDecoding
        if i ~=4
            td= removeGracileTD(td);
        end
        [decoding{i}, pred{i}] = compiledCODecoding(td, struct('array', array));
%         save('C:\Users\wrest\Documents\MATLAB\MonkeyData\Decoding\DecodingMoveOnToEndHanInc.mat', 'decoding', 'pred');
    end
end
end

%%
neuronsB = getNeurons('Butter', butterDate,'CObump','cuneate');
neuronsS = getNeurons('Snap', snapDate, 'CObump','cuneate');
neuronsC = getNeurons('Crackle', crackleDate, 'CObump','cuneate');
neuronsH = getNeurons('Han', hanDate,'COactpas','LeftS1Area2');
neuronsCombined = [neuronsB; neuronsS; neuronsC];
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\Encoding\EncodingMoveOnToEndHanInc.mat');
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\Decoding\DecodingMoveOnToEndHanInc.mat')
%%

%%
close all
sorted = neuronsCombined(logical([neuronsCombined.isSorted]),:);
sorted([sorted.modDepthMove] <1 & [sorted.modDepthBump] < 1,:) = [];
stats(1).cuneate = sum(sorted.isCuneate);
stats(1).cuneateTuned = sum(sorted.isCuneate & sorted.tuned);
stats(1).moveTuned = sum(sorted.isCuneate & sorted.tuned & sorted.moveTuned);
stats(1).bumpTuned = sum(sorted.isCuneate & sorted.tuned & sorted.bumpTuned);
stats(1).sinTunedAct = sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedAct);
stats(1).sinTunedPas = sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedPas);
stats(1).sinTunedBoth = sum(sorted.isCuneate & sorted.tuned & sorted.sinTunedPas & sorted.sinTunedPas);

bFlag = [neuronsB.modDepthMove] >1 & [neuronsB.modDepthBump] >1  & ~[neuronsB.handUnit];
bFlag(~[neuronsB.isSorted]& ~[neuronsB.isCuneate]) = [];
sFlag = [neuronsS.modDepthMove] >1 & [neuronsS.modDepthBump] >1  & ~[neuronsS.handUnit];
sFlag(~[neuronsS.isSorted]& ~[neuronsS.isCuneate]) = [];
cFlag = [neuronsC.modDepthMove] >1 & [neuronsC.modDepthBump] >1  & ~[neuronsC.handUnit];
cFlag(~[neuronsC.isSorted]& ~[neuronsC.isCuneate]) = [];

hFlag = [neuronsH.isSorted];


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
[neuronsS, mdl] = testForBimodality(neuronsS);
params.mdl = mdl;
neuronsB = testForBimodality(neuronsB, params);
neuronsC = testForBimodality(neuronsC, params);
%%
close all
vecStr = 'bimodProjMean';
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
%%
close all
cutoffMan = .925;
cutoffMean = .955;

neuronsS.handPSTHMan = [neuronsS.bimodProjMan] < cutoffMan;
neuronsB.handPSTHMan = [neuronsB.bimodProjMan] < cutoffMan;
neuronsC.handPSTHMan = [neuronsC.bimodProjMan] < cutoffMan;

neuronsS.handPSTHMean = [neuronsS.bimodProjMean] < cutoffMean;
neuronsB.handPSTHMean = [neuronsB.bimodProjMean] < cutoffMean;
neuronsC.handPSTHMean = [neuronsC.bimodProjMean] < cutoffMean;

params = struct('plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct', 'sinTunedPas', 'handPSTHMean'}});

params.examplePDs = [5,1];
nS= neuronStructPlot(neuronsS, params)

params.examplePDs = [74,1];
nB = neuronStructPlot(neuronsB, params)

params.examplePDs = [40,3];
nC = neuronStructPlot(neuronsC, params)

%%
params.examplePDs = [];
params.date = 'all';
neuronStructPlot([nB; nC; nS], params)

%%

params = struct('plotModDepth', true, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','sinTunedPas'}});

params.examplePDs = [];
neuronStructPlot(neuronsH,params);
%%

params = struct('plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','isCuneate', 'sinTunedAct','sinTunedPas'}});

params.examplePDs = [74,1];
neuronStructPlot(neuronsB, params)

params.examplePDs = [40,3];
neuronStructPlot(neuronsC, params)


params.examplePDs = [5,1];
neuronStructPlot(neuronsS, params)

%%

params = struct('plotModDepth', true, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','sinTunedAct'}});

params.examplePDs = [];
neuronStructPlot(neuronsH,params);

params = struct('plotModDepth', true, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','sinTunedAct', 'sinTunedPas'}});

params.examplePDs = [];
neuronStructPlot(neuronsH,params);
%%
params = struct('plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', false, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','isCuneate', 'sinTunedAct', 'sinTunedPas', '~handUnit'}});
params.date = 'all';

neuronStructPlot(sorted, params)



[lcn, hcn, ls1, hs1] = compareUniformity([nB; nC; nS], neuronsH);
%%
stats(2).cuneate = sum(neuronsB.isCuneate);
stats(2).cuneateTuned = sum(neuronsB.isCuneate & neuronsB.tuned);
stats(2).moveTuned = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.moveTuned);
stats(2).bumpTuned = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.bumpTuned);
stats(2).sinTunedAct = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedAct);
stats(2).sinTunedPas = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedPas);
stats(2).sinTunedBoth = sum(neuronsB.isCuneate & neuronsB.tuned & neuronsB.sinTunedPas & neuronsB.sinTunedPas);

stats(3).cuneate = sum(neuronsS.isCuneate);
stats(3).cuneateTuned = sum(neuronsS.isCuneate & neuronsS.tuned);
stats(3).moveTuned = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.moveTuned);
stats(3).bumpTuned = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.bumpTuned);
stats(3).sinTunedAct = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedAct);
stats(3).sinTunedPas = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedPas);
stats(3).sinTunedBoth = sum(neuronsS.isCuneate & neuronsS.tuned & neuronsS.sinTunedPas & neuronsS.sinTunedPas);

stats(4).cuneate = sum(neuronsC.isCuneate);
stats(4).cuneateTuned = sum(neuronsC.isCuneate & neuronsC.tuned);
stats(4).moveTuned = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.moveTuned);
stats(4).bumpTuned = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.bumpTuned);
stats(4).sinTunedAct = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedAct);
stats(4).sinTunedPas = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedPas);
stats(4).sinTunedBoth = sum(neuronsC.isCuneate & neuronsC.tuned & neuronsC.sinTunedPas & neuronsC.sinTunedPas);
statTab = struct2table(stats, 'RowNames', {'Combined', 'Butter', 'Snap', 'Crackle'});

%%
close all
params = struct('plotModDepth', true, 'plotActVsPasPD', true, 'plotEncodingFits', true,...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', false, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct', 'sinTunedPas'}});
params.date = 'all';
% params.suffix = 'Windowed';
x = neuronStructPlot(sorted, params);
params.tuningCondition = {'isSorted','sinTunedAct', 'sinTunedPas'};
y = neuronStructPlot(neuronsH, params);

neuronsB= x(strcmp(x.monkey, 'Butter'),:);
neuronsS = x(strcmp(x.monkey, 'Snap'),:);
neuronsC = x(strcmp(x.monkey, 'Crackle'),:);
%%
close all
figure
full = mean(x.encoding.FullEnc,2);
fullB = mean(neuronsB.encoding.FullEnc,2);
fullC =  mean(neuronsC.encoding.FullEnc,2);
fullS =  mean(neuronsS.encoding.FullEnc,2);
fullH =  mean(y.encoding.FullEnc,2);

bootci(100, @mean, full)
bootci(100, @mean, fullB)
bootci(100, @mean, fullC)
bootci(100, @mean, fullS)

mean(full)
mean(fullH)
bootci(100, @mean, full)
bootci(100, @mean, fullH)

vel = mean(x.encoding.VelEnc,2);
velB = mean(neuronsB.encoding.VelEnc,2);
velC =  mean(neuronsC.encoding.VelEnc,2);
velS = mean( neuronsS.encoding.VelEnc,2);
velH =  mean(y.encoding.VelEnc,2);

pos = mean(x.encoding.PosEnc,2);
posB = mean(neuronsB.encoding.PosEnc,2);
posC =  mean(neuronsC.encoding.PosEnc,2);
posS =  mean(neuronsS.encoding.PosEnc,2);
posH =  mean(y.encoding.PosEnc,2);

acc = mean(x.encoding.AccEnc,2);
accB = mean(neuronsB.encoding.AccEnc,2);
accC = mean( neuronsC.encoding.AccEnc,2);
accS =  mean(neuronsS.encoding.AccEnc,2);
accH =  mean(y.encoding.AccEnc,2);

speed = mean(x.encoding.SpeedEnc,2);
speedB = mean(neuronsB.encoding.SpeedEnc,2);
speedC =  mean(neuronsC.encoding.SpeedEnc,2);
speedS = mean( neuronsS.encoding.SpeedEnc,2);
speedH =  mean(y.encoding.SpeedEnc,2);


subplot(4,1,1)
histogram(fullB,0:.05:1)
xlim([0, 1])
title('Butter')
set(gca,'TickDir','out', 'box', 'off')

subplot(4,1,2)
histogram(fullC,0:.05:1)
xlim([0, 1])
title('Crackle')
set(gca,'TickDir','out', 'box', 'off')

subplot(4,1,3)
histogram(fullS,0:.05:1)
xlim([0, 1])
title('Snap')
set(gca,'TickDir','out', 'box', 'off')

subplot(4,1,4)
histogram(fullH,0:.05:1)
xlim([0, 1])
title('Han (area 2)')
set(gca,'TickDir','out', 'box', 'off')
suptitle('FullEncoding by monkey')

figure
subplot(4,1,1)
histogram(vel,0:.05:1)
xlim([0, 1])
title('Vel')
set(gca,'TickDir','out', 'box', 'off')

subplot(4,1,2)
histogram(speed,0:.05:1)
xlim([0, 1])
title('Speed')
set(gca,'TickDir','out', 'box', 'off')

subplot(4,1,3)
histogram(pos,0:.05:1)
xlim([0, 1])
title('pos')
set(gca,'TickDir','out', 'box', 'off')

subplot(4,1,4)
histogram(acc,0:.05:1)
xlim([0, 1])
title('acc')
set(gca,'TickDir','out', 'box', 'off')
suptitle('Encoding across monkeys by variable')

figure
subplot(4,1,1)
histogram(velB,0:.05:1)
xlim([0, 1])
title('Butter')

subplot(4,1,2)
histogram(velC,0:.05:1)
xlim([0, 1])
title('Crackle')

subplot(4,1,3)
histogram(velS,0:.05:1)
xlim([0, 1])
title('Snap')

subplot(4,1,4)
histogram(velH,0:.05:1)
xlim([0, 1])
title('Han')
suptitle('Vel encoding by monkey')

figure
subplot(4,1,1)
histogram(speedB,0:.05:1)
xlim([0, 1])
title('Butter')

subplot(4,1,2)
histogram(speedC,0:.05:1)
xlim([0, 1])
title('Crackle')

subplot(4,1,3)
histogram(speedS,0:.05:1)
xlim([0, 1])
title('Snap')

subplot(4,1,4)
histogram(speedH,0:.05:1)
xlim([0, 1])
title('Han')
suptitle('Speed Encoding by monkey')
%%
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
