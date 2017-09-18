   close all
   sigDif = zeros(19,1);
   
   histogramFlag= true;
   circleFlag = true;
    cuneateFlag = true;
    saveFig = true;
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
    bootPDAngMove{i} = atan2(pdVecMoveBoot{i}(:,2), pdVecMoveBoot{i}(:,1));
    bootPDMagMove{i} = rownorm(pdVecMoveBoot{i});
    
    bootPDAngBump{i} = atan2(pdVecBumpBoot{i}(:,2), pdVecBumpBoot{i}(:,1));
    bootPDMagBump{i} = rownorm(pdVecBumpBoot{i});
 
    sortedAngBump = sort(bootPDAngBump{i});
    lowAngBump(i) = sortedAngBump(50);
    highAngBump(i) = sortedAngBump(950);
    
    sortedAngMove = sort(bootPDAngMove{i});
    lowAngMove(i) = sortedAngMove(50);
    highAngMove(i) = sortedAngMove(950);
    
    sigThreshold = pi/3;
    
    sinTunedMove(i) = angleDiffCV(highAngMove(i),lowAngMove(i)) < sigThreshold & angleDiffCV(highAngMove(i), lowAngMove(i)) > angleDiffCV(highAngMove(i), mean(sortedAngMove)) & angleDiffCV(highAngMove(i), lowAngMove(i)) > angleDiffCV(lowAngMove(i), mean(sortedAngMove));
    sinTunedBump(i) = angleDiffCV(highAngBump(i),lowAngBump(i)) < sigThreshold & angleDiffCV(highAngBump(i), lowAngBump(i)) > angleDiffCV(highAngBump(i), mean(sortedAngBump)) & angleDiffCV(highAngBump(i), lowAngBump(i)) > angleDiffCV(lowAngBump(i), mean(sortedAngBump));
    
    tuned(i) = sigDifMove(i) & sigDifBump(i) &sinTunedMove(i) & sinTunedBump(i);
    if cuneateFlag
        title1 = ['CuneateElectrode_09032017 ' num2str(td(1).cuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).cuneate_unit_guide(i,2))];
    else
        title1 = ['S1Electrode ' num2str(td(1).LeftS1_unit_guide(i,1)), ' Unit ', num2str(td(1).LeftS1_unit_guide(i,2))];
    end
    
    if tuned(i)
        title1 = [title1, ' TUNED'];
    end
    if histogramFlag

        f1 = figure('Position', [100, 100, 1200, 800]);
        sp1 = subplot(2,1,1);
        histogram(bootstatRightBump)
        hold on
        histogram(bootstatLeftBump)
        histogram(bootstatUpBump)
        histogram(bootstatDownBump)
        histogram(bootstatPreBump)
        title([title1, ' Bump Tuning'])
        xlabel('Firing')
        legend('show')

        sp2= subplot(2,1,2);
        histogram(bootstatRightMove)
        hold on
        histogram(bootstatLeftMove)
        histogram(bootstatUpMove)
        histogram(bootstatDownMove)
        histogram(bootstatPreMove)
        title([title1, ' Move Tuning'])
        xlabel('Firing')
        legend('show')

        linkaxes([sp1, sp2]);
        figTitle = [title1, 'Histogram.png'];
        if(saveFig)
            saveas(f1,figTitle);
        end
    end
    if circleFlag
        theta = [0, pi/2, pi, 3*pi/2, 0];
        bumpMean = [meanRightBump, meanUpBump, meanLeftBump, meanDownBump, meanRightBump];
        bumpHigh = [topRightBump , topUpBump, topLeftBump, topDownBump, topRightBump];
        bumpLow = [botRightBump, botUpBump, botLeftBump, botDownBump, botRightBump];

        moveMean = [meanRightMove, meanUpMove, meanLeftMove, meanDownMove, meanRightMove];
        moveHigh = [topRightMove , topUpMove, topLeftMove, topDownMove, topRightMove];
        moveLow = [botRightMove, botUpMove, botLeftMove, botDownMove, botRightMove]; 

        f2 = figure('Position', [100, 0, 600, 600]); 
        polarplot(theta, bumpHigh, 'Color', [.5,.3,.3], 'LineWidth', 2)
        hold on 
        polarplot(theta, bumpMean, 'Color', [1,0,0], 'LineWidth', 2)
        polarplot(theta, bumpLow, 'Color', [1,.4,.4], 'LineWidth', 2)

        polarplot([angBump(i), angBump(i)], [0, magBump(i)],'Color', [1,0,0], 'LineWidth', 2);
        polarplot([lowAngBump(i), lowAngBump(i)], [0, magBump(i)],'Color', [1, .4,.4], 'LineWidth', 2);
        polarplot([highAngBump(i), highAngBump(i)], [0, magBump(i)],'Color', [1, .4,.4], 'LineWidth', 2);
        title('Bump')
        
        polarplot(theta, moveHigh, 'Color', [.3,.3,.5], 'LineWidth', 2)
        polarplot(theta, moveMean, 'Color', [0,0,1], 'LineWidth', 2)
        polarplot(theta, moveLow, 'Color', [.4,.4,1], 'LineWidth', 2)
        
        angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
        magMove(i) = norm(pdVecMove(i,:));
        polarplot([angMove(i), angMove(i)], [0, magMove(i)],'Color', [0 0 1 ], 'LineWidth', 2);
        polarplot([lowAngMove(i), lowAngMove(i)], [0, magMove(i)],'Color', [.4 .4 1], 'LineWidth', 2);
        polarplot([highAngMove(i), highAngMove(i)], [0, magMove(i)],'Color', [.4 .4 1], 'LineWidth', 2);
        
        title([title1, ' Tuning Curves'])
        legend('show')
        figTitle = [title1, 'TuningCurve.png'];
        if(saveFig)
            saveas(f2, figTitle);
        end
    end
    
end
%%
f3 = figure;
scatter(angBump(tuned), angMove(tuned))
ylim([-pi, pi])
xlim([-pi, pi])
title('Angle of PD in Active/Passive Conditions')
xlabel('Passive PD')
ylabel('ActivePD')
saveas(f3, 'ActiveVsPassiveS103202017.png')
pctSigBump = sum(sigDifBump)/12;
pctSigMove = sum(sigDifMove)/12;

figure 
histogram(dcBump,6)
hold on
histogram(dcMove,6)
legend('show')