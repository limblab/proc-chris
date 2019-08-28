clear all
close all
butterDate = '20181218';
snapDate = '20190827';
crackleDate = '20190418';
array = 'cuneate';
recompute = false;
doEncoding= false;

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
neuronsCombined = [];
for i = 2
    switch i
        case 1
            monkey= 'Butter';
            date = butterDate;
            number= 1;
            td = getTD(monkey, date, 'CO');

        case 2
            monkey = 'Snap';
            date = snapDate;
            number =1;
            td = getTD(monkey, date, 'CO',number);

        case 3
            monkey = 'Crackle';
            date = crackleDate;
            number =1;
            td = getTD(monkey, date, 'CO', number);

    end
    mappingFile = getSensoryMappings(monkey);
    mappingFile = findDistalArm(mappingFile);
    mappingFile = findHandCutaneousUnits(mappingFile);
    mappingFile = findProximalArm(mappingFile);
    mappingFile = findMiddleArm(mappingFile);
    mappingFile = findCutaneous(mappingFile);
    td = normalizeTDLabels(td);
    td = getSpeed(td);

    %%
    if ~isfield(td, 'idx_movement_on')
        params.start_idx =  'idx_goCueTime';
        params.end_idx = 'idx_endTime';
        td = getMoveOnsetAndPeak(td, params);
    end
    if recompute

    windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
    windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
    param.arrays = {array};
    param.in_signals = {'vel'};
    param.train_new_model = true;

    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    param.windowAct= windowAct;
    param.windowPas =windowPas;
    param.date = date;
    if td(1).bin_size == .001
        td=binTD(td, 10);
        td = getMoveOnsetAndPeak(td,params);
        td = td(~isnan([td.idx_movement_on]));

    end
    %%
    [processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td, param);
    neuronsNew = fitCOBumpPSTH(td, neuronsNew, params);
    param.array = array;
    param.sinTuned= neuronsNew.sinTunedAct | neuronsNew.sinTunedPas;
    neuronsCO = [neuronsNew];
    %%
    neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
    saveNeurons(neuronsCO,'MappedNeurons');

    neuronsCombined = [neuronsCombined; neuronsCO];
    end
    if doEncoding
        encoding{i} = compiledCOEncoding(td);
    end
end
if ~recompute
    neuronsB = getNeurons('Butter', '20181218','CObump');
    neuronsS = getNeurons('Snap', snapDate, 'CObump');
    neuronsC = getNeurons('Crackle', crackleDate, 'CObump');
    neuronsCombined = [neuronsB; neuronsS; neuronsC];
end
if ~doEncoding
    load('C:\Users\wrest\Documents\MATLAB\MonkeyData\Encoding\Encoding.mat');
end
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

neuronsB= sorted(strcmp(sorted.monkey, 'Butter'),:);
neuronsS = sorted(strcmp(sorted.monkey, 'Snap'),:);
neuronsC = sorted(strcmp(sorted.monkey, 'Crackle'),:);

encodingB = encoding{1};
encodingS = encoding{2};
encodingC = encoding{3};

% encodingB(neuronsCombined(neuronsCombined.isCuneate & strcmp(neuronsCombined.monkey, 'Butter'),:).ID ==0 ) = [];
% % encodingS(strcmp(neuronsCombined.monkey, 'Snap'), :) = [];
% % encodingC(strcmp(neuronsCombined.monkey, 'Crackle', :)= [];

params = struct('plotModDepth', true, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','isCuneate', 'moveTuned', 'bumpTuned'}});

neuronStructPlot(neuronsB, params)
neuronStructPlot(neuronsC, params)
neuronStructPlot(neuronsS, params)



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
params = struct('plotModDepth', true, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDir', false, 'plotPDDists', true, ...
    'savePlots', false, 'useModDepths', true, 'rosePlot', true, ...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,...
    'tuningCondition', {{'isSorted','isCuneate', 'sinTunedPas', 'sinTunedAct'}});
params.date = 'all';
% params.suffix = 'Windowed';
x = neuronStructPlot(sorted, params);
%%
