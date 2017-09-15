close all
for i = numCount
    meanRightBumpShort(:,i) = mean(shortRightBumpFiring{i});
    meanLeftBumpShort(:,i) = mean(shortLeftBumpFiring{i});
    meanUpBumpShort(:,i) = mean(shortUpBumpFiring{i});
    meanDownBumpShort(:,i) = mean(shortDownBumpFiring{i});
    
    meanRightMoveShort(:,i) = mean(shortRightMoveFiring{i});
    meanLeftMoveShort(:,i) = mean(shortLeftMoveFiring{i});
    meanUpMoveShort(:,i) = mean(shortUpMoveFiring{i});
    meanDownMoveShort(:,i) = mean(shortDownMoveFiring{i});
    
    stdRightBumpShort(:,i) = std(shortRightBumpFiring{i});
    stdLeftBumpShort(:,i) = std(shortLeftBumpFiring{i});
    stdUpBumpShort(:,i) = std(shortUpBumpFiring{i});
    stdDownBumpShort(:,i) = std(shortDownBumpFiring{i});
    
    stdRightMoveShort(:,i) = std(shortRightMoveFiring{i});
    stdLeftMoveShort(:,i) = std(shortLeftMoveFiring{i});
    stdUpMoveShort(:,i) = std(shortUpMoveFiring{i});
    stdDownMoveShort(:,i) = std(shortDownMoveFiring{i});
    
    shortTime = 0:10:150;
    
    figure
    subplot(2,1,1)
    errorbar(shortTime, meanRightBumpShort(:,i), stdRightBumpShort(:,i))
    ylim([0, max(max([meanRightBumpShort(:,i), meanRightMoveShort(:,i)]))]);
    subplot(2,1,2)
    errorbar(shortTime, meanRightMoveShort(:,i), stdRightMoveShort(:,i))
    ylim([0, max(max([meanRightBumpShort(:,i), meanRightMoveShort(:,i)]))]);
    suptitle('Right')
    
    figure
    subplot(2,1,1)
    errorbar(shortTime, meanLeftBumpShort(:,i), stdLeftBumpShort(:,i))
    ylim([0, max(max([meanLeftBumpShort(:,i), meanLeftMoveShort(:,i)]))]);
    subplot(2,1,2)
    errorbar(shortTime, meanLeftMoveShort(:,i), stdLeftMoveShort(:,i))
    ylim([0, max(max([meanLeftBumpShort(:,i), meanLeftMoveShort(:,i)]))]);
    suptitle('Left')
    
    figure
    subplot(2,1,1)
    errorbar(shortTime, meanUpBumpShort(:,i), stdUpBumpShort(:,i))
    ylim([0, max(max([meanUpBumpShort(:,i), meanUpMoveShort(:,i)]))]);
    subplot(2,1,2)
    errorbar(shortTime, meanUpMoveShort(:,i), stdUpMoveShort(:,i))
    ylim([0, max(max([meanUpBumpShort(:,i), meanUpMoveShort(:,i)]))]);
    suptitle('Up')
    
    figure
    subplot(2,1,1)
    errorbar(shortTime, meanDownBumpShort(:,i), stdDownBumpShort(:,i))
    ylim([0, max(max([meanDownBumpShort(:,i), meanDownMoveShort(:,i)]))]);
    subplot(2,1,2)
    errorbar(shortTime, meanDownMoveShort(:,i), stdDownMoveShort(:,i))
    ylim([0, max(max([meanDownBumpShort(:,i), meanDownMoveShort(:,i)]))]);
    suptitle('Down')
end