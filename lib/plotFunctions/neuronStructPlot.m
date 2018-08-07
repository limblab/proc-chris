function [neurons] = neuronStructPlot(neuronStruct,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    array = 'cuneate';
    monkey = 'Butter';
    date = 'all';
    plotModDepth = true;
    plotActVsPasPD = true;
    plotAvgFiring = true;
    plotAngleDif = true;
    plotPDDists= true;
    savePlots = true;
    tuningCondition = {'sinTunedAct','sinTunedPas'};
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
        actPDs = rad2deg(neurons.actPD.velPD);
        actPDsHigh = rad2deg(neurons.actPD.velPDCI(:,2));
        actPDsLow = rad2deg(neurons.actPD.velPDCI(:,1));
        
        pasPDs = rad2deg(neurons.pasPD.velPD);
        pasPDsHigh = rad2deg(neurons.pasPD.velPDCI(:,2));
        pasPDsLow = rad2deg(neurons.pasPD.velPDCI(:,1));
        
        yneg = pasPDs-pasPDsLow;
        ypos = pasPDsHigh -pasPDs;
        
        xneg = actPDs - actPDsLow;
        xpos = actPDsHigh - actPDs;
        
        fh2 = figure;
        scatter(actPDs, pasPDs)
%         errorbar(actPDs, pasPDs, yneg, ypos, xneg, xpos,'o')
        hold on
%         for i = 1:length(actPDs)
%             dx = -0.3; dy = 0.1; % displacement so the text does not overlay the data points
%             text(actPDs(i)+ dx, pasPDs(i) +dy, num2str(neurons.mapName(i)));
%         end
        plot([-180, 180], [-180, 180], 'r--')
        title(['Act vs. Pas PDs ',monkey, ' ', array, ' ', strjoin(tuningCondition, ' ')])
        xlabel('Active PD direction')
        ylabel('Passive PD direction')
        xlim([-180, 180])
        ylim([-180, 180])
        set(gca,'TickDir','out', 'box', 'off')
        xticks([-180 -90 0 90 180])
        yticks([-180 -90 0 90 180])
    end
    
    if plotAvgFiring
        bumpAvg = neurons.dcBump;
        moveAvg = neurons.dcMove;
        fh3 = figure;
        scatter(moveAvg,bumpAvg)
        hold on
        plot([min([bumpAvg;moveAvg]), max([bumpAvg;moveAvg])], [min([bumpAvg;moveAvg]), max([bumpAvg;moveAvg])], 'r--')
        title('Active and passive change in firing across all directions')
        xlabel('Delta firing rate Active (Hz)')
        ylabel('Delta firing rate Passive (Hz)')
        axis equal
        set(gca,'TickDir','out', 'box', 'off')
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
        title1 = string([monkey, '_',array, '_', date, '_', strjoin(tuningCondition, '_'), '_']);
        if plotPDDists
            saveas(fh5, char(strjoin(string([title1, 'PDDistributions.pdf']), '')));
        end
        if plotAngleDif 
            saveas(fh4, char(strjoin(string([title1, 'DiffPDAngs.pdf']),'')))
        end
        if plotAvgFiring
            saveas(fh3, char(strjoin(string([title1, 'DCAvgFiring.pdf']),'')))
        end
        if plotActVsPasPD
            saveas(fh2, char(strjoin(string([title1, 'ActVsPasPD.pdf']),'')));
        end
        if plotModDepth
            saveas(fh1, char(strjoin(string([title1, 'ActPasModDepth.pdf']),'')));
        end
    end
end

