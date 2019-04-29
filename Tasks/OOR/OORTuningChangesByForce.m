%% Load the td
close all
clear all

plotTrajectories = true;
plotForceReach = true;

monkey = 'Butter';
date = '20190117';
mappingLog = getSensoryMappings(monkey);
if strcmp(monkey, 'Butter')
    td1 =getTD(monkey, date, 'OOR',1);
    td3 = getTD(monkey, date, 'OOR',3);
    td = [td1, td3];
    
    td = removeGracileTD(td);
else
    td = getTD(monkey, date, 'OOR',1);
%     td = splitTD(td, struct('split_idx_name', 'idx_startTime', 'linked_fields', {{'trialID','result', 'tgtDir', 'forceDir', 'idx_startTargHoldTime', 'idx_goCueTime', 'idx_endTime', 'idx_endTargHoldTime'}}));

end
td(mod([td.tgtDir], 45)~=0) = [];
array = getTDfields(td, 'arrays');
array_spikes = [array{1}, '_spikes'];
array_unit_guide = [array{1}, '_unit_guide'];
reachWindow = {{'idx_movement_on', 0}, {'idx_endTargHoldTime', 0}};

labels = {'$\rightarrow$', '$\nearrow$', '$\uparrow$', '$\nwarrow$', '$\leftarrow$', '$\swarrow$','$\downarrow$', '$\searrow$'};
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'ForceVelPDs',filesep];
mkdir(savePath);
%% Preprocess the TD
td = removeBadTrials(td);
td = removeBadNeurons(td, struct('remove_unsorted', true));
td = smoothSignals(td, struct('signals', array_spikes, 'calc_rate', true));
td = smoothSignals(td, struct('signals', 'force'));
td = tdToBinSize(td, 50);
if ~isfield(td(1), 'idx_movement_on')
    td = getMoveOnsetAndPeak(td, struct('start_idx', 'idx_goCueTime', 'end_idx', 'idx_endTime'));
end
for i = 1:length(td)
    if td(i).forceDir == 360
        td(i).forceDir = 0;
    end
end
guide = td(1).(array_unit_guide);
tdReach = trimTD(td, reachWindow{1}, reachWindow{2});

num_units = length(tdReach(1).(array_spikes)(1,:));

dirsAct = unique([tdReach.tgtDir]);
dirsForce = unique([tdReach.forceDir]);

dirsAct = dirsAct(~isnan(dirsAct));
dirsForce= dirsForce(~isnan(dirsForce));
%%
for i = 1:length(dirsAct)
   for j = 1:length(dirsForce)
       tdReachForce{i,j} = tdReach([tdReach.forceDir] == dirsForce(j) & [tdReach.tgtDir] == dirsAct(i));
       meanFiring(:,i,j) = mean(cell2mat(cellfun(@mean, {tdReachForce{i,j}.(array_spikes)}, 'UniformOutput', false)'));
   end
end

%%
close all
for i = 1:length(meanFiring(:,1,1))
    figure()
    for j = 1:length(dirsForce)
        switch j
            case 1
            subplot(3, 3, 6)
            case 2
            subplot(3, 3, 3)
            case 3
            subplot(3, 3, 2)     
            case 4
            subplot(3, 3, 1)            
            case 5
            subplot(3, 3, 4)            
            case 6
            subplot(3, 3, 7)            
            case 7
            subplot(3, 3, 8)            
            case 8
            subplot(3, 3, 9)
        end
        polarplot(deg2rad([dirsAct, dirsAct(1)]), [meanFiring(i, :,j), meanFiring(i,1,j)])
    end
    pause
end
