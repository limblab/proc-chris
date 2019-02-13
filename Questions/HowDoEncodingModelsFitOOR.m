
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
    td = getTD(monkey, date, 'OOR');
    td = splitTD(td, struct('split_idx_name', 'idx_startTime', 'linked_fields', {{'trialID','result', 'tgtDir', 'forceDir', 'idx_startTargHoldTime', 'idx_goCueTime', 'idx_endTime', 'idx_endTargHoldTime'}}));

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
td = removeBadNeurons(td);
td = smoothSignals(td, struct('signals', array_spikes));
td = smoothSignals(td, struct('signals', 'force'));
td = binTD(td, 5);
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

for i = 1:length(dirsAct)
   for j = 1:length(dirsForce)
       tdReachForce{i,j} = tdReach([tdReach.forceDir] == dirsForce(j) & [tdReach.tgtDir] == dirsAct(i));
       meanFiring(:,i,j) = mean(cell2mat(cellfun(@mean, {tdReachForce{i,j}.(array_spikes)}, 'UniformOutput', false)'))./tdReach(1).bin_size;
   end
end

%%
tdButter = td;
spikes = [array{1}, '_spikes'];
params.model_type = 'glm';
params.num_boots = 100;
params.eval_metric = 'pr2';
% params.glm_distribution

params.in_signals= {'pos';'vel';'acc';'force'};
params.model_name = 'Full';
params.out_signals = array_spikes;
tdButter= getModel(tdButter, params);
fullPR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'vel';'acc';'force'};
params.model_name = 'FullMinusPos';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusPos = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos';'acc';'force'};
params.model_name = 'FullMinusVel';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusVel = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos';'vel';'acc'};
params.model_name = 'FullMinusForce';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusForce = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos';'vel';'acc';'force'};
params.model_name = 'FullMinusSpeed';
params.out_signals = {spikes};
tdButter= getModel(tdButter, params);
fullPR2minusSpeed = squeeze(evalModel(tdButter, params));

params.in_signals= {'pos'};
params.model_name = 'Pos';
tdButter= getModel(tdButter, params);
posPR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'vel'};
params.model_name = 'Vel';
tdButter= getModel(tdButter, params);
velPR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'force'};
params.model_name = 'Force';
tdButter= getModel(tdButter, params);
forcePR2 = squeeze(evalModel(tdButter, params));

params.in_signals= {'vel'};
params.model_name = 'VelSpeed';
tdButter= getModel(tdButter, params);
velSpeedPR2 = squeeze(evalModel(tdButter, params));

params.in_signals ={'acc';'pos'};
params.model_name = 'Acc';
tdButter= getModel(tdButter,params);
accPR2 = squeeze(evalModel(tdButter, params));

params.in_signals = {'force', 'vel'};
params.model_name = 'ForceVel';
tdButter= getModel(tdButter,params);
accPR2 = squeeze(evalModel(tdButter, params));