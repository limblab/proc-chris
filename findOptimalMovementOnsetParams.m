% params.event_list = {'bumpTime'; 'bumpDir'};
% params.extra_time = [.4,.6];
% params.include_ts = true;
% params.include_start = true;
% params.include_naming = true;
% params.start_idx =  'idx_goCueTime';
% params.end_idx = 'idx_endTime';
% params.trial_results = {'R', 'A'};
% td= parseFileByTrial(cds,params);
% td = td(~isnan([td.idx_goCueTime]));
%%
close all
dsVec = 1.9;
sVec = 10;
fig = figure();
for i = 1:length(dsVec)
    for j = 1:length(sVec)
        cla
        params.min_ds = dsVec(i);
        params.s_thresh = sVec(j);
        tdTemp = getMoveOnsetAndPeak(td, params);
        tdTemp = getSpeed(tdTemp);
        trimmedTemp = trimTD(tdTemp, {'idx_movement_on', -10}, {'idx_movement_on', 30});
        speed= cat(2,trimmedTemp.speed);
        plot(speed)
        hold on
        plot([10,10], [0,max(max(speed))])
        title(['min_ds ', num2str(dsVec(i)), ' s_thresh', num2str(sVec(j))])
        pause
    end
end