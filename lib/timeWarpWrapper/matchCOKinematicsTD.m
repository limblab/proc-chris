function tdOut =  matchCOKinematicsTD(td, params)
    plot_on = true;
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    dirs = unique([td.target_direction]);
    td = getSpeed(td);
    %% Find the movements in each direction and split them. Also find the starting template for each direction
    for i =1 :length(dirs)
        [~, tdSplit{i}] = getTDidx(td, 'target_direction', dirs(i));
        tdSplitMove{i} = trimTD(tdSplit{i}, {'idx_movement_on', -20}, {'idx_endTime', 0});
        maxLength = max(cellfun(@length, {tdSplitMove{i}.pos}));
        strParam = struct('num_samp', maxLength);
        tdStretchMove{i} = stretchSignals(tdSplitMove{i}, strParam);
        templates{i} = mean(cat(1, tdStretchMove{i}.speed));
    end
    %% Iterate through finding optimal stretches and offsets and updating templates
    f1 = @(x, trialSpeed,templateSpeed)norm(subsref(interp1(1:length(trialSpeed), shiftAndPadVector(trialSpeed, floor(10*x(1))), 1:floor(x(2)*length(trialSpeed))), struct('type', '()', 'subs', {{1:min(length(templateSpeed),floor(x(2)*length(trialSpeed)))}}))- templateSpeed(1:min(length(templateSpeed),floor(x(2)*length(trialSpeed)))));

    tdOut = [];
    for dir = 1:length(dirs)
        converged = false;
        while ~converged
            figure
            hold on
            for trial = 1:length(tdSplit{dir})
                
                trialSpeed = tdSplit{dir}(trial).speed;
                templateSpeed = templates{dir};
                fun = @(x)f1(x, trialSpeed, templateSpeed);
                x = fminsearch(fun, [1,1]);
                tdSplit{dir}(trial).optShiftScale = x;
                tdSplit{dir}(trial).speed = interp1(1:length(trialSpeed), shiftAndPadVector(trialSpeed, floor(10*x(1))), 1:floor(x(2)*length(trialSpeed)));
                if plot_on
                    plot(tdSplit{dir}(trial).speed)
                end
            end
            maxLength = max(cellfun(@length, {tdSplit{dir}.speed}));
            strParam = struct('num_samp', maxLength);
            tdStretchMove{dir} = stretchSignals(tdSplit{dir}, strParam);
            templatesNew{dir} = mean(cat(1, tdStretchMove{dir}.speed));
            if templatesNew{dir} == templates{dir}
                converged = true;
                disp('Templates converged for a direction')
            else
                templates{dir} = templatesNew{dir};
                disp('Templates still not converged, running again')
            end
            tdOut = [tdOut, tdSplit{dir}];
        end
    end   
end