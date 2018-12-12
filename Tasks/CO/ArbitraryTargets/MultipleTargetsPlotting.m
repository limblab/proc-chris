clear all
close all
date = '20181211';
monkey = 'Butter';
unitNames = 'cuneate';

mappingLog = getSensoryMappings(monkey);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO');

dirs = unique([td.target_direction]);
dirs = dirs(~isnan(dirs));
td = trimTD(td, {'idx_endTime',-20}, {'idx_endTime', 0});
td = removeBadNeurons(td, struct('min_fr', 1));

elec2MapName = td(1).cuneate_naming;
for i = 1:length(td(1).cuneate_spikes(1,:))
    gracileFlag(i) = getGracile('Butter', elec2MapName(elec2MapName(:,1) == td(1).cuneate_unit_guide(i,1),2));
end

td = smoothSignals(td, struct('signals', 'cuneate_spikes'));

for i = 1:length(dirs)
    tdDir{i}= td([td.target_direction] == dirs(i));
    firing{i} = cat(3, tdDir{i}.cuneate_spikes).*100;
end

for j = 1:length(td(1).cuneate_spikes(1,:))
    close all
    figure2('Renderer', 'painters', 'Position', [10 10,400 600])

    hold on
    for i = 1:length(dirs)
        subplot(length(dirs), 1,i)
        hold on
        title([num2str(rad2deg(dirs(i))), ' movement direction: Elec ', num2str(td(1).cuneate_unit_guide(j,1)), ' Unit ', num2str(td(1).cuneate_unit_guide(j,2))])
        for k = 1:length(tdDir{i})
            plot(.01:.01:.01*length(tdDir{i}(k).pos(:,1)), tdDir{i}(k).cuneate_spikes(:,j).*100)
        end
        meanFiring(i) = mean(mean(squeeze(firing{i}(:,j,:))));
    end
    figure2
    polarplot([dirs, dirs(1)], [meanFiring, meanFiring(1)])
    if ~gracileFlag(j)
        title(['Tuning Curve: Elec ', num2str(td(1).cuneate_unit_guide(j,1)), ' Unit ', num2str(td(1).cuneate_unit_guide(j,2))])
    else
        title(['Tuning Curve: Elec ', num2str(td(1).cuneate_unit_guide(j,1)), ' Unit ', num2str(td(1).cuneate_unit_guide(j,2)), ' GRACILE'])

    end
    pause
end
%%
% array = [-1 88	78	68	58	48	38	28	18 -1;
% 96 87 77 67 57 47 37 27 17 8;
% 95 86 76 66 56 46 36 26 16 7;
% 94 85 75 65 55 45 35 25 15 6;
% 93 84 74 64 54 44 34 24 14 5;
% 92 83 73 63 53 43 33 23 13 4;
% 91 82 72 62 52 42 32 22 12 3;
% 90 81 71 61 51 41 31 21 11 2;
% 89 80 70 60 50 40 30 20 10 1;
% -1 79 69 59 49 39 29 19 9 -1]
% for i = 1:10
%     for j = 1:10
%         ind = elec2MapName(:,2) == array(i,j);
%         if sum(ind) ~=0
%             arrayNew(i,j) = elec2MapName(elec2MapName(:,2) == array(i,j),1);
%         else
%             arrayNew(i,j) = -1;
%         end
%     end
% end