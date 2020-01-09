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
clearvars -except td3
% 
date = '20190829';
monkey = 'Snap';
unitNames = 'cuneate';
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
% date = '20190822';
% monkey = 'Snap';1
% unitNames= 'cuneate';

mappingLog = getSensoryMappings(monkey);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;
td = td3;
% td =getTD(monkey, date, 'CO',2);
td = getSpeed(td);
dsVec = 1:.1:2;
sVec = 2;
fig = figure();
% params.useForce = true;
% params.which_field = 'force';
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
    
dirsM = unique([td.target_direction]);
dirsM(isnan(dirsM)) = [];
dirsM(mod(dirsM, pi/4) ~=0) = [];
    
if td(1).bin_size ==.001
    td = binTD(td, 10);
end
td(~isnan([td.idx_bumpTime]))=[];
for i = 1:length(dsVec)
    for j = 1:length(sVec)
        for k = 1:length(dirsM)
            cla
            params.min_ds = dsVec(i);
            params.s_thresh = sVec(j);
            tdTemp = getMoveOnsetAndPeak(td([td.target_direction] == dirsM(k)), params);
            tdTemp = getSpeed(tdTemp);
            tdTemp = removeHighSpeedAtOnset(tdTemp);
    %         tdTemp = removeBadTrials(tdTemp);
            tdTemp = tdTemp(~isnan([tdTemp.idx_movement_on]));

            trimmedTemp = trimTD(tdTemp, {'idx_movement_on', -20}, {'idx_movement_on', 30});
    %         trimmedTemp1 = removeBadTrials(trimmedTemp);
            speed= cat(2,trimmedTemp.speed);
            plot(speed)
            hold on
            plot([20,20], [0,max(max(speed))])
            plot(mean(speed'), 'LineWidth', 5)
            title(['min_ds ', num2str(dsVec(i)), ' s_thresh', num2str(sVec(j)), ' Direction ', num2str(dirsM(k))])
            pause
        end
    end
end