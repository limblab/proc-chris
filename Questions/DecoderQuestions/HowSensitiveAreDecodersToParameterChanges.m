clear all
close all

monkey = 'Crackle';
task = 'CO';
date = '20190329';

td = getTD(monkey,date, task, 1);
[~,td] = getTDidx(td, 'result', 'R');
td = removeBadNeurons(td, struct('remove_unsorted', true));
td = getMoveOnsetAndPeak(td, struct('start_idx','idx_goCueTime','end_idx', 'idx_endTime'));
smoothParam = [0, 10, 20,50, 100];
binSize = [5, 10, 20, 50,100];
%%
r2 = zeros(length(smoothParam), length(binSize), 4,2);
for smoothInd = 1:length(smoothParam)
    if smoothParam(smoothInd) > 0
        tdSmooth = smoothSignals(td, struct('signals', 'cuneate_spikes','width', smoothParam(smoothInd)/1000));
    else
        tdSmooth = td;
        
    end
    for binInd = 1:length(binSize)
        tdRun = tdToBinSize(tdSmooth,binSize(binInd));
        windows = {{'idx_movement_on', 0}, {'idx_movement_on', ceil(150/(1000*tdRun(1).bin_size))};...
                    {'idx_movement_on', 0}, {'idx_movement_on', ceil(300/(1000*tdRun(1).bin_size))};...
                    {'idx_movement_on', 0}, {'idx_endTime', 0};...
                    {'idx_startTime', 0},   {'idx_endTime', 0}};
        for wInd = 1:length(windows(:,1))
            tdTrim = trimTD(tdRun, windows{wInd,1}, windows{wInd, 2});
            params.model_type    =  'linmodel';
            params.model_name    =  'movementGLM';
            params.in_signals    =  {'cuneate_spikes'};%, find(velMove2BumpPR2>0 & velBump2MovePR2 >0)};% {'name',idx; 'name',idx};
            params.out_signals   =  {'vel'};% {'name',idx};
            params.train_idx     =  1:length(tdTrim);
            % GLM-specific parameters


            params.glm_distribution     =  'normal';
            params.model_name    =  ['LM_binSize_', num2str(binSize(binInd)), '_smooth_', num2str(smoothParam(smoothInd)), '_windowNum_', num2str(wInd)];
            [trial_lm, model_info] = getModel(tdTrim, params);
            params.eval_metric      =  'r2';
            r2(smoothInd, binInd, wInd,:) = evalModel(trial_lm, params);
          
        end
    end
end