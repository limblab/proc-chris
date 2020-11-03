clear all
close all
windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

for i = 1:12
    neurons = getPaperNeurons(i, windowAct, windowPas);
    neurons = neurons(logical(neurons.isSorted),:);
    fld = fieldnames(neurons);
    if any(contains(fld, 'isSpindle'))
        spindleFlag = neurons.isSpindle;
        propFlag = neurons.proprio;
        cutFlag = neurons.cutaneous;
        proxFlag = neurons.proximal;
        midFlag = neurons.midArm;
        distFlag = neurons.distal;
        handFlag = neurons.handUnit;
        daysDiff = neurons.daysDiff;
        moveFlag = neurons.moveTuned;
        
        mapFlag = abs(daysDiff)<=3;
        
        flagPropCN = propFlag & (proxFlag | midFlag) & mapFlag & moveFlag;
        flagCutCN = cutFlag & ~handFlag & mapFlag & moveFlag;
        
        neuronsProp{i} = neurons(flagPropCN,:);
        neuronsCut{i} = neurons(flagCutCN,:);
        
        allInc = neurons.increaseAllDirs;
        numNeurons(i) = sum(flagPropCN | flagCutCN);
        
        numProp(i) = sum(flagPropCN);
        numCut(i) = sum(flagCutCN);
        
        numPropInc(i) = sum(allInc(flagPropCN));
        numCutInc(i) = sum(allInc(flagCutCN));
        numAllInc(i) = sum(allInc);
        
        pctProp(i) = numPropInc(i)*100 / sum(flagPropCN);
        pctCut(i) = numCutInc(i)*100/ sum(flagCutCN);
    else
        allInc = neurons.increaseAllDirs;
        numProp(i) = 0;
        numCut(i) = 0;
        numPropInc(i) = 0;
        numCutInc(i) = 0;
        numNeurons(i) = height(neurons);
        pctProp(i) = 0;
        pctCut(i) = 0;
        numAllInc(i) = sum(allInc);

    end
    pctAll(i) = sum(allInc)/ height(neurons);
end
%%
numTab = table(numNeurons', numAllInc',numCut', numProp', numCutInc', numPropInc', 'VariableNames', {'NumNeurons', 'numIncreasing','numCut', 'numProp', 'numCutIncreasing', 'numPropIncreasing'});
pctTab = table(pctAll', pctProp', pctCut', 'VariableNames', {'pctIncreasing','pctPropIncreasing','pctCutIncreasing'});