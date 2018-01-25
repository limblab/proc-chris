function [fh, outStruct, neurons] = getCOActPasStats(td,params)
  
    beforeBump = .3;
    afterBump = .3;
    beforeMove = .3;
    afterMove = .3;
    
    date= '03202017';
    array= 'RightCuneate';
    histogramFlag= false;
    circleFlag = false;
    plotFlag = false;
    saveFig =false;

    if(exist('params') && ~isfield(params,'sinTuned'))
        warning('No sinusoidal tuning provided, assuming all are tuned')
    end
    
    if (td(1).bin_size ~= .01), error('Bad bin size, has to be 10 ms wide');end
        

    numBoots = 1000;
    conf = .95;
    sinTuned = ones(length(td(1).([params.array, '_unit_guide'])(1,:)),1);

    if nargin > 1, assignParams(who,params); end % overwrite parameters

    unitLabel = array;
    unitGuide = [unitLabel, '_unit_guide'];
    unitSpikes = [unitLabel, '_spikes'];
    spikeLabel = [unitLabel, '_spikes'];
    params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
    params.extra_time = [.4,.6];
    td = td(~isnan([td.target_direction]));
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeak(td, params);

    bumpTrials = td(~isnan([td.bumpDir])); 
    upMove = td([td.target_direction] == pi/2 & isnan([td.bumpDir]));
    leftMove = td([td.target_direction] ==pi& isnan([td.bumpDir]));
    downMove = td([td.target_direction] ==3*pi/2& isnan([td.bumpDir]));
    rightMove = td([td.target_direction]==0& isnan([td.bumpDir]));
    
    upBump = bumpTrials([bumpTrials.bumpDir] == 90);
    downBump = bumpTrials([bumpTrials.bumpDir] == 270);
    leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
    rightBump = bumpTrials([bumpTrials.bumpDir] == 0);
    
    timeVec = linspace(-1*beforeBump, afterBump, length(upMove(1).idx_movement_on-(beforeMove*100):upMove(1).idx_movement_on+(afterMove*100)));
    
   for num1 = 1:length(td(1).(spikeLabel)(1,:))
       upMoveFiring = zeros(length(upMove), length(timeVec));
       for  i = 1:length(upMove)
            upMoveFiring(i,:) = upMove(i).(spikeLabel)(upMove(i).idx_movement_on-(beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),num1);
       end
       upBumpFiring = zeros(length(upBump), length(timeVec));
        for  i = 1:length(upBump)
            upBumpFiring(i,:) = upBump(i).(spikeLabel)(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),num1);
        end
       
       downMoveFiring = zeros(length(downMove), length(timeVec));
       for  i = 1:length(downMove)
            downMoveFiring(i,:) = downMove(i).(spikeLabel)(downMove(i).idx_movement_on-(beforeMove*100):downMove(i).idx_movement_on+(afterMove*100),num1);
        end
       downBumpFiring = zeros(length(downBump), length(timeVec));
        for  i = 1:length(downBump)
            downBumpFiring(i,:) = downBump(i).(spikeLabel)(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),num1);
        end
       
        
       leftMoveFiring = zeros(length(leftMove), length(timeVec));
        for  i = 1:length(leftMove)
            leftMoveFiring(i,:) = leftMove(i).(spikeLabel)(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),num1);
        end
       leftBumpFiring = zeros(length(leftBump), length(timeVec));
        for  i = 1:length(leftBump)
            leftBumpFiring(i,:) = leftBump(i).(spikeLabel)(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),num1);
        end
        
        
       rightBumpFiring = zeros(length(rightBump), length(timeVec));
        for  i = 1:length(rightBump)
            rightBumpFiring(i,:) = rightBump(i).(spikeLabel)(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),num1);
        end
        rightMoveFiring = zeros(length(rightMove), length(timeVec));
        for  i = 1:length(rightMove)
            rightMoveFiring(i,:) = rightMove(i).(spikeLabel)(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),num1);
        end

       shortRightBumpFiring{num1} = rightBumpFiring(:, beforeBump*100:beforeBump*100+10);
       shortLeftBumpFiring{num1} = leftBumpFiring(:, beforeBump*100:beforeBump*100+10);
       shortUpBumpFiring{num1} = upBumpFiring(:, beforeBump*100:beforeBump*100+10);
       shortDownBumpFiring{num1} = downBumpFiring(:, beforeBump*100:beforeBump*100+10);

       shortRightMoveFiring{num1} = rightMoveFiring(:, beforeMove*100:beforeMove*100+10);
       shortLeftMoveFiring{num1} = leftMoveFiring(:, beforeMove*100:beforeMove*100+10);
       shortUpMoveFiring{num1} = upMoveFiring(:, beforeMove*100:beforeMove*100+10);
       shortDownMoveFiring{num1} = downMoveFiring(:, beforeMove*100:beforeMove*100+10);

       preBumpFiring{num1} = [rightBumpFiring(:, beforeBump*50:beforeBump*100); leftBumpFiring(:, beforeBump*50:beforeBump*100);...
           upBumpFiring(:,beforeBump*50:beforeBump*100); downBumpFiring(:,beforeBump*50:beforeBump*100)];
       preMoveFiring{num1} = [rightMoveFiring(:, 1:beforeMove*50); leftMoveFiring(:, 1:beforeMove*50);...
       upMoveFiring(:,1:beforeMove*50); downMoveFiring(:,1:beforeMove*50)];
   
   end
   
           

   

   sigDif = zeros(length(shortLeftBumpFiring),1);
