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
end


xlim([2, 11])
ylim([0, 50])
ylabel('Peak Speeds')
xlabel('Target Distances')
title(['Peak speed scales with target distance'])
legend(string(num2cell(rad2deg(dirsM))), 'Location', 'northwest')
set(gca,'TickDir','out', 'box', 'off')


splitsFrac = 0:.2:1.0;
for i = 1:length(dirsM)
    tdDir{i} = tdPeak([tdPeak.target_direction] == dirsM(i));
    tdDir1{i} = td([td.target_direction] == dirsM(i));
    
    speeds{i} = cat(1, tdDir{i}.speed);
    dists{i} = cat(1, tdDir{i}.tgtDist);
    for j = 1:length(splitsFrac)-1
        [sSpeeds, sInd] = sort(speeds{i});
        tdSpeed{i,j} = tdDir{i}(sInd(floor(splitsFrac(j)*length(tdDir{i})): floor(splitsFrac(j+1)*length(tdDir{i}))));
        tdDirSpeed{i} = [tdDirSpeed{i}, tdSpeed{i,j}];
    end
end


edgeVec = 5:10:45;
midVec = 10:10:40;
guide = td(1).([array,'_unit_guide']);
for  i= 1:length(dirsM)
    tdDirPeak = tdPeak([tdPeak.target_direction] == dirsM(i));
    speeds1 = cat(3, tdDirPeak.speed);
    firing = cat(3, tdDirPeak.([array, '_spikes']));
    meanFR{i}    = squeeze(firing);
    speedTrial{i} = squeeze(speeds1);
    edgeInds{i} = getIndicesInsideEdge(speedTrial{i}, edgeVec);
    for j = 1:length(edgeInds{i}(:,1))
        edgeFR{i}(j,:) = mean(meanFR{i}(:, edgeInds{i}(j,:)),2);
    end

end
for i = 1:length(meanFR{1}(:,1))
    figure2();
    hold on
    for j = 1:length(dirsM)
%         scatter(speedTrial{j}, meanFR{j}(i, :), 16, colors(j,:), 'filled','HandleVisibility', 'off')
        plot(midVec, edgeFR{j}(:,i),'Color', colors(j,:),'HandleVisibility', 'off')
        s1 = scatter(-1,-1, 16, colors(j,:), 'filled');
    end
    xlim([10, 45])
    title(['Electrode ', num2str(guide(i,1)), ' Unit ' , num2str(guide(i,2))])
    xlabel('Hand speed at peak')
    ylabel('Firing rate at peak')
    legend(string(num2cell(rad2deg(dirsM))), 'Location', 'northwest')

%     pause
    close all
    
end
%% There's going to be a continuous distribution of target distances, making modeling somewhat difficult
% Easist way may be just to split it into two groups ("close", "slow"
% reaches and "far", "fast" reaches. Then fit GLMs on each and compare
% their performances.
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';
% params.glm_distribution
varsToUse = {{'vel'}};
%              {{'pos';'vel';'acc';'speed';'force'}};%, ...
%              {'vel';'acc';'speed'; 'force'},...
%              {'pos';'speed';'acc'; 'force'},...
%              {'pos';'vel';'speed';'force'},...
%              {'pos';'vel';'acc';'speed'},...
%              {'pos';'vel';'acc'; 'force'},...
%              {'pos'},...
%              {'vel'},...
%              {'vel_hw'},...
%              {'vel_fw'},...
%              {'acc'},...
%              {'force'},...
%              {'speed'},...
%              {'speed';'vel'},...
%              {'pos';'vel';'acc';'vel_fw'; 'force'}};
%          
               

     
for j = 1:length(varsToUse)
    disp(['Working on  ' strjoin(varsToUse{j})])
    params.in_signals= varsToUse{j};
    params.model_name = strjoin(varsToUse{j}, '_');
    modelNames{j} = strjoin(varsToUse{j}, '_');
    params.out_signals = {spikes};
    
    cv(:,:,j) = getCVModelParams(tdFast, params);
    
    
    [tdFast, modelFast{j}] = getModel(tdFast, params);
    pr2Fast(j,:) = squeeze(evalModel(tdFast, params));
    
    [tdSlow, modelSlow{j}] = getModel(tdSlow, params);
    pr2Slow(j,:) = squeeze(evalModel(tdSlow, params));
    
    
end
%%
modelFast1 = modelFast{1};
modelSlow1 = modelSlow{1};

bFast = modelFast1.b(2:3,:);
vecFast = rownorm(bFast');

bSlow = modelSlow1.b(2:3,:);
vecSlow = rownorm(bSlow');

figure2();
scatter(vecSlow, vecFast, 16,'k', 'filled')
hold on
plot([0, max([vecSlow, vecFast])], [0, max([vecSlow, vecFast])], 'r--')
xlabel('Slow Sensitivity')
ylabel('Fast Sensitivity')
title1 = ['SlowFastSensitivity', monkey, date];
title(['Neural sensitivity to slow/fast movements', monkey])
xlim([0,.1])
ylim([0,.1])
set(gca,'TickDir','out', 'box', 'off')

saveas(gca, ['C:\Users\wrest\Pictures\ResultsPPFigs\', title1,'.pdf'])
