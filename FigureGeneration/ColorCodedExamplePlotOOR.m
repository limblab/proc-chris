%% Load the TD
close all
clearvars -except td2
task = 'OOR';
normalize1 = true;

% monkey ='Snap';
% date = '20190924';
% cDate = date;
% array = 'cuneate';

monkey ='Butter';
date = '20190117';
array = 'cuneate';

params.start_idx        =  'idx_goCueTime';
params.end_idx          =  'idx_endTargHoldTime';
if ~exist('td2')
% td2 = getTD(monkey,date, task,1);
% td2 = tdToBinSize(td2, 10);

td2 = getTD(monkey,date, task,1);
td22 =getTD(monkey,date, task,3);
td2 = [td2, td22];
td2 = removeNonMatchingNeurons(td2);
td2 = tdToBinSize(td2, 10);
end
td = smoothSignals(td2, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .1));

td = removeUnsorted(td);
td = getSpeed(td);
td = removeGracileTD(td);
td = removeBadNeurons(td, struct('min_fr', 1));    


td = getMoveOnsetAndPeak(td, params);
guide = td(1).([array, '_unit_guide']);
spikes = [array, '_spikes'];

td = removeBadTrials(td);
[~, td] = getTDidx(td, 'result','R');
td(isnan([td.idx_movement_on])) = [];
td = trimTD(td, {'idx_movement_on',-10}, {'idx_movement_on', 10});
td = dupeAndShift(td, 'vel', -1, 'force', -1);
dirsM = unique([td.target_direction]);
dirsM(isnan(dirsM)) = [];
if any(dirsM>7)
    dirsM(mod(dirsM, 45)~=0) = [];
else
    dirsM(mod(dirsM, pi/4)~=0) =[];
end
dirsF = unique([td.forceDir]);
dirsF(isnan(dirsF)) = [];
dirsF(dirsF>359) = [];
if any(dirsF>7)
    dirsF(mod(dirsF, 45)~=0) = [];
else
    dirsF(mod(dirsF, pi/4)~=0) =[];
end
%%
close all
colors = linspecer(length(dirsF));
% keyboard
rightTD = td([td.target_direction]==0);
figure
hold on
for i =1:length(dirsF)
    tdDir = rightTD(mod([rightTD.forceDir],360) == dirsF(i));
    fDir = cat(1, tdDir.pos);
    fDirM = mean(cat(3, tdDir.pos),3);
    
    scatter(fDir(:,1), fDir(:,2), 4, colors(i,:),'filled')
    plot(fDirM(:,1), fDirM(:,2),'LineWidth', 3,  'Color', colors(i,:))
end

xlim([-15, 15])
ylim([-50, -20])
figure
polarscatter([0:pi/4:7*pi/4], ones(length(dirsM),1),32,  colors, 'filled');
%%
figure
hold on
for i =1:length(dirsM)
    tdDir = td([td.target_direction] == dirsM(i));
    vDir = cat(1, tdDir.force);
    scatter(vDir(:,1), vDir(:,2), 4, colors(i,:),'filled')
    scatter(mean(vDir(:,1)), mean(vDir(:,2)), 64, colors(i,:), 'filled')
end
%%

butterDate = '20190129';
monkey= 'Butter';
date = butterDate;
tdCO = getTD(monkey, date, 'CO',2);

tdCO = tdToBinSize(tdCO, 10);
tdCO = smoothSignals(tdCO, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .1));
tdCO = getSpeed(tdCO);
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
tdCO = getMoveOnsetAndPeak(tdCO, params);
tdCO = dupeAndShift(tdCO, 'vel', -1:-1:-3, 'force', -1:-1:-3);
tdCO = trimTD(tdCO, {'idx_movement_on', -10}, {'idx_movement_on', 10});
%%
numBoots = 100;
perms = randi(length(td),length(td),numBoots);
permsCO = randi(length(tdCO), length(tdCO), numBoots);
r2 = zeros(numBoots, 2,2);
for i = 1:numBoots
forceCO = cat(1, tdCO(permsCO(:,i)).force);
forceCOShifts = cat(1,tdCO(permsCO(:,i)).force_shift);
forceCO = [forceCO, forceCOShifts];
velCO = cat(1, tdCO(permsCO(:,i)).vel);
velCO = [velCO,cat(1,tdCO(permsCO(:,i)).vel_shift)];

force = cat(1,td(perms(:,i)).force);
force = [force, cat(1,td(perms(:,i)).force_shift)];

vel = cat(1, td(perms(:,i)).vel);
vel = [vel, cat(1,td(perms(:,i)).vel_shift)];
%%
fitX = fitlm(force, vel(:,1));
fitY = fitlm(force, vel(:,2));

fitXCO = fitlm(forceCO,velCO(:,1));
fitYCO = fitlm(forceCO, velCO(:,2));

r2(i,1,1) = sqrt(fitX.Rsquared.Ordinary);
r2(i,1,2) = sqrt(fitY.Rsquared.Ordinary);
r2(i,2,1) = sqrt(fitXCO.Rsquared.Ordinary);
r2(i,2,2) = sqrt(fitYCO.Rsquared.Ordinary);
end
%%
figure
bar(squeeze(mean(r2)))
hold on
scatter(.85*ones(numBoots,1), r2(:, 1,1),8, 'k')
scatter(1.15*ones(numBoots,1), r2(:, 1,2),8, 'k')
scatter(1.85*ones(numBoots,1), r2(:, 2,1),8, 'k')
scatter(2.15*ones(numBoots,1), r2(:, 2,2),8, 'k')
xticklabels({'Bias Force','Center Out'})

a = get(gca, 'XTickLabel');
set(gca, 'XTickLabel', a, 'fontsize', 18)
xlabel('Task', 'FontSize', 18)
ylabel('Force/vel correlation', 'FontSize', 18)
legend('X','Y','Location','Northwest')
set(gca,'TickDir','out', 'box', 'off', 'LineWidth', 3)
yticklabels({'0', '', '0.2', '', '0.4', '', '0.6', '', '0.8','','1.0'}, 'FontSize', 18)

