function [neurons] = neuronStructPlot(neuronStruct,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    array = neuronStruct.array{1};
    monkey = neuronStruct.monkey{1};
    date = 'all';
    plotModDepth = true;
    plotActVsPasPD = true;
    plotAvgFiring = true;
    plotAngleDif = true;
    plotPDDists= true;
    savePlots = true;
    useModDepths = true;
    size1 = 18;
    tuningCondition = {'sinTunedAct','isSorted'};
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
        scatter(neurons.modDepthMove, neurons.modDepthBump,'k', 'filled')
        lims = [min([neurons.modDepthMove; neurons.modDepthBump])-5, max([neurons.modDepthMove; neurons.modDepthBump])+5];
        hold on
        plot([lims(1), lims(2)], [lims(1), lims(2)], 'r--')
        xlim(lims)
        ylim(lims)
        set(gca,'TickDir','out', 'box', 'off')
    end
    
    if plotActVsPasPD
        actPDs = mod(rad2deg(neurons.actPD.velPD)+360, 360);
        actPDsHigh = mod(rad2deg(neurons.actPD.velPDCI(:,2))+360,360);
        actPDsLow = mod(rad2deg(neurons.actPD.velPDCI(:,1))+360,360);
        
        modDepths = max([neurons.modDepthMove, neurons.modDepthBump]');
        if useModDepths
            size1 = modDepths;
            size1(size1==0) =1;
        end
        
        pasPDs = mod(rad2deg(neurons.pasPD.velPD)+360, 360);
        pasPDsHigh = mod(rad2deg(neurons.pasPD.velPDCI(:,2))+360,360);
        pasPDsLow = mod(rad2deg(neurons.pasPD.velPDCI(:,1))+360, 360);
        
        yneg = pasPDs-pasPDsLow;
        ypos = pasPDsHigh -pasPDs;
        
        xneg = actPDs - actPDsLow;
        xpos = actPDsHigh - actPDs;
        
        fh2 = figure;
        scatter(actPDs, pasPDs, size1*2,'k', 'filled')
        hold on
        errorbar(actPDs, pasPDs, yneg, ypos, xneg, xpos,'k.')
%         for i = 1:length(actPDs)
%             dx = -0.3; dy = 0.1; % displacement so the text does not overlay the data points
%             text(actPDs(i)+ dx, pasPDs(i) +dy, num2str(neurons.mapName(i)));
%         end
        plot([0, 360], [0, 360], 'r--')
        title(['Act vs. Pas PDs ',monkey, ' ', array, ' ', strjoin(tuningCondition, ' ')])
        xlabel('Active PD direction')
        ylabel('Passive PD direction')
        xlim([0, 360])
        ylim([0, 360])
        set(gca,'TickDir','out', 'box', 'off')
        xticks([0, 90, 180, 270, 360])
        yticks([0, 90, 180, 270, 360])
    end
    
    if plotAvgFiring
        bumpAvg = neurons.dcBump;
        moveAvg = neurons.dcMove;
        fh3 = figure;
        scatter(moveAvg,bumpAvg, size1*2, 'filled')
        hold on
%         scatter(0, 40, 50, 'r', 'filled')
%         text(-18, 40, '25 Hz Mod Depth' ,'FontSize',7)
        plot([min([bumpAvg;moveAvg]), max([bumpAvg;moveAvg])], [min([bumpAvg;moveAvg]), max([bumpAvg;moveAvg])], 'r--', 'LineWidth' ,4)
%         title('Active and passive change in firing across all directions')
        xlabel('Firing rate change Active (Hz)')
        ylabel('Firing rate change Passive (Hz)')
        axis square
        set(gca,'TickDir','out', 'box', 'off')
    end
    
    if plotAngleDif
        actPDs = neurons.actPD.velPD;
        pasPDs = neurons.pasPD.velPD;
        pdDif = angleDiff(actPDs, pasPDs, true, true);
        fh4 = figure;
        histogram(pdDif)
        title('PD rotations between active and passive')
        xlabel('change in PD directions')
        ylabel('# of units')
        
    end
    
    if plotPDDists
        actPDs = neurons.actPD.velPD;
        pasPDs = neurons.pasPD.velPD;
        
        fh5= figure;
        histogram(rad2deg(actPDs), rad2deg(-pi:pi/6:pi));
        title('Distribution of PDs in Active')
        xlabel('Angle')
        ylabel('# of units')
        set(gca,'TickDir','out', 'box', 'off')

        fh6 = figure;
        histogram(rad2deg(pasPDs),rad2deg(-pi:pi/6:pi));
        title('Distribution of PDs in Passive')
        xlabel('Angle')
        ylabel('# of units')
        set(gca,'TickDir','out', 'box', 'off')

    end
    
    if (savePlots)
        title1 = string([monkey, '_',array, '_', date, '_', strjoin(tuningCondition, '_'), '_']);
        if plotPDDists
            saveas(fh5, char(strjoin(string([title1, 'PDDistributionsActive.pdf']), '')));
            saveas(fh6, char(strjoin(string([title1, 'PDDistributionsPassive.pdf']), '')));
        end
        if plotAngleDif 
            saveas(fh4, char(strjoin(string([title1, 'DiffPDAngs.png']),'')))
        end
        if plotAvgFiring
            saveas(fh3, char(strjoin(string([title1, 'DCAvgFiring.png']),'')))
        end
        if plotActVsPasPD
            saveas(fh2, char(strjoin(string([title1, 'ActVsPasPD.pdf']),'')));
        end
        if plotModDepth
            saveas(fh1, char(strjoin(string([title1, 'ActPasModDepth.png']),'')));
        end
    end
end

