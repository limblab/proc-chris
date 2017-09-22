   close all
  %% Compute firing in respective windows
  clearvars -except cds
    beforeBump = .3;
    afterBump = .3;
    beforeMove = .3;
    afterMove = .3;
    
    date1= '03202017';
    histogramFlag= true;
    circleFlag = true;
    cuneateFlag = true;
    spikeFlag = false;
    
    spikeTable = cds.units;
    sortedTable = spikeTable(strcmp({spikeTable.array},'RightCuneate') & [spikeTable.ID]>0);
    saveFig =true;
    if ~cuneateFlag
        unitLabel = 'LeftS1';
    else
        unitLabel = 'RightCuneate';
    end
    unitGuide = [unitLabel, '_unit_guide'];
    unitSpikes = [unitLabel, '_spikes'];
    spikeLabel = [unitLabel, '_spikes'];
    params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
    params.extra_time = [.4,.6];
    td = parseFileByTrial(cds, params);
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
    temp =mean(shortRightBumpFiring{i})*100;
    bootstatRightBump= bootstrp(1000, @mean, temp);
    temp =mean(shortLeftBumpFiring{i})*100;
    bootstatLeftBump= bootstrp(1000, @mean, temp);
    temp =mean(shortDownBumpFiring{i})*100;
    bootstatDownBump= bootstrp(1000, @mean, temp);
    temp =mean(shortUpBumpFiring{i})*100;
    bootstatUpBump= bootstrp(1000, @mean, temp);
    temp = mean(preBumpFiring{i})*100;
    bootstatPreBump = bootstrp(1000,@mean, temp);
    temp = mean([shortRightBumpFiring{i}*100; shortLeftBumpFiring{i}*100; shortUpBumpFiring{i}*100; shortDownBumpFiring{i}*100]);
    bootstatPostBump = bootstrp(1000,@mean, temp);
    meanPostBump = mean(bootstatPostBump);
    dcBump(i) = meanPostBump - mean(bootstatPreBump);
    
    
    
    sortedRightBump = sort(bootstatRightBump);
    sortedLeftBump = sort(bootstatLeftBump);
    sortedUpBump = sort(bootstatUpBump);
    sortedDownBump = sort(bootstatDownBump);
    sortedPreBump = sort(bootstatPreBump);
    
    meanRightBump = mean(sortedRightBump);
    topRightBump = sortedRightBump(975);
    botRightBump = sortedRightBump(25);
    
    meanLeftBump = mean(sortedLeftBump);
    topLeftBump = sortedLeftBump(975);
    botLeftBump = sortedLeftBump(25);
    
    meanUpBump = mean(sortedUpBump);
    topUpBump = sortedUpBump(975);
    botUpBump = sortedUpBump(25);
    
    meanDownBump = mean(sortedDownBump);
    topDownBump = sortedDownBump(975);
    botDownBump = sortedDownBump(25);
    
    meanPreBump = mean(sortedPreBump);
    topPreBump = sortedPreBump(25);
    botPreBump = sortedPreBump(975);
    
    bumpTuned(i) = meanDownBump > topPreBump | meanUpBump > topPreBump | meanRightBump > topPreBump| meanLeftBump > topPreBump |...
        meanDownBump < botPreBump | meanUpBump< botPreBump | meanRightBump< botPreBump | meanLeftBump < botPreBump;
    rightSigBump(i) = topRightBump<meanLeftBump | topRightBump<meanUpBump | topRightBump<meanDownBump | botRightBump > meanLeftBump | botRightBump >meanUpBump | botRightBump > meanDownBump;
    leftSigBump(i) = topLeftBump<meanRightBump | topLeftBump<meanUpBump | topLeftBump<meanDownBump | botLeftBump > meanRightBump | botLeftBump >meanUpBump | botLeftBump > meanDownBump;
    upSigBump(i) = topUpBump<meanRightBump | topUpBump<meanLeftBump | topUpBump<meanDownBump | botUpBump > meanRightBump | botUpBump >meanLeftBump | botUpBump > meanDownBump;
    downSigBump(i) = topDownBump<meanRightBump | topDownBump<meanUpBump | topDownBump<meanLeftBump | botDownBump > meanRightBump | botDownBump >meanUpBump | botDownBump > meanLeftBump;
    
    sigDifBump(i) = rightSigBump(i) | leftSigBump(i) | upSigBump(i) | downSigBump(i);
    
    temp =mean(shortRightMoveFiring{i})*100;
    bootstatRightMove= bootstrp(1000, @mean, temp);
    temp =mean(shortLeftMoveFiring{i})*100;
    bootstatLeftMove= bootstrp(1000, @mean, temp);
    temp =mean(shortDownMoveFiring{i})*100;
    bootstatDownMove= bootstrp(1000, @mean, temp);
    temp =mean(shortUpMoveFiring{i})*100;
    bootstatUpMove= bootstrp(1000, @mean, temp);
    temp = mean(preMoveFiring{i})*100;
    bootstatPreMove = bootstrp(1000,@mean, temp);   
    temp = mean([shortRightMoveFiring{i}*100; shortLeftMoveFiring{i}*100; shortUpMoveFiring{i}*100; shortDownMoveFiring{i}*100]);
    bootstatPostMove = bootstrp(1000,@mean, temp);
    dcMove(i) = mean(bootstatPostMove) - mean(bootstatPreMove);
    
