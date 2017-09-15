   close all
   sigDif = zeros(19,1);
   vec = 1:19;
   noVec = [7, 10, 12, 14, 15, 16, 18];
   histogramFlag= true;
   circleFlag = true;
    cuneateFlag = true;
for i = 1:length(shortRightBumpFiring)
    close all
    temp =mean(shortRightBumpFiring{i});
    bootstatRightBump= bootstrp(1000, @mean, temp);
    temp =mean(shortLeftBumpFiring{i});
    bootstatLeftBump= bootstrp(1000, @mean, temp);
    temp =mean(shortDownBumpFiring{i});
    bootstatDownBump= bootstrp(1000, @mean, temp);
    temp =mean(shortUpBumpFiring{i});
    bootstatUpBump= bootstrp(1000, @mean, temp);
    temp = mean(preBumpFiring{i});
    bootstatPreBump = bootstrp(1000,@mean, temp);
    
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
    
    temp =mean(shortRightMoveFiring{i});
    bootstatRightMove= bootstrp(1000, @mean, temp);
    temp =mean(shortLeftMoveFiring{i});
    bootstatLeftMove= bootstrp(1000, @mean, temp);
    temp =mean(shortDownMoveFiring{i});
    bootstatDownMove= bootstrp(1000, @mean, temp);
    temp =mean(shortUpMoveFiring{i});
    bootstatUpMove= bootstrp(1000, @mean, temp);
    temp = mean(preMoveFiring{i});
    bootstatPreMove = bootstrp(1000,@mean, temp);   

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
    
    if histogramFlag
        if cuneateFlag
            title1 = ['CuneateElectrode' num2str(td(1).RightCuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).RightCuneate_unit_guide(i,2))];
        else
            title1 = ['S1Electrode' num2str(td(1).LeftS1_unit_guide(i,1)), ' Unit ', num2str(td(1).LeftS1_unit_guide(i,2))];
        end
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
        figTitle = [title1, 'Histogram.pdf'];
        saveas(f1,figTitle);
    end
    if circleFlag   
        theta = [0, pi/2, pi, 3*pi/2, 0];
        bumpMean = [meanRightBump, meanUpBump, meanLeftBump, meanDownBump, meanRightBump];
        bumpHigh = [topRightBump , topUpBump, topLeftBump, topDownBump, topRightBump];
        bumpLow = [botRightBump, botUpBump, botLeftBump, botDownBump, botRightBump];

        moveMean = [meanRightMove, meanUpMove, meanLeftMove, meanDownMove, meanRightMove];
        moveHigh = [topRightMove , topUpMove, topLeftMove, topDownMove, topRightMove];
        moveLow = [botRightMove, botUpMove, botLeftMove, botDownMove, botRightMove]; 

        f2 = figure('Position', [100, 0, 600, 1200]); 
        sp1 = subplot(4,1,1:2);
        polar(theta, bumpHigh, 'r')
        hold on 
        polar(theta, bumpMean, 'k')
        polar(theta, bumpLow, 'b')
        angBump(i) = atan2(pdVecBump(i, 2), pdVecBump(i,1));
        magBump(i) = norm(pdVecBump(i,:));
        polar([angBump(i), angBump(i)], [0, magBump(i)]);
        title1 = ['Bump'];
        title(title1)
        
        sp2 = subplot(4,1,3:4);
        polar(theta, moveHigh, 'r')
        hold on 
        polar(theta, moveMean, 'k')
        polar(theta, moveLow, 'b')
        angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
        magMove(i) = norm(pdVecMove(i,:));
        polar([angMove(i), angMove(i)], [0, magMove(i)]);
        title('Move')
        linkaxes([sp1, sp2])
        suptitle(title1)
        figTitle = [title1, 'TuningCurve.pdf'];
        saveas(f2, figTitle);
    end
    
    
end
figure
scatter(angBump, angMove)
pctSigBump = sum(sigDifBump)/12;
pctSigMove = sum(sigDifMove)/12;