for i = 1:length(shortLeftBumpFiring)

    postBumpFiring{i} = [shortRightBumpFiring{i}; shortLeftBumpFiring{i}; shortUpBumpFiring{i}; shortDownBumpFiring{i}];
    [meanRightBump, botRightBump, topRightBump,bootstatRightBump] = bootstrpFiringRates(shortRightBumpFiring{i},numBoots, conf);
    [meanLeftBump, botLeftBump, topLeftBump, bootstatLeftBump] = bootstrpFiringRates(shortLeftBumpFiring{i},numBoots, conf);
    [meanUpBump, botUpBump, topUpBump, bootstatUpBump] = bootstrpFiringRates(shortUpBumpFiring{i},numBoots, conf);
    [meanDownBump, botDownBump, topDownBump, bootstatDownBump] = bootstrpFiringRates(shortDownBumpFiring{i},numBoots, conf);
    [meanPreBump(i), botPreBump(i), topPreBump(i), bootstatPreBump] = bootstrpFiringRates(preBumpFiring{i},numBoots,conf);
    [meanPostBump(i), botPostBump(i), topPostBump(i), bootstatPostBump] = bootstrpFiringRates(postBumpFiring{i}, numBoots, conf);
    dcBump(i) = meanPostBump(i) - meanPreBump(i);
    
    bumpTuned(i) = meanDownBump > topPreBump(i) | meanUpBump > topPreBump(i) | meanRightBump > topPreBump(i)| meanLeftBump > topPreBump(i) |...
        meanDownBump < botPreBump(i) | meanUpBump< botPreBump(i) | meanRightBump< botPreBump(i) | meanLeftBump < botPreBump(i);
    rightSigBump(i) = topRightBump<meanLeftBump | topRightBump<meanUpBump | topRightBump<meanDownBump | botRightBump > meanLeftBump | botRightBump >meanUpBump | botRightBump > meanDownBump;
    leftSigBump(i) = topLeftBump<meanRightBump | topLeftBump<meanUpBump | topLeftBump<meanDownBump | botLeftBump > meanRightBump | botLeftBump >meanUpBump | botLeftBump > meanDownBump;
    upSigBump(i) = topUpBump<meanRightBump | topUpBump<meanLeftBump | topUpBump<meanDownBump | botUpBump > meanRightBump | botUpBump >meanLeftBump | botUpBump > meanDownBump;
    downSigBump(i) = topDownBump<meanRightBump | topDownBump<meanUpBump | topDownBump<meanLeftBump | botDownBump > meanRightBump | botDownBump >meanUpBump | botDownBump > meanLeftBump;
    
    sigDifBump(i) = rightSigBump(i) | leftSigBump(i) | upSigBump(i) | downSigBump(i);
    

