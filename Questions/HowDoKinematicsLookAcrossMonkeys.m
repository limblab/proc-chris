close all
clear all
for i = 1:12
    td = getPaperFiles(i,10);
    monkey = td(1).monkey;
    date1 = td(1).date;
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td);

    dirsM = uniquetol([td.target_direction],0.0001);
    dirsM(isnan(dirsM)) = [];
    colors = linspecer(length(dirsM));
    if i ~=1
        td = td(isnan([td.idx_bumpTime]));
    end
    td = trimTD(td, 'idx_movement_on', {'idx_movement_on',40});
    figure
    for j = 1:length(dirsM)
        pos = cat(1, td([td.target_direction] == dirsM(j)).pos);
        
        scatter(pos(:,1), pos(:,2), 16, colors(j,:))
        hold on
    end
    title([monkey, ' ', date1])
end

