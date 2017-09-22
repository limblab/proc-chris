up = [0,1];
down =[0,-1];
left= [-1,0];
right=[1,0];
%15:53
for muscleNum = 33
    downBumpPec = zeros(11, length(downBump));
    for i = 1:length(downBump)
        downBumpPec(:,i) = downBump(i).opensim(downBump(i).idx_bumpTime:downBump(i).idx_bumpTime+10,muscleNum);
    end

    upBumpPec = zeros(11, length(upBump));
    for i =1:length(upBump)
        upBumpPec(:,i) = upBump(i).opensim(upBump(i).idx_bumpTime:upBump(i).idx_bumpTime+10,muscleNum);
    end

    leftBumpPec = zeros(11, length(leftBump));
    for i =1:length(leftBump)
        leftBumpPec(:,i) = leftBump(i).opensim(leftBump(i).idx_bumpTime:leftBump(i).idx_bumpTime+10,muscleNum);
    end

    rightBumpPec = zeros(11, length(rightBump));
    for i =1:length(rightBump)
        rightBumpPec(:,i) = rightBump(i).opensim(rightBump(i).idx_bumpTime:rightBump(i).idx_bumpTime+10,muscleNum);
    end

    downMovePec = zeros(11, length(downMove));
    for i = 1:length(downMovePec(1,:))
        downMovePec(:,i) = downMove(i).opensim(downMove(i).idx_movement_on:downMove(i).idx_movement_on+10,muscleNum);
    end

    upMovePec = zeros(11, length(upMove));
    for i =1:length(upMovePec(1,:))
        upMovePec(:,i) = upMove(i).opensim(upMove(i).idx_movement_on:upMove(i).idx_movement_on+10,muscleNum);
    end

    leftMovePec = zeros(11, length(leftMove));
    for i =1:length(leftMovePec(1,:))
        leftMovePec(:,i) = leftMove(i).opensim(leftMove(i).idx_movement_on:leftMove(i).idx_movement_on+10,muscleNum);
    end

    rightMovePec = zeros(11, length(rightMove));
    for i =1:length(rightMovePec(1,:))
        rightMovePec(:,i) = rightMove(i).opensim(rightMove(i).idx_movement_on:rightMove(i).idx_movement_on+10,muscleNum);
    end

    startDownBump = downBumpPec(1,:);
    startDownMove = downMovePec(1,:);

    startUpBump = upBumpPec(1,:);
    startUpMove = upMovePec(1,:);

    startRightBump = rightBumpPec(1,:);
    startRightMove = rightMovePec(1,:);

    startLeftBump = leftBumpPec(1,:);
    startLeftMove = leftMovePec(1,:);

    endLeftBump = leftBumpPec(end,:);
    endLeftMove = leftMovePec(end,:);

    endRightBump = rightBumpPec(end,:);
    endRightMove = rightMovePec(end,:);

    endUpBump = upBumpPec(end,:);
    endUpMove = upMovePec(end,:);

    endDownBump = downBumpPec(end,:);
    endDownMove = downMovePec(end,:);

    difBumpLeft = endLeftBump - startLeftBump;
    difBumpRight = endRightBump - startRightBump;
    difBumpUp = endUpBump - startUpBump;
    difBumpDown = endDownBump - startDownBump;

    difMoveLeft = endLeftMove -  startLeftMove;
    difMoveRight = endRightMove - startRightMove;
    difMoveUp = endUpMove - startUpMove;
    difMoveDown = endDownMove - startDownMove;
    %%
    bootstatLeftDLenMove = bootstrp(1000,@mean, difMoveLeft);
    bootstatRightDLenMove = bootstrp(1000,@mean, difMoveRight);
    bootstatUpDLenMove = bootstrp(1000,@mean, difMoveUp);
    bootstatDownDLenMove = bootstrp(1000,@mean, difMoveDown);

    bootPDMove = up.*bootstatUpDLenMove + down.*bootstatDownDLenMove+ left.*bootstatLeftDLenMove + right.*bootstatRightDLenMove;
    angPDMove = atan2(bootPDMove(:,2), bootPDMove(:,1));
    magPDMove = rownorm(bootPDMove);
    sortedAngPDMove = sort(angPDMove);
    lowAngPDMove = sortedAngPDMove(25);
    highAngPDMove = sortedAngPDMove(975);
    
    sortedLeftDLenMove = sort(bootstatLeftDLenMove);
    sortedRightDLenMove = sort(bootstatRightDLenMove);
    sortedUpDLenMove = sort(bootstatUpDLenMove);
    sortedDownDLenMove = sort(bootstatDownDLenMove);


    lowLeftDLenMove = sortedLeftDLenMove(25);
    highLeftDLenMove = sortedLeftDLenMove(975);
    leftDLenMove = mean(sortedLeftDLenMove);

    lowRightDLenMove = sortedRightDLenMove(25);
    highRightDLenMove = sortedRightDLenMove(975);
    rightDLenMove = mean(sortedRightDLenMove);

    lowUpDLenMove = sortedUpDLenMove(25);
    highUpDLenMove = sortedUpDLenMove(975);
    upDLenMove = mean(sortedUpDLenMove);

    lowDownDLenMove = sortedDownDLenMove(25);
    highDownDLenMove = sortedDownDLenMove(975);
    downDLenMove = mean(sortedDownDLenMove);

    muscleActivePD = up*upDLenMove + down*downDLenMove + right*rightDLenMove + left*leftDLenMove;

    muscleActiveAng= atan2(muscleActivePD(2), muscleActivePD(1));
    muscleActiveMag = norm(muscleActivePD);
    %%
    bootstatLeftDLenBump = bootstrp(1000,@mean, difBumpLeft);
    bootstatRightDLenBump = bootstrp(1000,@mean, difBumpRight);
    bootstatUpDLenBump = bootstrp(1000,@mean, difBumpUp);
    bootstatDownDLenBump = bootstrp(1000,@mean, difBumpDown);

    bootPDBump = up.*bootstatUpDLenBump + down.*bootstatDownDLenBump+ left.*bootstatLeftDLenBump + right.*bootstatRightDLenBump;
    angPDBump = atan2(bootPDBump(:,2), bootPDBump(:,1));
    magPDBump = rownorm(bootPDBump);
    sortedAngPDBump = sort(angPDBump);
    lowAngPDBump = sortedAngPDBump(25);
    highAngPDBump = sortedAngPDBump(975);
    
    
    sortedLeftDLenBump = sort(bootstatLeftDLenBump);
    sortedRightDLenBump = sort(bootstatRightDLenBump);
    sortedUpDLenBump = sort(bootstatUpDLenBump);
    sortedDownDLenBump = sort(bootstatDownDLenBump);


    lowLeftDLenBump = sortedLeftDLenBump(25);
    highLeftDLenBump = sortedLeftDLenBump(975);
    leftDLenBump = mean(sortedLeftDLenBump);

    lowRightDLenBump = sortedRightDLenBump(25);
    highRightDLenBump = sortedRightDLenBump(975);
    rightDLenBump = mean(sortedRightDLenBump);

    lowUpDLenBump = sortedUpDLenBump(25);
    highUpDLenBump = sortedUpDLenBump(975);
    upDLenBump = mean(sortedUpDLenBump);

    lowDownDLenBump = sortedDownDLenBump(25);
    highDownDLenBump = sortedDownDLenBump(975);
    downDLenBump = mean(sortedDownDLenBump);

    musclePassivePD = up*upDLenBump + down*downDLenBump + right*rightDLenBump + left*leftDLenBump;

    musclePassiveAng= atan2(musclePassivePD(2), musclePassivePD(1));
    musclePassiveMag = norm(musclePassivePD);

    %%
    figure
    polarplot([muscleActiveAng, muscleActiveAng], [0, muscleActiveMag], 'b')
    hold on
    polarplot([highAngPDBump, highAngPDBump], [0, musclePassiveMag],'Color', [1,.4,.4], 'LineWidth', 2) 
    polarplot([musclePassiveAng, musclePassiveAng], [0, musclePassiveMag],'Color', [1,0,0], 'LineWidth', 2)
    polarplot([lowAngPDBump, lowAngPDBump], [0, musclePassiveMag], 'Color', [1,.4,.4], 'LineWidth', 2)
    polarplot([lowAngPDMove, lowAngPDMove], [0, muscleActiveMag],'Color', [.4,.4,1], 'LineWidth', 2)
    polarplot([highAngPDMove, highAngPDMove], [0, muscleActiveMag],'Color', [.4,.4,1], 'LineWidth', 2)
    legend('show')
    title(strrep(td(1).opensim_names{muscleNum}, '_', ' '))
    
    %%
    
