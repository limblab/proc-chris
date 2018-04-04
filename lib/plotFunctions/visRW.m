function [fh1] = visRW(td,params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    fh1 = figure;
    hold on
    for trial = 6:length(td)
        for timeStep = 1:length(td(trial).pos(:,1))
            params.barX = td(1).bin_size * (timeStep-1);
            params.figureHandle = subplot(3,1,3);
            fhRaster = trialRaster(td(trial),params);
            fhPos = subplot(3,1,1:2);
            scatter(td(trial).pos(timeStep,1), td(trial).pos(timeStep,2))
            for targs = 1:length(td(1).target_center(:,1))
                rectangle('Position', [td(trial).target_center(targs,1)-2, td(trial).target_center(targs,2)-34, 4, 4]);   
            end
            xlim([-20,20])
            ylim([-50,-10])
            title(trial)
            drawnow
            pause(.03)
            cla(fhPos)
        end
    end
end

