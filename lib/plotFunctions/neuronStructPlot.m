function [neurons] = neuronStructPlot(neuronStruct,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    array = 'cuneate';
    date = 'all';
    plotModDepth = false;
    plotActVsPasPD = true;
    plotAvgFiring = false;
    plotAngleDif = false;
    plotPDDists= false;
    savePlots = false;
    tuningCondition = {'sinTunedAct'};
    fh1 = [];
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    if iscell(tuningCondition)
        for i = 1:length(tuningCondition)
            neuronStruct = neuronStruct(find(neuronStruct.(tuningCondition{i})),:);
        end
    else
        neuronStruct = neuronStruct(find(neuronStruct.(tuningCondition)),:);
    end
    neuronStruct1 = [];
   if iscell(date)
       for i =1:length(date)
            neuronStruct1 = [neuronStruct1; neuronStruct(find(strcmp(date{i}, [neuronStruct.date])),:)];
       end
       neuronStruct = neuronStruct1;
   elseif strcmp(date, 'all')
       
   else 
       neuronStruct = neuronStruct(find(strcmp(date, [neuronStruct.date])),:);
   end
    
    cuneateNeurons = neuronStruct(~strcmp('LeftS1',[neuronStruct.array]) & ~strcmp('area2',[neuronStruct.array]),:);
    s1Neurons = neuronStruct(strcmp('LeftS1',[neuronStruct.array]) | strcmp('area2',[neuronStruct.array]),:);
    
    if strcmp(array, 'cuneate') | strcmp(array, 'RightCuneate')
        neurons = cuneateNeurons;
    elseif strcmp(array, 'area2') | strcmp(array,'LeftS1')
        neurons = s1Neurons;
    elseif strcmp(array, 'all')
        neurons = [cuneateNeurons; s1Neurons];
    else
        error('bad string')
    end
    

    if plotModDepth
        fh1 = figure;
        scatter(neurons.modDepthMove, neurons.modDepthBump)
    end
    
    if plotActVsPasPD
        actPDs = neurons.actPD.velPD;
        actPDsHigh = neurons.actPD.velPDCI(:,2);
        actPDsLow = neurons.actPD.velPDCI(:,1);
        
        pasPDs = neurons.pasPD.velPD;
        pasPDsHigh = neurons.pasPD.velPDCI(:,2);
        pasPDsLow = neurons.pasPD.velPDCI(:,1);
        
        yneg = pasPDs-pasPDsLow;
        ypos = pasPDsHigh -pasPDs;
        
        xneg = actPDs - actPDsLow;
        xpos = actPDsHigh - actPDs;
        
        fh2 = figure;
        errorbar(actPDs, pasPDs, yneg, ypos, xneg, xpos,'o')
        hold on
        plot([-pi, pi], [-pi, pi], 'r--')
        title(['Act vs. Pas PDs ', array, ' ', strjoin(tuningCondition, ' ')])
        xlabel('Active PD direction')
        ylabel('Passive PD direction')
        xlim([-pi, pi])
        ylim([-pi, pi])
        
    end
    
    if plotAvgFiring
        bumpAvg = neurons.dcBump;
        moveAvg = neurons.dcMove;
        fh3 = figure;
        histogram(moveAvg)
        hold on
        histogram(bumpAvg)
        title('Active and passive change in firing across all directions')
        xlabel('Delta firing rate (Hz)')
        ylabel('# of units')
        legend('Active DC Shift', 'Passive DC Shift')
    end
    
    if plotAngleDif
        bumpDif = neurons.pasActDif;
        fh4 = figure;
        histogram(bumpDif)
        title('PD rotations between active and passive')
        xlabel('change in PD directions')
        ylabel('# of units')
        
    end
    
    if plotPDDists
        actPDs = neurons.actPD.velPD;
        pasPDs = neurons.pasPD.velPD;
        
        fh5= figure;
        histogram(actPDs);
        hold on
        histogram(pasPDs);
        title('Distribution of PDs in Active and Passive')
        xlabel('Angle')
        ylabel('# of units')
        legend('ActivePD Distribution', 'PassivePD Distribution')
    end
    
    if (savePlots)
        title1 = string([array, '_', date, '_', strjoin(tuningCondition, '_'), '_']);
        if plotPDDists
            saveas(fh5, strjoin(string([title1, 'PDDistributions.pdf']), ''));
        end
        if plotAngleDif 
            saveas(fh4, strjoin(string([title1, 'DiffPDAngs.pdf']),''))
        end
        if plotAvgFiring
            saveas(fh3, strjoin(string([title1, 'DCAvgFiring.pdf']),''))
        end
        if plotActVsPasPD
            saveas(fh2, strjoin(string([title1, 'ActVsPasPD.pdf']),''));
        end
        if plotModDepth
            saveas(fh1, strjoin(string([title1, 'ActPasModDepth.pdf']),''));
        end
 end
    
end