%     figure
%     histogram(bootstatPreMove)
%     hold on
%     histogram(bootstatPostMove)
%     histogram(bootstatPreBump)
%     histogram(bootstatPostBump)
%     legend('show')

    postMoveFiring{i} = [shortRightMoveFiring{i}; shortLeftMoveFiring{i}; shortUpMoveFiring{i}; shortDownMoveFiring{i}];
    [meanRightMove, botRightMove, topRightMove,bootstatRightMove] = bootstrpFiringRates(shortRightMoveFiring{i},numBoots, conf);
    [meanLeftMove, botLeftMove, topLeftMove, bootstatLeftMove] = bootstrpFiringRates(shortLeftMoveFiring{i},numBoots, conf);
    [meanUpMove, botUpMove, topUpMove, bootstatUpMove] = bootstrpFiringRates(shortUpMoveFiring{i},numBoots, conf);
    [meanDownMove, botDownMove, topDownMove, bootstatDownMove] = bootstrpFiringRates(shortDownMoveFiring{i},numBoots, conf);
    [meanPreMove(i), botPreMove(i), topPreMove(i), bootstatPreMove] = bootstrpFiringRates(preMoveFiring{i},numBoots,conf);
    [meanPostMove(i), botPostMove(i), topPostMove(i), bootstatPostMove] = bootstrpFiringRates(postMoveFiring{i}, numBoots, .99);
    dcMove(i) = meanPostMove(i) - meanPreMove(i);
    modDepthMove(i) = max([meanUpMove, meanDownMove, meanLeftMove, meanRightMove]) - min([meanUpMove, meanDownMove, meanLeftMove, meanRightMove]);
    modDepthBump(i) = max([meanUpBump, meanDownBump, meanLeftBump, meanRightBump]) - min([meanUpBump, meanDownBump, meanLeftBump, meanRightBump]);

    
    rightMoveSig(i) = topRightMove<meanLeftMove | topRightMove<meanUpMove | topRightMove<meanDownMove | botRightMove > meanLeftMove | botRightMove >meanUpMove | botRightMove > meanDownMove;
    leftMoveSig(i) = topLeftMove<meanRightMove | topLeftMove<meanUpMove | topLeftMove<meanDownMove | botLeftMove > meanRightMove | botLeftMove >meanUpMove | botLeftMove > meanDownMove;
    upMoveSig(i) = topUpMove<meanRightMove | topUpMove<meanLeftMove | topUpMove<meanDownMove | botUpMove > meanRightMove | botUpMove >meanLeftMove | botUpMove > meanDownMove;
    downMoveSig(i) = topDownMove<meanRightMove | topDownMove<meanUpMove | topDownMove<meanLeftMove | botDownMove > meanRightMove | botDownMove >meanUpMove | botDownMove > meanLeftMove;
    moveTuned(i) = meanDownMove > topPreMove(i) | meanUpMove > topPreMove(i) | meanRightMove > topPreMove(i)| meanLeftMove > topPreMove(i) |...
    meanDownMove < botPreMove(i) | meanUpMove< botPreMove(i) | meanRightMove< botPreMove(i) | meanLeftMove < botPreMove(i);

    sigDifMove(i) = rightMoveSig(i) | leftMoveSig(i) | upMoveSig(i) | downMoveSig(i);
    %

    upVec = [0, 1];
    downVec = [0,-1];
    rightVec = [1,0];
    leftVec = [-1, 0];
    
    pdVecMove(i,:) =  meanDownMove*downVec + meanUpMove*upVec + meanRightMove*rightVec + meanLeftMove*leftVec;
    pdVecBump(i,:) = meanDownBump*downVec + meanUpBump*upVec + meanRightBump*rightVec + meanLeftBump*leftVec;
    
    pdVecMoveBoot{i} = bootstatDownMove*downVec + bootstatUpMove*upVec + bootstatRightMove*rightVec + bootstatLeftMove*leftVec;
    pdVecBumpBoot{i} = bootstatDownBump*downVec + bootstatUpBump*upVec + bootstatRightBump*rightVec + bootstatLeftBump*leftVec;
    angBump(i) = atan2(pdVecBump(i, 2), pdVecBump(i,1));
    magBump(i) = norm(pdVecBump(i,:));
    angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
    bootPDAngMove{i} = angleDiff(atan2(pdVecMoveBoot{i}(:,2), pdVecMoveBoot{i}(:,1)), angMove(i), true, true);
    bootPDMagMove{i} = rownorm(pdVecMoveBoot{i});
    angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
    
    bootPDAngBump{i} = angleDiff(atan2(pdVecBumpBoot{i}(:,2), pdVecBumpBoot{i}(:,1)), angBump(i), true, true);
    bootPDMagBump{i} = rownorm(pdVecBumpBoot{i});
 
    
    sortedAngBump = sort(bootPDAngBump{i});
    lowAngBump(i) = sortedAngBump(50)+ angBump(i);
    highAngBump(i) = sortedAngBump(950) + angBump(i);
    
    sortedAngMove = sort(bootPDAngMove{i});
    lowAngMove(i) = sortedAngMove(50) +angMove(i);
    highAngMove(i) = sortedAngMove(950)+ angMove(i);

    
    goodFiring(i) = meanDownMove>0 & meanUpMove >0 & meanRightMove >0 & meanLeftMove >0 & meanDownBump >0 & meanUpBump >0 & meanRightBump>0 & meanLeftBump >0;
    
    if strcmp(array, 'cuneate') | strcmp(array, 'RightCuneate')
        trueCuneate = getTrueCuneate(td, params);
        tuned(i) = sigDifMove(i) & sigDifBump(i) & goodFiring(i)& sinTuned(i) & trueCuneate(i);%&sinTunedMove(i) & sinTunedBump(i);
    else
        tuned(i) = sigDifMove(i) & sigDifBump(i) & goodFiring(i)& sinTuned(i) ;%&sinTunedMove(i) & sinTunedBump(i);

    end
    title1 = [array,'_Lando_Electrode_',date, '_', num2str(td(1).(unitGuide)(i,1)), ' Unit ', num2str(td(1).(unitGuide)(i,2))];

    
    if tuned(i)
        title1 = [title1, '_TUNED'];
    end
    if histogramFlag & tuned(i)

        f1 = figure('Position', [100, 100, 1200, 800]);
        sp1 = subplot(2,1,1);
        histogram(bootstatRightBump)
        hold on
        histogram(bootstatLeftBump)
        histogram(bootstatUpBump)
        histogram(bootstatDownBump)
        histogram(bootstatPreBump)
        title([strrep(title1, '_', ' '), ' Bump Tuning'])
        xlabel('Firing')
        legend('show')

        sp2= subplot(2,1,2);
        histogram(bootstatRightMove)
        hold on
        histogram(bootstatLeftMove)
        histogram(bootstatUpMove)
        histogram(bootstatDownMove)
        histogram(bootstatPreMove)
        title([strrep(title1, '_', ' '), ' Move Tuning'])
        xlabel('Firing')
        legend('show')

        linkaxes([sp1, sp2]);
        figTitle = [title1, 'Histogram.pdf'];
        if(saveFig)
            saveas(f1,strrep(figTitle, ' ', '_'));
        end
    end
    if circleFlag & tuned(i)
        theta = [0, pi/2, pi, 3*pi/2, 0];
        bumpMean = [meanRightBump, meanUpBump, meanLeftBump, meanDownBump, meanRightBump];
        bumpHigh = [topRightBump , topUpBump, topLeftBump, topDownBump, topRightBump];
        bumpLow = [botRightBump, botUpBump, botLeftBump, botDownBump, botRightBump];

        moveMean = [meanRightMove, meanUpMove, meanLeftMove, meanDownMove, meanRightMove];
        moveHigh = [topRightMove , topUpMove, topLeftMove, topDownMove, topRightMove];
        moveLow = [botRightMove, botUpMove, botLeftMove, botDownMove, botRightMove]; 

        f2 = figure('Position', [100, 0, 600, 600]); 
        polarplot(theta, bumpHigh, 'Color', [1,.4,.4], 'LineWidth', 2)
        hold on 
        polarplot(theta, bumpMean, 'Color', [1,0,0], 'LineWidth', 2)
        polarplot(theta, bumpLow, 'Color', [1,.4,.4], 'LineWidth', 2)

        polarplot([angBump(i), angBump(i)], [0, magBump(i)],'Color', [1,0,0], 'LineWidth', 2);
        polarplot([lowAngBump(i), lowAngBump(i)], [0, magBump(i)],'Color', [1, .4,.4], 'LineWidth', 2);
        polarplot([highAngBump(i), highAngBump(i)], [0, magBump(i)],'Color', [1, .4,.4], 'LineWidth', 2);
        title('Bump')
        
        polarplot(theta, moveHigh, 'Color', [.4,.4,1], 'LineWidth', 2)
        polarplot(theta, moveMean, 'Color', [0,0,1], 'LineWidth', 2)
        polarplot(theta, moveLow, 'Color', [.4,.4,1], 'LineWidth', 2)
        
        angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
        magMove(i) = norm(pdVecMove(i,:));
        polarplot([angMove(i), angMove(i)], [0, magMove(i)],'Color', [0 0 1 ], 'LineWidth', 2);
        polarplot([lowAngMove(i), lowAngMove(i)], [0, magMove(i)],'Color', [.4 .4 1], 'LineWidth', 2);
        polarplot([highAngMove(i), highAngMove(i)], [0, magMove(i)],'Color', [.4 .4 1], 'LineWidth', 2);
        
        title([strrep(title1, '_', ' '), ' Tuning Curves'])
        legend('show')
        figTitle = [title1, 'TuningCurve.pdf'];
        if(saveFig)
            saveas(f2, strrep(figTitle, ' ', '_'));
        end
    end
    close all

    outStruct(i).angBump.high = highAngBump(i);
    outStruct(i).angBump.low = lowAngBump(i);
    outStruct(i).angBump.mean = angBump(i);

