%% Load the td
close all
clear all

plotTrajectories = true;
plotForceReach = true;

monkey = 'Crackle';
date = '20190417';
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
td = getSpeed(td);

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
td = smoothSignals(td, struct('signals', array_spikes));
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
dirsForce(mod(dirsForce, 45)~=0) = [];
%% get the mean firing in each force/reach pair
for i = 1:length(dirsAct)
   for j = 1:length(dirsForce)
       tdReachForce{i,j} = tdReach([tdReach.forceDir] == dirsForce(j) & [tdReach.tgtDir] == dirsAct(i));
       meanFiring(:,i,j) = mean(cell2mat(cellfun(@mean, {tdReachForce{i,j}.(array_spikes)}, 'UniformOutput', false)'))./tdReach(1).bin_size;
   end
end

%% plot reach trajectories
close all
if plotTrajectories
colors = linspecer(length(dirsForce));
for i = 1:length(dirsAct)
   figure2();
   xlim([-15, 15])
   ylim([-50, -25])
   hold on
   for j = 1:length(dirsForce)
       trials = tdReachForce{i,j};
       for k = 1:length(trials)
           plot(trials(k).pos(:,1), trials(k).pos(:,2), '-', 'Color', colors(j,:))
       end
   end
end
%% plot force trajectories

for i =1:length(dirsForce)
    figure2();
hold on
    for j = 1:length(dirsAct)
        trials = tdReachForce{j,i};
        force = cat(1, trials.force);
        scatter(force(:,1), force(:,2),36,colors(i, :),  'filled') 
    end
end
legend('0', '45', '90', '135', '180', '225', '270', '315')
end
%%
%%
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'ForceReachPlots',filesep];
mkdir(savePath);
if plotForceReach
for i = 1:num_units
    close all
    plotName = ['AverageFiringForceDirxReachDirE', num2str(guide(i,1)), 'U', num2str(guide(i,2)),'.png'];
    figure2();
    imagesc(squeeze(meanFiring(i,:,:)));
    title(['Average Firing: ForceDir/ReachDir E', num2str(guide(i,1)), 'U', num2str(guide(i,2))]);
    xlabel('ReachDirection')
    ylabel('ForceDirection')
    theseAxes = gca;
    theseAxes.TickLabelInterpreter='latex';
    xticklabels(labels)
    yticklabels(labels)
    
    set(gca,'YDir','normal')
    colorbar
    saveas(gca,[savePath, plotName]);
end
end
%%
pdVel = getTDPDs(tdReach, struct('out_signals', array_spikes,'in_signals', 'vel','out_signal_names',tdReach(1).(array_unit_guide), 'num_boots', 1000));
pdForce = getTDPDs(tdReach, struct('out_signals', array_spikes, 'in_signals','force','out_signal_names',tdReach(1).(array_unit_guide), 'num_boots', 1000));
%%
mapping = tdReach(1).cuneate_naming;
for j = 1:num_units
    pdVel.chan(j,1) = pdVel.signalID(j,1);
    pdForce.chan(j,1) = pdForce.signalID(j,1);
    pdVel.unitNum(j,1) = pdVel.signalID(j,2);
    pdForce.unitNum(j,1) = pdForce.signalID(j,2);
    
    pdVel.mapName(j, 1) = mapping(find(mapping(:,1) == pdVel.signalID(j,1)), 2);
    pdForce.mapName(j,1) = mapping(find(mapping(:,1)==pdForce.signalID(j,1)), 2);
end
velNeurons = insertMappingsIntoNeuronStruct(pdVel, mappingLog);
forceNeurons = insertMappingsIntoNeuronStruct(pdForce, mappingLog);
pdVelTuned = velNeurons(logical(velNeurons.velTuned),:);
pdForceTuned= forceNeurons(logical(forceNeurons.forceTuned),:);
neuronStructVel = makeNeuronStructFromPDTable(velNeurons, 'cuneate');
neuronStructForce= makeNeuronStructFromPDTable(forceNeurons, 'cuneate');
neuronStruct = innerjoin(neuronStructVel, neuronStructForce, 'Keys', {'monkey', 'date', 'array', 'signalID', 'chan', 'unitNum','mapName', 'isCuneate', 'isGracile', 'sameDayMap', 'daysDiff', 'isProprioceptive', 'isSpindle', 'proximal', 'midArm', 'distal', 'handUnit', 'cutaneous', 'proprio', 'task'});
saveNeurons(neuronStruct, 'ForcePDs')
%%
figure2();
histogram(neuronStruct.velPD, 15)
hold on 
histogram(neuronStruct.forcePD, 15)
title('Velocity and Force PD distributions')
xlabel('Preferred Direction (rads)')
ylabel('# of tuned units')
set(gca,'TickDir','out', 'box', 'off')
legend('Vel PDs', 'Force PDs')
saveas(gca, [savePath, 'VelocityForcePDsDuringReaching.png'])

%%
figure2();
histogram(neuronStruct.velPD(logical(neuronStruct.sameDayMap) & neuronStruct.isSpindle), 10)
hold on 
histogram(neuronStruct.forcePD(logical(neuronStruct.sameDayMap) & neuronStruct.isSpindle), 10)
title('Velocity and Force PD distributions of Mapped Spindles')
xlabel('Preferred Direction (rads)')
ylabel('# of tuned units')
set(gca,'TickDir','out', 'box', 'off')
legend('Vel PDs', 'Force PDs')
saveas(gca, [savePath, 'MappedSpindleForceVelPDs.png'])
%%
figure2();
histogram(angleDiff(neuronStruct.velPD(logical(neuronStruct.sameDayMap) & neuronStruct.isSpindle),neuronStruct.forcePD(logical(neuronStruct.sameDayMap) & neuronStruct.isSpindle), true, false), 10)
title('Difference between force and vel PDs of Mapped Spindles')
xlabel('Change in Preferred Direction (rads)')
ylabel('# of tuned units')
set(gca,'TickDir','out', 'box', 'off')
saveas(gca, [savePath, 'MappedSpindleForceVelPDDiff.png'])
%%
pdVelTunedinBoth = neuronStruct(neuronStruct.velTuned & neuronStruct.forceTuned,:);
pdForceTunedinBoth = neuronStruct(neuronStruct.velTuned & neuronStruct.forceTuned,:);

figure2();
histogram(angleDiff(pdVelTunedinBoth.velPD, pdForceTunedinBoth.forcePD, true, false), 10)
title('Difference in force/vel PDs')
xlabel('Delta Preferred Direction (rads)')
ylabel('# of units')
set(gca,'TickDir','out', 'box', 'off')
saveas(gca, [savePath, 'ForceVelPDDiffAllNeurons.png'])

%% Stretch to same size for average time course during reaches
reachLens = cat(1,td.idx_endTargHoldTime);
meanLength = mean(reachLens);
tdStretch = stretchSignals(td, struct('num_samp', meanLength));

dirsAct = unique([tdStretch.tgtDir]);
dirsForce = unique([tdStretch.forceDir]);

dirsAct = dirsAct(~isnan(dirsAct));
dirsForce= dirsForce(~isnan(dirsForce));

for i = 1:length(dirsAct)
   for j = 1:length(dirsForce)
       tdStretchForce{i,j} = tdStretch([tdStretch.forceDir] == dirsForce(j) & [tdStretch.tgtDir] == dirsAct(i));
       stretchedFiring{i, j} = cat(3, tdStretchForce{i,j}.(array_spikes));
       meanStretchedFiring(i,j,:, :) = mean(stretchedFiring{i,j},3);
   end
end

%% Generate figures
centers = [44, 17, 14, 11, 38, 65, 68, 71];

for unit = 1:num_units
    figure2();
    for i = 1:length(dirsAct)
        center = centers(i);
        subplot(9,9, center+1)
        plot(linspace(0, 50*meanLength, meanLength), squeeze(meanStretchedFiring(i,1, :,unit)))
        set(gca,'TickDir','out', 'box', 'off')

        subplot(9,9, center-8)
        plot(linspace(0, 50*meanLength, meanLength),squeeze(meanStretchedFiring(i,2,:, unit)))
        set(gca,'TickDir','out', 'box', 'off')
        
        subplot(9,9, center-9)
        plot(linspace(0, 50*meanLength, meanLength),squeeze(meanStretchedFiring(i,3,:, unit)))
        set(gca,'TickDir','out', 'box', 'off')

        subplot(9,9, center-10)
        plot(linspace(0, 50*meanLength, meanLength),squeeze(meanStretchedFiring(i,4,:, unit)))
        set(gca,'TickDir','out', 'box', 'off')

        subplot(9,9, center-1)
        plot(linspace(0, 50*meanLength, meanLength),squeeze(meanStretchedFiring(i,5,:, unit)))
        set(gca,'TickDir','out', 'box', 'off')

        subplot(9,9, center+8)
        plot(linspace(0, 50*meanLength, meanLength),squeeze(meanStretchedFiring(i,6,:, unit)))
        set(gca,'TickDir','out', 'box', 'off')

        subplot(9,9, center+9)
        plot(linspace(0, 50*meanLength, meanLength),squeeze(meanStretchedFiring(i,7,:, unit)))
        set(gca,'TickDir','out', 'box', 'off')

        subplot(9,9, center+10)
        plot(linspace(0, 50*meanLength, meanLength),squeeze(meanStretchedFiring(i,8,:, unit)))
        set(gca,'TickDir','out', 'box', 'off')

    end
    suptitle(['Average Firing: ForceDir/ReachDir E', num2str(guide(unit,1)), 'U', num2str(guide(unit,2))]);
    pause
end