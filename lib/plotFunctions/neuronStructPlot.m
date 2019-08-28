function [neurons] = neuronStructPlot(neuronStruct,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    array = neuronStruct.array{1};
    monkey = neuronStruct.monkey{1};
    date = neuronStruct.date{1};
    
%     task = neuronStruct.task{1};
    plotUnitNum = false;
    plotModDepth = false;
    plotActVsPasPD = false;
    plotAvgFiring = false;
    plotAngleDif = false;
    plotPDDists= true;
    savePlots = true;
    useModDepths = true;
    rosePlot = true;
    plotModDepthClassic = false;
    plotSinusoidalFit = false;
    colorRow = [];
    size1 = 18;
    suffix = [];
    tuningCondition = {'isSorted'};
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
    s1Neurons = neuronStruct(strcmp('S1',[neuronStruct.array]) |strcmp('LeftS1Area2', [neuronStruct.array]) | strcmp('area2',[neuronStruct.array]),:);
    
    if strcmp(array, 'cuneate') | strcmp(array, 'RightCuneate')
        neurons = cuneateNeurons;
    elseif strcmp(array, 'area2') | strcmp(array,'LeftS1') | strcmp(array, 'LeftS1Area2')| strcmp(array, 'S1')
        neurons = s1Neurons;
    else
        neurons = neuronStruct;
    end
    actWindow = neurons.actWindow{1}';
    actWindow = actWindow(:);
    pasWindow = neurons.pasWindow{1}';
    pasWindow = pasWindow(:);
    pasWindow = cellfun(@num2str, pasWindow, 'un', 0);
    actWindow = cellfun(@num2str, actWindow, 'un', 0);
    pasWindow = strjoin(pasWindow, '_');
    actWindow = strjoin(actWindow, '_');

    if plotModDepth
        fh1 = figure;
        scatter(neurons.actPD.velModdepth*20, neurons.pasPD.velModdepth*20,'k', 'filled')
        lims = [0, max([neurons.actPD.velModdepth; neurons.pasPD.velModdepth])*20+.2];
        hold on
        plot([lims(1), lims(2)], [lims(1), lims(2)], 'r--')
        xlim(lims)
        ylim(lims)
        xlabel('Active Modulation Depth (spikes/s / (cm/s))')
        ylabel('Passive Modulation Depth (spikes/s / (cm/s))')
        set(gca,'TickDir','out', 'box', 'off')
        title(['GLM Sensitivity ',monkey, ' ', array, ' ', strjoin(tuningCondition, ' ')])
    end
    if plotSinusoidalFit
        for i = 1:height(neurons)
            bins = neurons.actTuningCurve.bins(i,:);
            actCurve = neurons.actTuningCurve.velCurve(i,:);
            pasCurve = neurons.pasTuningCurve.velCurve(i,:);
            cosBins = [cos(bins); sin(bins)]';
            lmAct = fitlm(cosBins, actCurve);
            sinFitAct(i) = lmAct.Rsquared.Ordinary;
            lmPas = fitlm(cosBins, pasCurve);
            sinFitPas(i) = lmPas.Rsquared.Ordinary;
            
        end
        fh8 = figure;
        hold on
        scatter(sinFitAct, sinFitPas,16, 'k', 'filled')
        plot([0, 1], [0, 1], 'r--')

        xlabel('Active Sinusoidal R2')
        ylabel('Passive Sinusoidal R2')
        set(gca,'TickDir','out', 'box', 'off')
        title('Effectiveness of Sinusoidal fits in active and passive')
    end
    if plotModDepthClassic
        fh7 = figure;
        hold on
        actFiring = neurons.actTuningCurve.velCurve.*20;
        pasFiring = neurons.pasTuningCurve.velCurve.*20;
        for i =1:length(actFiring(:,1,1))
            uActFiring = sort(actFiring(i,:));
            uPasFiring = sort(pasFiring(i,:));
            actMod(i) = uActFiring(end) - uActFiring(1);
            pasMod(i) = uPasFiring(end) - uPasFiring(1);
        end
        maxActPas = max([actMod, pasMod]);
        xlim([0, maxActPas])
        ylim([0, maxActPas])
        plot([0, maxActPas], [0, maxActPas], 'r--')
        scatter(actMod, pasMod,'k', 'filled')
        xlabel('Active Modulation Depth Classic (Hz)')
        ylabel('Passive Modulation Depth Classic (Hz)')
        set(gca,'TickDir','out', 'box', 'off')
        title('Tuning Curve Modulation Depths in Active and Passive')
    end
    if plotActVsPasPD
        actPDs =rad2deg(neurons.actPD.velPD);
        actPDsHigh = rad2deg(neurons.actPD.velPDCI(:,2));
        actPDsLow = rad2deg(neurons.actPD.velPDCI(:,1));
        
        modDepths = max([neurons.modDepthMove, neurons.modDepthBump]');
        if useModDepths
            size1 = modDepths;
            size1(size1==0) =1;
        end
        
        pasPDs = rad2deg(neurons.pasPD.velPD);
        pasPDsHigh = rad2deg(neurons.pasPD.velPDCI(:,2));
        pasPDsLow = rad2deg(neurons.pasPD.velPDCI(:,1));
        
        yneg = pasPDs-pasPDsLow;
        ypos = pasPDsHigh -pasPDs;
        
        xneg = actPDs - actPDsLow;
        xpos = actPDsHigh - actPDs;
        
        fh2 = figure;
        scatter(actPDs, pasPDs, size1*2,'k', 'filled')
        hold on
        errorbar(actPDs, pasPDs, yneg, ypos, xneg, xpos,'k.')
        if plotUnitNum
        for i = 1:length(actPDs)
            dx = -0.3; dy = 0.1; % displacement so the text does not overlay the data points
            text(actPDs(i)+ dx, pasPDs(i) +dy, num2str(neurons.chan(i)));
        end
        end
        plot([-180, 180], [-180, 180], 'r--')
        title(['Act vs. Pas PDs ',monkey, ' ', array, ' ', strjoin(tuningCondition, ' ')])
        xlabel('Active PD')
        ylabel('Passive PD')
        xlim([-200, 200])
        ylim([-200, 200])
         
        pdBump = neurons.angBump;
        pdMove = neurons.angMove;
        split = pi/4;
        vec = -pi:split:pi;
        mat = getIndicesInsideEdge(pdMove, vec);
        midVec = vec(1)+ .5*split:split:pi;
        for i = 1:length(mat(:,1))
            pdMoveVec(i) = rad2deg(circ_mean(pdMove(mat(i,:))));
            pdBumpVec(i) = rad2deg(circ_mean(pdBump(mat(i,:))));
        end
        if pdBumpVec(1) >0 
            pdBumpVec(1) = pdBumpVec(1) -360;
        end
        plot(rad2deg(midVec), pdBumpVec,'b', 'LineWidth', 2)
        
        set(gca,'TickDir','out', 'box', 'off')
        xticks([-180, -90,0, 90, 180])
        yticks([-180, -90,0,90,180])
       
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
        
        if ~rosePlot
        
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
        else
            fh5= figure;
            rose2(actPDs, 18);
            set(gca,'TickDir','out', 'box', 'off')

            title('Distribution of PDs in Active')

            fh6 = figure;
            rose2(pasPDs, 18);
            set(gca,'TickDir','out', 'box', 'off')

            title('Distribution of PDs in Passive')
        end
    end
    
    if (savePlots)
        savePath = [getBasicPath(monkey, dateToLabDate(date), getGenericTask('CO')), 'plotting', filesep,'NeuronStructPlots', filesep, actWindow, '_', pasWindow, filesep];
        mkdir(savePath)
        if ~isempty(suffix)
            title1 = string([monkey, '_',array, '_', date, '_', strjoin(tuningCondition, '_'), '_', suffix, '_']);
        else
            title1 = string([monkey, '_',array, '_', date, '_', strjoin(tuningCondition, '_'), '_']);
        end
        if plotPDDists
            saveas(fh5, [savePath,char(strjoin(string([title1, 'PDDistributionsActive.pdf']), ''))]);
            saveas(fh5, [savePath,char(strjoin(string([title1, 'PDDistributionsActive.png']), ''))]);

            saveas(fh6, [savePath,char(strjoin(string([title1, 'PDDistributionsPassive.pdf']), ''))]);
            saveas(fh6, [savePath,char(strjoin(string([title1, 'PDDistributionsPassive.png']), ''))]);
            
        end
        if plotAngleDif 
            saveas(fh4, [savePath,char(strjoin(string([title1, 'DiffPDAngs.png']),''))])
            
            saveas(fh4, [savePath,char(strjoin(string([title1, 'DiffPDAngs.pdf']),''))])
        end
        if plotAvgFiring
            saveas(fh3, [savePath,char(strjoin(string([title1, 'DCAvgFiring.png']),''))])
            saveas(fh3, [savePath,char(strjoin(string([title1, 'DCAvgFiring.pdf']),''))])
        end
        if plotActVsPasPD
            saveas(fh2, [savePath,char(strjoin(string([title1, 'ActVsPasPD.png']),''))]);
            saveas(fh2, [savePath,char(strjoin(string([title1, 'ActVsPasPD.pdf']),''))]);
        end
        if plotModDepth
            saveas(fh1, [savePath,char(strjoin(string([title1, 'ActPasModDepth.png']),''))]);
            saveas(fh1, [savePath,char(strjoin(string([title1, 'ActPasModDepth.pdf']),''))]);
        end
        if plotModDepthClassic
            saveas(fh7, [savePath, char(strjoin(string([title1, 'ActPasModDepthClassic.png']),''))]);
            saveas(fh7, [savePath, char(strjoin(string([title1, 'ActPasModDepthClassic.pdf']),''))]);

        end
        if plotSinusoidalFit
            saveas(fh8, [savePath, char(strjoin(string([title1, 'SinusoidalR2.png']),''))]);
            saveas(fh8, [savePath, char(strjoin(string([title1, 'SinusoidalR2.pdf']),''))]);

        end
    end
end

