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
td1 = trimTD(td, {'idx_peak_speed', -3}, {'idx_peak_speed'});
%% Sanity check on hand speeds (make sure that longer reaches have faster hand speeds)
close all
tdPeak = trimTD(td, 'idx_peak_speed', 'idx_peak_speed');
colors = linspecer(length(dirsM));
splitsFrac = 0:.1:1.0;

for i = 1:length(dirsM)
    tdDir{i} = tdPeak([tdPeak.target_direction] == dirsM(i));
    tdDir1{i} = td1([td1.target_direction] == dirsM(i));
    speeds{i} = cat(1, tdDir{i}.speed);
    dists{i} = cat(1, tdDir{i}.tgtDist);
    for j = 1:length(splitsFrac)-1
        [sSpeeds, sInd] = sort(speeds{i});
        tdSpeed{i,j} = tdDir1{i}(sInd(floor(splitsFrac(j)*length(tdDir{i}))+1: floor(splitsFrac(j+1)*length(tdDir{i}))));
    end
end
%
for i = 1:length(splitsFrac)-1
    tdS{i}  =horzcat(tdSpeed{:,i});
    meanFiring(i,:) = squeeze(mean(mean(cat(3, tdS{i}.cuneate_spikes)), 3));
    meanSpeed(i) =mean(mean(cat(3, tdS{i}.speed)),3);
end
mkdir([getPathFromTD(td1), '\plotting\BinnedSpeedFR\'])
guide = td1(1).cuneate_unit_guide;
for i = 1:length(meanFiring(1,:))
    title1 = ['FiringByHand SpeedE', num2str(guide(i,1)), 'U', num2str(guide(i,2))];

    figure2();
    scatter(meanSpeed, meanFiring(:,i), 32, 'filled')
    title(['Firing as a function of Hand Speed E', num2str(guide(i,1)), 'U', num2str(guide(i,2))])
    xlabel('Peak Hand Speed (cm/s)')
    ylabel('Firing Rate')
    set(gca,'TickDir','out', 'box', 'off')
    saveas(gca, [getPathFromTD(td),'\plotting\BinnedSpeedFR\',title1, '.pdf'])

end
% firing = squeeze(mean(cat(3, td1.cuneate_spikes)));
% for i = 1:length(td(1).cuneate_spikes(1,:))
%     
%     figure2();
%     scatter(squeeze(mean(cat(3, td1.speed))), firing(i,:))
%     pause();
% end