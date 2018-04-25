function td = easyTD(path, monkey, task, date)
    load(path);
    if strcmp(getGenericTask(task), 'CO')
        params.event_list = {'bumpTime'; 'bumpDir'};
        params.extra_time = [.4,.6];
        params.include_ts = true;
        params.include_start = true;
        params.include_naming = true;
        params.start_idx =  'idx_goCueTime';
        params.end_idx = 'idx_endTime';
        params.trial_results = {'R', 'A'};
        params.min_ds = 1.9;
        params.s_thresh = 10;
        td= parseFileByTrial(cds,params);
        td = td(~isnan([td.idx_goCueTime]));
        td = getMoveOnsetAndPeak(td, params);
    elseif strcmp(getGenericTask(task), 'RW')
        params.extra_time = [.4,.6];
        params.include_ts = true;
        params.include_start = true;
        params.include_naming = true;
        params.start_idx =  'idx_goCueTime';
        params.end_idx = 'idx_endTime';
        td = parseFileByTrial(cds, params);
        td = getRWMovements(td, params);
        params.min_ds = 1.9;
        params.s_thresh = 10;
        td = getMoveOnsetAndPeak(td,params);
    end
    save(['C:\Users\csv057\Documents\MATLAB\MonkeyData\', getGenericTask(task), filesep, monkey, filesep, date, filesep, 'TD', filesep, monkey, '_', task, '_', date, '_TD.mat'], 'td');
end