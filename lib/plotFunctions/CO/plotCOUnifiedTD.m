function fh1 =  plotCOUnifiedTD(td, params)
    td = td(~isnan([td.target_direction]));
    td = removeBadNeurons(td);
    td = smoothSignals(td, struct('signals', 'cuneate_spikes', 'calc_rate' ,true));
    td = trimTD(td, {'idx_movement_on', -10}, {'idx_endTime', 0});
    td = binTD(td, 5);
    dirs = unique([td.target_direction]);
    numUnits = length(td(1).cuneate_spikes(1,:));
    
    for dir =1:length(dirs)
        [~, tdSplit{dir}] = getTDidx(td, 'target_direction', dirs(dir));
        meanLength = ceil(mean(cellfun(@length, {tdSplit{dir}.vel})));
        strParam = struct('num_samp', meanLength);
        tdMove{dir} = stretchSignals(tdSplit{dir}, strParam);
        firing{dir} = cat(3, tdMove{dir}.cuneate_spikes);
        
        for i = 1:meanLength
            for j = 1:numUnits
                 bootMean{dir}(:,i,j) = sort(bootstrp(100, @mean, firing{dir}(i, j,:)));
                 ciWidth{dir}(i,j) = bootMean{dir}(97, i,j) - bootMean{dir}(2,i,j);
            end
        end
        for unit = 1:numUnits
            meanFiring(unit, dir) = mean(mean(firing{dir}(:, unit,:)));
            stdFiring(unit,dir) = std(mean(firing{dir}(:,unit,:)));
        end
    end
    for unit = 1:length(td(1).cuneate_spikes(1,:))
        close all
        figure
        hold on
        for j = 1:length(dirs)
            errorbar(1:length(firing{j}(:,unit,1)), mean(squeeze(firing{j}(:,unit,:)),2), ciWidth{j}(:,unit))
        end
        title(['Channel: ', num2str(td(1).cuneate_unit_guide(unit,1)), ' Unit: ', num2str(td(1).cuneate_unit_guide(unit,2))])
%         figure
%         hold on
%         bar(1:4, meanFiring(unit,:))
%         errorbar(1:4, meanFiring(unit, :), stdFiring(unit,:))
        pause
    end
end