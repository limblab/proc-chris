
% clear all
close all
clearvars -except cds
%load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 0;
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
%%

upBump = bumpTrials([bumpTrials.bumpDir] == 90);
leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
downBump = bumpTrials([bumpTrials.bumpDir] == 270);
rightBump = bumpTrials([bumpTrials.bumpDir] == 0);
close all
for muscleNum = 14

    beforeTime = .100;
    %Muscle EMG
    postUpBumpEMG = zeros(length(upBump), 25);
    for i = 1:length(upBump)
        postUpBumpEMG(i,:) = upBump(i).emg(upBump(i).idx_bumpTime-10:upBump(i).idx_bumpTime+14,muscleNum);
    end

    postDownBumpEMG = zeros(length(downBump), 25);
    for i = 1:length(downBump)
        postDownBumpEMG(i,:) = downBump(i).emg(downBump(i).idx_bumpTime-10:downBump(i).idx_bumpTime+14,muscleNum);
    end

    postRightBumpEMG = zeros(length(rightBump), 25);
    for i = 1:length(rightBump)
        postRightBumpEMG(i,:) = rightBump(i).emg(rightBump(i).idx_bumpTime-10:rightBump(i).idx_bumpTime+14,muscleNum);
    end

    postLeftBumpEMG = zeros(length(leftBump), 25);
    for i = 1:length(leftBump)
        postLeftBumpEMG(i,:) = leftBump(i).emg(leftBump(i).idx_bumpTime-10:leftBump(i).idx_bumpTime+14,muscleNum);
    end
    % Muscle Lengths
    postUpBumpLen = zeros(length(upBump), 25);
    for i = 1:length(upBump)
        postUpBumpLen(i,:) = upBump(i).opensim(upBump(i).idx_bumpTime-10:upBump(i).idx_bumpTime+14,52);
    end

    postDownBumpLen = zeros(length(downBump), 25);
    for i = 1:length(downBump)
        postDownBumpLen(i,:) = downBump(i).opensim(downBump(i).idx_bumpTime-10:downBump(i).idx_bumpTime+14,52);
    end

    postRightBumpLen = zeros(length(rightBump), 25);
    for i = 1:length(rightBump)
        postRightBumpLen(i,:) = rightBump(i).opensim(rightBump(i).idx_bumpTime-10:rightBump(i).idx_bumpTime+14,52);
    end

    postLeftBumpLen = zeros(length(leftBump), 25);
    for i = 1:length(leftBump)
        postLeftBumpLen(i,:) = leftBump(i).opensim(leftBump(i).idx_bumpTime-10:leftBump(i).idx_bumpTime+14,52);
    end
    
    [divergenceDown,sortMat] = sort(postDownBumpEMG(:,end));
    highFlag = divergenceDown>1.5;
    timeVec = linspace(-.1, .150, 25);
    figure 
    subplot(3,3,2)
    plot(timeVec, postUpBumpEMG')
    xlim([-.1,.150])
    subplot(3,3,4)
    plot(timeVec,postLeftBumpEMG')
    xlim([-.1,.150])
    subplot(3,3,6)
    plot(timeVec,postRightBumpEMG')
    xlim([-.1,.150])
    subplot(3,3,8)
    plot(timeVec,postDownBumpEMG(sortMat(highFlag),:)', 'r')
    hold on
    plot(timeVec,postDownBumpEMG(sortMat(~highFlag),:)', 'b')
    xlim([-.1,.150])
    muscleName1 = td(1).emg_names{muscleNum};
    muscleName = muscleName1(5:end);
    suptitle(muscleName)
    
    timeVec = linspace(-.1, .150, 25);
    figure 
    subplot(3,3,2)
    plot(timeVec, mean(postUpBumpEMG))
    xlim([-.1,.150])
    subplot(3,3,4)
    plot(timeVec,mean(postLeftBumpEMG))
    xlim([-.1,.150])
    subplot(3,3,6)
    plot(timeVec,mean(postRightBumpEMG))
    xlim([-.1,.150])
    subplot(3,3,8)
    plot(timeVec,mean(postDownBumpEMG))
    xlim([-.1,.150])
    muscleName1 = td(1).emg_names{muscleNum};
    muscleName = muscleName1(5:end);
    suptitle(muscleName)
    
    timeVec = linspace(-.1, .150, 25);
    figure 
    subplot(3,3,2)
    plot(timeVec, postUpBumpLen')
    xlim([-.1,.150])
    subplot(3,3,4)
    plot(timeVec,postLeftBumpLen')
    xlim([-.1,.150])
    subplot(3,3,6)
    plot(timeVec,postRightBumpLen')
    xlim([-.1,.150])
    subplot(3,3,8)
    plot(timeVec,postDownBumpLen(sortMat(highFlag),:)', 'r')
    hold on
    plot(timeVec,postDownBumpLen(sortMat(~highFlag),:)', 'b')
    xlim([-.1,.150])
    muscleName1 = td(1).emg_names{muscleNum};
    muscleName = muscleName1(5:end);
    
    downHighEMG =postDownBumpLen(sortMat(highFlag),end);
    downLowEMG = postDownBumpLen(sortMat(~highFlag),end);
    
    figure
    histogram(downHighEMG)
    hold on
    histogram(downLowEMG)
    
    ttest2(downHighEMG, downLowEMG)
    
    suptitle([muscleName, ' Length'])
    
end