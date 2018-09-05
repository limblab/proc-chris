%% Load all files for comparison
clear all
monkey = 'Butter';
date = '20180405';
mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, 'RW');
tdLando = getTD('Lando', '20170728', 'RW_hold');
%% Preprocess them (binning, trimming etc)
tdButter = getRWMovements(tdButter);
tdButter= removeBadTrials(tdButter);
tdLando = removeBadTrials(tdLando);
tdButter= binTD(tdButter, 5);
tdLando = binTD(tdLando, 5);

%% Population statistics
butterNaming = tdButter.cuneate_unit_guide;
landoNaming = tdLando.cuneate_unit_guide;

landoVel = cat(1, tdLando.vel);
landoPos = cat(1, tdLando.pos);
landoNeurons = cat(1,tdLando.cuneate_spikes);
landoSortedNeurons = landoNeurons(:, landoNaming(:,2) ~=0);

butterVel = cat(1, tdButter.vel);
butterPos = cat(1, tdButter.pos);
butterNeurons = cat(1, tdButter.cuneate_spikes);
butterSortedNeurons = butterNeurons(:,butterNaming(:,2)~=0);

%%
[fh1, neuronsISI] = constructISIHistFromTD(tdButter);
[fh1, neuronsISILando] = constructISIHistFromTD(tdLando);
%%
isiMedians = cellfun(@median, neuronsISI);
isiMediansLando = cellfun(@median,neuronsISILando);
isiMeans = cellfun(@mean, neuronsISI);
figure
ax1 = axes('Position',[0 0 1 1],'Visible','off');
ax2 = axes('Position',[.15 .2 .8 .6]);
ksdensity(isiMedians*1000);
hold on
ksdensity(isiMediansLando*1000)
legend('Butter', 'Lando')
title('Distribution of median ISIs for neurons over entire experiment')
xlabel('Interspike Interval (ms)')
ylabel('Smoothed density')
axes(ax1)
text(.1,.1,{'Lando20170728RW_hold','Butter20180405RW'}, 'FontSize', 6)