outStruct(i).angMove.high = highAngMove(i);
outStruct(i).angMove.low = lowAngMove(i);
outStruct(i).angMove.mean = angMove(i);

outStruct(i).moveTuned= sigDifMove(i);
outStruct(i).bumpTuned = sigDifBump(i);
outStruct(i).preMove.mean = meanPreMove(i);
outStruct(i).preMove.high = topPreMove(i);
outStruct(i).preMove.low = botPreMove(i);

outStruct(i).postMove.mean = meanPostMove(i);
outStruct(i).postMove.high = topPostMove(i);
outStruct(i).postMove.low = botPostMove(i);

%%
outStruct(i).firing.bump.left.mean = meanLeftBump;
outStruct(i).firing.bump.left.high = topLeftBump;
outStruct(i).firing.bump.left.low= botLeftBump;

outStruct(i).firing.bump.right.mean = meanRightBump;
outStruct(i).firing.bump.right.high = topRightBump;
outStruct(i).firing.bump.right.low = botRightBump;

outStruct(i).firing.bump.up.mean = meanUpBump;
outStruct(i).firing.bump.up.high = topUpBump;
outStruct(i).firing.bump.up.low = botUpBump;

outStruct(i).firing.bump.down.mean = meanDownBump;
outStruct(i).firing.bump.down.high = topDownBump;
outStruct(i).firing.bump.down.low = botDownBump;

