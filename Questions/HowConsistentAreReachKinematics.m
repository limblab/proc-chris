%% Load all files for comparison
monkey = 'Snap';
date = '20190823';
mappingLog = getSensoryMappings(monkey);
if ~exist('tdButter')
    tdButter =getTD(monkey, date, 'CO',1);
    dirsM = unique([tdButter.target_direction]);
    dirsM(isnan(dirsM)) = [];
    tdButter =tdToBinSize(tdButter, 10);
    tdButter= getSpeed(tdButter);
    tdButter= getMoveOnsetAndPeak(tdButter);
end


tdB = trimTD(tdButter, {'idx_goCueTime', -30}, {'idx_goCueTime', 60});
colors = linspecer(length(dirsM));
figure
hold on
for i = 1:length(dirsM)
    switch i
        case 1
            subplot(3,3,6)
        case 2
            subplot(3,3,3)
        case 3
            subplot(3,3,2)
        case 4
            subplot(3,3,1)
        case 5
            subplot(3,3,4)
        case 6
            subplot(3,3,7)
        case 7
            subplot(3,3,8)
        case 8
            subplot(3,3,9)
    end
    td1 = tdB([tdB.target_direction] == dirsM(i)); 
    speed = cat(2, td1.speed);
    plot(-300:10:600, speed, 'Color', colors(i,:))
    hold on
    mSpeed = mean(speed');
%     plot(-300:10:600, mSpeed, 'Color', colors(i,:), 'LineWidth', 2)
    ylim([0, 30+max(mSpeed)])
    xlim([-300, 600])
end