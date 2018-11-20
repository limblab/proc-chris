function [ fhCell ] = plotRWTD( td, params )
%PLOTRWTD Summary of this function goes here
%   Detailed explanation goes here
close all
yOffset = 32;
td = removeBadTrials(td);
    for i = 1:1658
        fh{i}= figure;
        subplot(4,3,1:9)
        scatter(td(i).pos(1:td(i).idx_goCueTime), td(i).pos(1:td(i).idx_goCueTime),'r')
        hold on
        scatter(td(i).pos(td(i).idx_goCueTime:td(i).idx_movement_on,1), td(i).pos(td(i).idx_goCueTime:td(i).idx_movement_on,2),'b')
        scatter(td(i).pos(td(i).idx_movement_on:td(i).idx_peak_speed,1), td(i).pos(td(i).idx_movement_on: td(i).idx_peak_speed, 2), 'g')
        scatter(td(i).pos(td(i).idx_peak_speed:td(i).idx_endTime,1), td(i).pos(td(i).idx_peak_speed: td(i).idx_endTime, 2), 'k')
        center = td(i).target_center;
        center(2) = center(2)- 32;
        rectangle('Position', [center, 2,2],'FaceColor', 'g')
        rectangle('Position', [td(i).cursor_start,2,2],'FaceColor', 'r')
        ylim([-60,-10])
        xlim([-25, 25])
        subplot(4,3,10:12)
        for i = 1:length(td(1).cuneate_unit_guide(1,:))
            scatter([td(i).cuneate_ts{i}], i*ones(length(td(i).cuneate_ts{i})));
        end
        pause
%         axis equal
    end

end

