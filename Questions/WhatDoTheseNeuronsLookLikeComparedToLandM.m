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
        
        
    else
        numPropInc(i) = 0;
        numCutInc(i) = 0;
        numNeurons(i) = height(neurons);
        

    end
end
%%
