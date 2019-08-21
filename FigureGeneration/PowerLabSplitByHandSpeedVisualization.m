%% Load the TD
clearvars -except tdStart

monkey = 'Crackle';
date = '20190327';
array = 'cuneate';
task = 'CO';
params.start_idx        =  'idx_goCueTime';
params.end_idx          =  'idx_endTime';

if ~exist('tdStart') | ~checkCorrectTD(tdStart, monkey, date)
    tdStart =getTD(monkey, date, task,1);
    tdStart = tdToBinSize(tdStart, 10);
end

td = smoothSignals(tdStart, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .1));
td = removeUnsorted(td);
td = getSpeed(td);
td = getMoveOnsetAndPeak(td, params);
td(isnan([td.target_direction])) = [];

td = td(isnan([td.bumpDir]));
td(isnan([td.idx_movement_on])) = [];
td = trimTD(td, 'idx_movement_on', 'idx_endTime');

dirsM = unique([td.target_direction]);
dirsM(isnan(dirsM)) = [];
td(isnan([td.idx_peak_speed])) = [];
%% Sanity check on hand speeds (make sure that longer reaches have faster hand speeds)
tdPeak = trimTD(td, 'idx_peak_speed', 'idx_peak_speed');
colors = linspecer(length(dirsM));

tdFast =[];
tdSlow =[];

figure2();
hold on
for i = 1:length(dirsM)
    tdDir{i} = tdPeak([tdPeak.target_direction] == dirsM(i));
    tdDir1{i} = td([td.target_direction] == dirsM(i));
    
    speeds{i} = cat(1, tdDir{i}.speed);
    dists{i} = cat(1, tdDir{i}.tgtDist);
    scatter(dists{i},speeds{i}, 16, colors(i,:), 'filled','HandleVisibility', 'off')
    s1 = scatter(-1,-1, 16, colors(i,:), 'filled');
    medSpeed(i) = median(speeds{i});
    fastInds = speeds{i} >medSpeed(i);
    tdDirFast{i} = tdDir1{i}(fastInds);
    tdDirSlow{i} = tdDir1{i}(~fastInds);
    tdFast = [tdFast,tdDirFast{i}];
    tdSlow = [tdSlow, tdDirSlow{i}];
    spdSlow{i} = cat(1,tdDir{i}(~fastInds).speed);
    spdFast{i} = cat(1,tdDir{i}(fastInds).speed);
    medSpdSlow(i) = median(spdSlow{i});
    medSpdFast(i) = median(spdFast{i});
end

xlim([2, 11])
ylim([0, 50])
ylabel('Peak Speeds')
xlabel('Target Distances')
title(['Peak speed scales with target distance'])
legend(string(num2cell(rad2deg(dirsM))), 'Location', 'northwest')
set(gca,'TickDir','out', 'box', 'off')

%%
close all
figure2();
bar([medSpdSlow; medSpdFast]')
hold on
set(gca, 'XTickLabels', {'0', '45', '90', '135', '180', '225', '270', '315'})
xlabel('Reach direction (deg)')
ylabel('Peak Hand Speed (cm/s)')
title('Hand speeds from split trials')
for i = 1:length(dirsM)
    scatter(.85*ones(length(spdSlow{i}), 1)+i-1, spdSlow{i}, 12, 'filled', 'k', 'HandleVisibility', 'off')
    scatter(1.15*ones(length(spdFast{i}), 1)+i-1, spdFast{i}, 12, 'filled', 'k', 'HandleVisibility', 'off')
end
legend('Slow Trials', 'Fast Trials', 'Location', 'northwest')
set(gca,'TickDir','out', 'box', 'off')