%     figure
%     histogram(bootstatPreMove)
%     hold on
%     histogram(bootstatPostMove)
%     histogram(bootstatPreBump)
%     histogram(bootstatPostBump)
%     legend('show')
    
    sortedRightMove = sort(bootstatRightMove);
    sortedLeftMove = sort(bootstatLeftMove);
    sortedUpMove = sort(bootstatUpMove);
    sortedDownMove = sort(bootstatDownMove);
    sortedPreMove = sort(bootstatPreMove);

    meanRightMove = mean(sortedRightMove);
    topRightMove = sortedRightMove(975);
    botRightMove = sortedRightMove(25);

    meanLeftMove = mean(sortedLeftMove);
    topLeftMove = sortedLeftMove(975);
    botLeftMove = sortedLeftMove(25);

    meanUpMove = mean(sortedUpMove);
    topUpMove = sortedUpMove(975);
    botUpMove = sortedUpMove(25);

    meanDownMove = mean(sortedDownMove);
    topDownMove = sortedDownMove(975);
    botDownMove = sortedDownMove(25);
    
    meanPreMove = mean(sortedPreMove);
    topPreMove = sortedPreMove(975);
    botPreMove = sortedPreMove(25);
    
    modDepthMove(i) = max([meanUpMove, meanDownMove, meanLeftMove, meanRightMove]) - min([meanUpMove, meanDownMove, meanLeftMove, meanRightMove]);
    modDepthBump(i) = max([meanUpBump, meanDownBump, meanLeftBump, meanRightBump]) - min([meanUpBump, meanDownBump, meanLeftBump, meanRightBump]);

    
    rightMoveSig(i) = topRightMove<meanLeftMove | topRightMove<meanUpMove | topRightMove<meanDownMove | botRightMove > meanLeftMove | botRightMove >meanUpMove | botRightMove > meanDownMove;
    leftMoveSig(i) = topLeftMove<meanRightMove | topLeftMove<meanUpMove | topLeftMove<meanDownMove | botLeftMove > meanRightMove | botLeftMove >meanUpMove | botLeftMove > meanDownMove;
    upMoveSig(i) = topUpMove<meanRightMove | topUpMove<meanLeftMove | topUpMove<meanDownMove | botUpMove > meanRightMove | botUpMove >meanLeftMove | botUpMove > meanDownMove;
    downMoveSig(i) = topDownMove<meanRightMove | topDownMove<meanUpMove | topDownMove<meanLeftMove | botDownMove > meanRightMove | botDownMove >meanUpMove | botDownMove > meanLeftMove;
    moveTuned(i) = meanDownMove > topPreMove | meanUpMove > topPreMove | meanRightMove > topPreMove| meanLeftMove > topPreMove |...
    meanDownMove < botPreMove | meanUpMove< botPreMove | meanRightMove< botPreMove | meanLeftMove < botPreMove;

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
    
    sigThreshold = pi/2;
    
    sinTunedMove(i) = highAngMove(i)-lowAngMove(i)< sigThreshold;
    sinTunedBump(i) = highAngBump(i)-lowAngBump(i) < sigThreshold;
    
    goodFiring(i) = meanDownMove>0 & meanUpMove >0 & meanRightMove >0 & meanLeftMove >0 & meanDownBump >0 & meanUpBump >0 & meanRightBump>0 & meanLeftBump >0;
    
    tuned(i) = sigDifMove(i) & sigDifBump(i) & goodFiring(i);% &sinTunedMove(i) & sinTunedBump(i);
    if cuneateFlag
        title1 = ['Cuneate_Lando_Electrode_', date1,'_', num2str(td(1).(unitGuide)(i,1)), '_Unit ', num2str(td(1).(unitGuide)(i,2))];
    else
        title1 = ['S1_Lando_Electrode_',date1, '_', num2str(td(1).(unitGuide)(i,1)), ' Unit ', num2str(td(1).(unitGuide)(i,2))];
    end
    
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
    if spikeFlag
        spikeWaveshape = sortedTable(i).spikes.wave;
        f6 = figure;
        plot(linspace(0,1.6, 48), spikeWaveshape, 'k')
        title([strrep(title1, '_', ' '), ' Wave Shape'])
        saveas(f6, [title1, 'WaveShape.pdf'])
        
    end
end
%%
f3 = figure;

angBumpTuned= angBump(tuned);
angMoveTuned = angMove(tuned);
scatter(rad2deg(angBumpTuned), rad2deg(angMoveTuned))
hold on
plot([-180, 180], [-180, 180])
ylim([-180, 180])
xlim([-180, 180])
title('Angle of PD in Active/Passive Conditions')
xlabel('Passive PD')
ylabel('ActivePD')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [-180,-135, -90,-45,0,45, 90, 135, 180],'ytick', [-180,-135, -90,-45,0,45, 90, 135, 180])
saveas(f3, ['ActiveVsPassive', unitLabel, date1,'.pdf'])

pasActDif = angleDiff(angBump, angMove);
f4 =figure;
histogram(rad2deg(pasActDif),15)
title('Angle Between Active and Passive')
pctSigBump = sum(sigDifBump)/12;
pctSigMove = sum(sigDifMove)/12;
saveas(f4, ['AngleBetweenActPas',unitLabel, date1,'.pdf'])

f5 = figure; 
histogram(dcBump,6)
hold on
histogram(dcMove,6)
legend('show')
title('Move Avg. Firing vs. Bump Avg. Firing')
saveas(f5, ['AvgFiringMoveVsBump',unitLabel, date1,'.pdf'])

f6 = figure;
scatter(modDepthMove(tuned), modDepthBump(tuned))
title('Modulation Depth in Active vs. Passive')
xlabel('Max Modulation Depth in Active')
ylabel('Max Modulation Depth in Passive')
set(gca,'TickDir','out', 'box', 'off')
