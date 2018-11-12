function plotTD(td, params)
    event_list  = getTDfields(td, 'idx');
    spiking = cat(1, td.cuneate_spikes);
    r = corrcoef(spiking);
    velPlot= false;
    binSize = td(1).bin_size;
    for i = 1:10
        figure
        trial = td(i);
        pos = td(i).pos;
        vel = td(i).vel;
        inds = [];
        for j= 1:length(event_list)
            inds = [inds, min(trial.(event_list{j}))];
        end
        [sortedInds,sortMat] = sort(inds);
        sorted_events = event_list(sortMat);
        sorted_events = sorted_events(~isnan(sortedInds));
        sortedInds = sortedInds(~isnan(sortedInds));
        
        subplot(6, 3, 1:9)
        prev = 1;
        colors =linspecer(length(sorted_events));
        if ~velPlot
        for j = 1:length(sorted_events)
            scatter(pos(prev:td(i).(sorted_events{j}),1), pos(prev:td(i).(sorted_events{j}),2), [], colors(j,:))
            prev = td(i).(sorted_events{j});
            hold on
        end
        legend(sorted_events)
        xlim([-15, 15])
        ylim([-50, -20])
        else
            plot(binSize:binSize:binSize*length(vel(:,1)),vel(:,1))
            hold on
            plot(binSize:binSize:binSize*length(vel(:,1)),vel(:,2))
            xlim([0, binSize*length(vel(:,1))])

        end
        subplot(6,3, 10:18)
        prev = 1;
        for j = 1:length(sorted_events)
            plot([min(td(i).(sorted_events{j}))-trial.idx_startTime,min(td(i).(sorted_events{j}))-trial.idx_startTime].*td(1).bin_size, [0,120], 'Color', colors(j,:),'LineStyle', '--','LineWidth', 2)
            prev = td(i).(sorted_events{j});
            hold on
        end
%         legend(sorted_events)

        cuneate = trial.cuneate_ts;
        unit = 1;
        for j = 1:length(cuneate)
            if ~isempty(cuneate{j})
                scatter(cuneate{j}, ones(length(cuneate{j}),1)*unit,2, 'k','filled')
                hold on
                unit  = unit +1;
            end
        end
        xlim([0, binSize*length(vel(:,1))])
        suptitle(['Trial # ' ,num2str(i)])
        drawnow
    end
end