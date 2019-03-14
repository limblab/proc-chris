function td = easyTD(path, monkey, task, date)
    load(path);
    params.exclude_units = [255];
    params.extra_time = [.4,.6];
    params.include_ts = true;
    params.include_start = true;
    params.include_naming = true;
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    params.trial_results = {'R', 'A'};
    if strcmp(getGenericTask(task), 'CO')
        params.event_list = {'bumpTime'; 'bumpDir'};
%         params.min_ds = 2.5;
%         params.s_thresh = 40;
        td= parseFileByTrial(cds,params);
        td = td(~isnan([td.idx_goCueTime]));
%         if td(1).bin_size == .001
%             td = binTD(td, 10);
%         end
        td = getMoveOnsetAndPeak(td, params);
    elseif strcmp(getGenericTask(task), 'RW')
        td = parseFileByTrial(cds, params);
%         td = getRWMovements(td, params);
        params.min_ds = 1.9;
        params.s_thresh = 10;
%         td = getMoveOnsetAndPeak(td,params);
    elseif strcmp(getGenericTask(task),'TRT')
        params.array_alias = {'LeftS1Area2','S1';'RightCuneate','CN'};
        params.event_list = {'bumpTime';'bumpDir';'ctHoldTime';'otHoldTime';'spaceNum';'targetStartTime'};
        params.trial_results = {'R','A','F','I'};
        td_meta = struct('task',task);
        params.meta = td_meta;
        trial_data = parseFileByTrial(cds,params);
        % sanitize?
        idxkeep = cat(1,trial_data.spaceNum) == 1 | cat(1,trial_data.spaceNum) == 2;
        td = trial_data(idxkeep);
        td = parseFileByTrial(cds, params);
    elseif strcmp(getGenericTask(task), 'OOR')
        params.event_list = {'startTargOnTime';'startTargHold';'goCueTime';'endTargHoldTime';'tgtDir';'forceDir'};

        td_meta = struct('task',task);
        params.meta = td_meta;
        td = parseFileByTrial(cds, params);
        td = getMoveOnsetAndPeak(td,params);

        
    end
    save([getBasePath(), getGenericTask(task), filesep, monkey, filesep, date, filesep, 'TD', filesep, monkey, '_', task, '_', date, '_TD.mat'], 'td');
end