%%

outStruct(i).firing.move.left.mean = meanLeftMove;
outStruct(i).firing.move.left.high = topLeftMove;
outStruct(i).firing.move.left.low= botLeftMove;

outStruct(i).firing.move.right.mean = meanRightMove;
outStruct(i).firing.move.right.high = topRightMove;
outStruct(i).firing.move.right.low = botRightMove;

outStruct(i).firing.move.up.mean = meanUpMove;
outStruct(i).firing.move.up.high = topUpMove;
outStruct(i).firing.move.up.low = botUpMove;

outStruct(i).firing.move.down.mean = meanDownMove;
outStruct(i).firing.move.down.high = topDownMove;
outStruct(i).firing.move.down.low = botDownMove;
%%

outStruct(i).date = date;
outStruct(i).array = array;


pasActDif = angleDiff(angBump(i), angMove(i));

outStruct(i).pasActDif = pasActDif;
outStruct(i).numPasDif = sum(sigDifBump(i));
outStruct(i).numActDif = sum(sigDifMove(i));


outStruct(i).dcBump = dcBump(i);
outStruct(i).dcMove= dcMove(i);

outStruct(i).modDepthMove=modDepthMove(i);
outStruct(i).modDepthBump = modDepthBump(i);

outStruct(i).tuned= tuned(i);
end
%%


if plotFlag
    coActPasPlotting(outStruct);
end
fh=[];
end

