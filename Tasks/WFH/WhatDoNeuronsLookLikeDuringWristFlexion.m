clear all
close all
monkey = 'Butter';
date = '20190412';
task = 'WFH';

td = getTD(monkey, date,task, 1);
[~, td] = getTDidx(td, 'result', 'R');
% td = trimTD(td, {'idx_endTime', -50}, 'idx_endTime');
dirs = unique([td.target_direction]);
% td = removeBadNeurons(td, struct('remove_unsorted', true, 'min_fr', 1));
td = getMoveOnsetAndPeak(td);
td = td(~isnan([td.idx_movement_on]));
td = trimTD(td, {'idx_movement_on',0}, {'idx_movement_on', 500});
td = binTD(td, 50);
td = smoothSignals(td, struct('signals', 'cuneate_spikes', 'calc_rate', true));

unit_guide= td(1).cuneate_unit_guide;
naming = td(1).cuneate_naming;

td = dimReduce(td, struct('num_dims', 2));
colors = linspecer(length(dirs));
%%
figure
hold on

for i = 1:length(dirs)
    
tdDir{i} = td([td.target_direction] == dirs(i));

pos = cat(1, tdDir{i}.pos);
scatter(pos(:,1), pos(:,2),36, colors(i,:))
neurons{i} = cat(3, tdDir{i}.cuneate_spikes);


meanFir(i,:) = squeeze(mean(mean(neurons{i}),3))';
ci(i,:,:) = bootci(1000, @mean, squeeze(mean(neurons{i}))');

end
legend(num2str(dirs))
%%
close all
c = categorical(cellfun(@num2str, num2cell(dirs), 'un', 0));
savePath = [getPathFromTD(td), 'plotting',filesep, 'tuningCurves' filesep];
mkdir([savePath,'png', filesep])
mkdir([savePath,'pdf', filesep])
for i = 1:length(meanFir(1,:))
    close all
    f1 = figure;
    subplot(4,2,1:2)
    bar([meanFir(1,i), meanFir(2,i), meanFir(3,i), meanFir(4,i), meanFir(5,i), meanFir(6,i)])
    hold on
    errorbar([1:length(dirs)],[meanFir(1,i), meanFir(2,i), meanFir(3,i), meanFir(4,i), meanFir(5,i), meanFir(6,i)], [ci(1,1,i)- meanFir(1,i), ci(2,1, i)- meanFir(2,i), ci(3,1,i)- meanFir(3, i), ci(4,1, i)- meanFir(4, i),ci(5,1, i)- meanFir(5,i),ci(6,1, i)- meanFir(6,i)],[ci(1,2,i)- meanFir(1,i), ci(2,2, i)- meanFir(2,i), ci(3,2,i)- meanFir(3, i), ci(4,2, i)- meanFir(4, i),ci(5,2, i)- meanFir(5,i),ci(6,2, i)- meanFir(6,i)] );
    
    xticks(1:6)
    qc = arrayfun(@char, sym(dirs), 'uniform', 0);
    xticklabels(qc)
    title(['Elec ', num2str(unit_guide(i, 1)), ' Unit ', num2str(unit_guide(i,2))])
    subplot(4,2,3:8)
    polarplot([dirs, dirs(1)], [ci(:,2,i); ci(1, 2,i)]', 'Color', [1, .59, .59])
    hold on
    polarplot([dirs, dirs(1)], [meanFir(:,i); meanFir(1,i)]', 'Color', [1,0,0])
    polarplot([dirs, dirs(1)], [ci(:,1,i); ci(1, 1,i)]', 'Color', [1, .59, .59])
    
    saveas(f1, [savePath,'png', filesep, monkey, '_',date,'_',task, 'Elec', num2str(unit_guide(i,1)), 'Unit', num2str(unit_guide(i,2)), 'TuningCurve.png']);
    saveas(f1, [savePath,'pdf', filesep, monkey, '_',date,'_',task, 'Elec', num2str(unit_guide(i,1)), 'Unit', num2str(unit_guide(i,2)), 'TuningCurve.png']);
end
%%
array = 'cuneate';
params.monkey = monkey;
params.array = array;
params.date = date;
params.out_signals = 'cuneate_spikes';
params.distribution = 'poisson';
params.out_signal_names = unit_guide;
params.window = window;
tablePDs = getTDPDs(td, params);
%%
tunedPDs = tablePDs(logical(checkIsTuned(tablePDs, pi/4)), :);
tunedPDs = tunedPDs(tunedPDs.signalID(:,2) ~=0,:);
pds = tunedPDs.velPD;
figure();
for i = 1:length(pds)
    polarplot([pds(i), pds(i)], [0,1])
    hold on

end