end
%%
close all

afterBins = 10;
binStart = -10;
for muscleNum = 1:length(td(1).emg(1,:))
    downBumpEMG = zeros(afterBins+1-binStart, length(downBump));
    for i = 1:length(downBump)
        downBumpEMG(:,i) = downBump(i).emg(downBump(i).idx_bumpTime+binStart:downBump(i).idx_bumpTime+afterBins,muscleNum);
    end

    upBumpEMG = zeros(afterBins+1-binStart, length(upBump));
    for i =1:length(upBump)
        upBumpEMG(:,i) = upBump(i).emg(upBump(i).idx_bumpTime+binStart:upBump(i).idx_bumpTime+afterBins,muscleNum);
    end

    leftBumpEMG = zeros(afterBins+1-binStart, length(leftBump));
    for i =1:length(leftBump)
        leftBumpEMG(:,i) = leftBump(i).emg(leftBump(i).idx_bumpTime+binStart:leftBump(i).idx_bumpTime+afterBins,muscleNum);
    end

    rightBumpEMG = zeros(afterBins+1-binStart, length(rightBump));
    for i =1:length(rightBump)
        rightBumpEMG(:,i) = rightBump(i).emg(rightBump(i).idx_bumpTime+binStart:rightBump(i).idx_bumpTime+afterBins,muscleNum);
    end
    
    

    downMoveEMG = zeros(afterBins+1-binStart, length(downMove));
    for i = 1:length(downMove)
        downMoveEMG(:,i) = downMove(i).emg(downMove(i).idx_movement_on+binStart:downMove(i).idx_movement_on+afterBins,muscleNum);
    end

    upMoveEMG = zeros(afterBins+1-binStart, length(upMove));
    for i =1:length(upMove)
        upMoveEMG(:,i) = upMove(i).emg(upMove(i).idx_movement_on+binStart:upMove(i).idx_movement_on+afterBins,muscleNum);
    end

    leftMoveEMG = zeros(afterBins+1-binStart, length(leftMove));
    for i =1:length(leftMove)
        leftMoveEMG(:,i) = leftMove(i).emg(leftMove(i).idx_movement_on+binStart:leftMove(i).idx_movement_on+afterBins,muscleNum);
    end

    rightMoveEMG = zeros(afterBins+1-binStart, length(rightMove));
    for i =1:length(rightMove)
        rightMoveEMG(:,i) = rightMove(i).emg(rightMove(i).idx_movement_on+binStart:rightMove(i).idx_movement_on+afterBins,muscleNum);
    end
    
    meanDownBumpEMG = mean(mean(downBumpEMG));
    meanUpBumpEMG = mean(mean(upBumpEMG));
    meanLeftBumpEMG = mean(mean(leftBumpEMG));
    meanRightBumpEMG = mean(mean(rightBumpEMG));
    
    trialDownBumpEMG = mean(downBumpEMG,2);
    trialUpBumpEMG = mean(upBumpEMG,2);
    trialRightBumpEMG = mean(rightBumpEMG,2);
    trialLeftBumpEMG = mean(leftBumpEMG,2);
    
    meanDownMoveEMG = mean(mean(downMoveEMG));
    meanUpMoveEMG = mean(mean(upMoveEMG));
    meanLeftMoveEMG = mean(mean(leftMoveEMG));
    meanRightMoveEMG = mean(mean(rightMoveEMG));
    
    trialDownMoveEMG = mean(downMoveEMG, 2);
    trialUpMoveEMG = mean(upMoveEMG,2);
    trialRightMoveEMG = mean(rightMoveEMG,2);
    trialLeftMoveEMG = mean(leftMoveEMG,2);
    
    figure 
    maxVal = max(max([upMoveEMG, leftMoveEMG, rightMoveEMG, downMoveEMG]));
    subplot(3,3,2)
%     plot(upBumpEMG,'r')
%     hold on
    plot(upMoveEMG, 'b')
    ylim([0, maxVal])
    subplot(3,3,4)
%     plot(leftBumpEMG, 'r')
%     hold on
    plot(leftMoveEMG, 'b')
        ylim([0, maxVal])
    subplot(3,3,6)
%     plot(rightBumpEMG, 'r')
%     hold on
    plot(rightMoveEMG, 'b')
        ylim([0, maxVal])
    subplot(3,3,8)
%     plot(downBumpEMG, 'r')
%     hold on 
    plot(downMoveEMG, 'b')
        ylim([0, maxVal])
    suptitle(strrep(td(1).emg_names{muscleNum},'_',' '))
    
    figure 
    subplot(3,3,2)
%     plot(trialUpBumpEMG,'r')
%     hold on
    plot(trialUpMoveEMG, 'b')
    ylim([0, maxVal])
    subplot(3,3,4)
%     plot(trialLeftBumpEMG, 'r')
%     hold on
    plot(trialLeftMoveEMG, 'b')
    ylim([0, maxVal])
    subplot(3,3,6)
%     plot(trialRightBumpEMG, 'r')
%     hold on
    plot(trialRightMoveEMG, 'b')
    ylim([0, maxVal])
    subplot(3,3,8)
%     plot(trialDownBumpEMG, 'r')
%     hold on 
    plot(trialDownMoveEMG, 'b')
    ylim([0, maxVal])
    suptitle(strrep(td(1).emg_names{muscleNum},'_',' '))
    
    pdEMGMove = up.*meanUpMoveEMG + down.*meanDownMoveEMG + right.*meanRightMoveEMG + left.*meanLeftMoveEMG;
    pdEMGBump = up.*meanUpBumpEMG + down.*meanDownBumpEMG + right.*meanRightBumpEMG + left.*meanLeftBumpEMG;
   
    pdAngMove = atan2(pdEMGMove(2), pdEMGMove(1));
    pdAngBump = atan2(pdEMGBump(2), pdEMGBump(1));
    
    pdMagMove = norm(pdEMGMove);
    pdMagBump = norm(pdEMGBump);
    
    figure
    polarplot([pdAngMove, pdAngMove], [0, pdMagMove],'Color', [0,0,1], 'LineWidth', 2)
    hold on
    polarplot([pdAngBump, pdAngBump], [0, pdMagBump],'Color', [1 0 0], 'LineWidth', 2)
    title(strrep(td(1).emg_names{muscleNum},'_',' '))
end
