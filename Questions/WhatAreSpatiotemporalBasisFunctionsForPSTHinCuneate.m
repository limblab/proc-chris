clear all
%% File loading and parameter settting
includePassive = true;
includeActive = false;
doZscore = true;

trialName = 'Spatiotemporal';
if includePassive & ~includeActive
    trialName = [trialName, 'Passive'];
elseif ~includePassive & includeActive
    trialName = [trialName, 'Active'];
else includePassive & includeActive
    trialName = [trialName, 'PassiveActive'];
end

monkey = 'Butter';
date = '20181218';
actWindow = {{'idx_movement_on', -5}, {'idx_movement_on', 30}};
pasWindow = {{'idx_bumpTime', -5}, {'idx_bumpTime', 15}};
preWindow = {{'idx_goCueTime',-5}, {'idx_goCueTime',0}};
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO');
getSensoryMappings(monkey);
array = getTDfields(td, 'arrays');
array_spikes = [array{1}, '_spikes'];
array_unit_guide = [array{1}, '_unit_guide'];
% getSensoryMappings(monkey);

if td(1).bin_size == .001
    td = binTD(td, 10);
end

savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'SpatiotemporalClustering',filesep];
mkdir(savePath);

%% Pre-process TD
% td = removeBadTrials(td);
td = removeBadNeurons(td);
td = removeGracileTD(td);
% td = smoothSignals(td, struct('signals', 'cuneate_spikes'));

td =  td(~isnan([td.target_direction]));
guide = td(1).(array_unit_guide);
tdBump = td(~isnan([td.bumpDir]));

neuronsToUse = find(td(1).(array_unit_guide)(:,2) >0); %all neurons
useGuide = guide(neuronsToUse,:);
useGuideRep = repmat(useGuide, 8,1);
cellTemp = num2cell(rad2deg([td.target_direction]));
[td.target_direction] = cellTemp{:};

tdAct = trimTD(td, actWindow{1}, actWindow{2});
tdPas = trimTD(tdBump, pasWindow{1}, pasWindow{2});
tdPre = trimTD(td, preWindow{1}, preWindow{2});

%% compute directions for PSTHs
dirsAct = unique([tdAct.target_direction]);
dirsAct = dirsAct(~isnan(dirsAct));
dirsActStr = strtrim(cellstr(num2str(dirsAct'))');

dirsActStr = strcat('D',dirsActStr);

dirsPas = unique([tdPas.bumpDir]);
dirsPas = dirsPas(~isnan(dirsPas));
dirsPasStr = strtrim(cellstr(num2str(dirsPas'))');

dirsPasStr = strcat('D',dirsPasStr);
%% Compute average PSTH in each direction in active and passive, as well as premovement
for i = 1:length(dirsAct)
    raw{i}  = cat(3, tdAct([tdAct.target_direction] == dirsAct(i)).(array_spikes));
    raw{i} = raw{i}(:, neuronsToUse,:);
    meanFirAct(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringAct{i} = squeeze(mean(raw{i}));
end
tabAct = table(raw',meanFirAct, 'VariableNames', {'RawAct', 'MeanAct'}, 'RowNames', dirsActStr);
raw1 = cat(3, tdPre.(array_spikes));
raw1 = raw1(:,neuronsToUse,:);
meanFirPre = mean(squeeze(mean(raw1,3))*100);
meanTrialFiringPre = squeeze(mean(raw1));
for i = 1:length(dirsPas)
    
    raw{i}  = cat(3, tdPas([tdPas.bumpDir] == dirsPas(i)).(array_spikes));
        raw{i} = raw{i}(:, neuronsToUse,:);
    meanFirPas(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringPas{i} = squeeze(mean(raw{i}));

end
%% Find whethere neurons are tuned for inclusion in analysis
for i = 1:length(dirsAct)
    for j= 1:length(meanFirAct(1,1,:))
        groups = [ones(length(meanTrialFiringPre(j,:)),1); 2*ones(length(meanTrialFiringAct{i}(j,:)),1)];
        isTunedMat(j,i) = anovan([meanTrialFiringPre(j,:), meanTrialFiringAct{i}(j,:)], groups, 'display' ,'off');
    end
end
tabPas = table(raw',meanFirPas, 'VariableNames', {'RawPas', 'MeanPas'}, 'RowNames', dirsPasStr);

isTunedInd = find(any(isTunedMat'<.001));

firingTable = [tabAct,tabPas];
%% Generate matrix of trials, each row is the horzcatted PSTH in each direction, with the option of including passive as well
close all
allPSTH = [];
count = 0;
for i = isTunedInd
    count = count + 1;
    [~, maxFiringDirAct(count)] = max(max(meanFirAct(:,:,i)'));
    [~, maxFiringDirPas(count)] = max(max(meanFirPas(:,:,i)'));
    if includePassive & includeActive
        allPSTH = [allPSTH; [reshape(meanFirAct(:, :, i)',1, length(meanFirAct(1,:,1))*length(meanFirAct(:,1,1))), reshape(meanFirPas(:, :, i)',1, length(meanFirPas(1,:,1))*length(meanFirPas(:,1,1)))]];
    elseif includeActive & ~includePassive
      allPSTH = [allPSTH; reshape(meanFirAct(:, :, i)',1, length(meanFirAct(1,:,1))*length(meanFirAct(:,1,1)))];
    elseif includePassive & ~includeActive
        allPSTH = [allPSTH; reshape(meanFirPas(:,:,i)',1, length(meanFirPas(1,:,1))*length(meanFirPas(:,1,1)))];
    end
end
%% Compute the PCA on the matrix
if doZscore
    allPSTH = zscore(allPSTH,0, 2);
    trialName = [trialName, 'Zscored'];
end
    
[coeff, scores, latent, t2, explained, mu] = pca(allPSTH);
%% Plot the first few PCs in a line
figure2();
plot(coeff(:,1), 'LineWidth', 2)
hold on
plot(coeff(:,2), 'LineWidth', 2)
plot(coeff(:,3), 'LineWidth', 2)
plot(coeff(:,4), 'LineWidth', 2)
title('PCA templates for PSTH')
xlabel('time (ms)')
ylabel('firing (Hz)')
legend('PCA1', 'PCA2', 'PCA3','PCA4')
set(gca,'TickDir','out', 'box', 'off')
saveas(gca, [savePath, 'WrappedPCs_', trialName, '.png']);

%% Plot the first few PCs after re-wrapping them around the circle
for i =1:6
    if length(dirsAct) ==8
    if includePassive & includeActive
    pcReshaped = reshape(coeff(:,i), length(coeff(:,i))/16, 16);
    ylimits = [min(min(pcReshaped)), max(max(pcReshaped))];
    figure2();
    subplot(3, 3, 6)
    plot(pcReshaped(:,1), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,9), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 3)
    plot(pcReshaped(:,2), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,10), 'LineWidth', 2)
    ylim(ylimits)

    subplot(3,3, 2)
    plot(pcReshaped(:,3), 'LineWidth', 1)
    hold on
    plot(pcReshaped(:,11), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 1)
    plot(pcReshaped(:,4), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,12), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 4)
    plot(pcReshaped(:,5), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,13), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 7)
    plot(pcReshaped(:,6), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,14), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 8)
    plot(pcReshaped(:,7), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,15), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 9)
    plot(pcReshaped(:,8), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,16), 'LineWidth', 2)
    ylim(ylimits)
    
    suptitle(['PC ', num2str(i)])
    else
    pcReshaped = reshape(coeff(:,i), length(coeff(:,i))/8, 8);
    ylimits = [min(min(pcReshaped)), max(max(pcReshaped))];
    figure2();
    subplot(3, 3, 6)
    plot(pcReshaped(:,1), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 3)
    plot(pcReshaped(:,2), 'LineWidth', 2)
    ylim(ylimits)

    subplot(3,3, 2)
    plot(pcReshaped(:,3), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 1)
    plot(pcReshaped(:,4), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 4)
    plot(pcReshaped(:,5), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 7)
    plot(pcReshaped(:,6), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 8)
    plot(pcReshaped(:,7), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 9)
    plot(pcReshaped(:,8), 'LineWidth', 2)
    ylim(ylimits)
    
    suptitle(['PC ', num2str(i)])
    
    end
    elseif length(dirsAct) ==4
    if includePassive & includeActive
    pcReshaped = reshape(coeff(:,i), length(coeff(:,i))/8, 8);
    ylimits = [min(min(pcReshaped)), max(max(pcReshaped))];
    figure2();
    subplot(3, 3, 6)
    plot(pcReshaped(:,1), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,5), 'LineWidth', 2)
    ylim(ylimits)

    subplot(3,3, 2)
    plot(pcReshaped(:,2), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,6), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 4)
    plot(pcReshaped(:,3), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,7), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 8)
    plot(pcReshaped(:,4), 'LineWidth', 2)
    hold on
    plot(pcReshaped(:,8), 'LineWidth', 2)
    ylim(ylimits)
    
    suptitle(['PC ', num2str(i)])
    else
    pcReshaped = reshape(coeff(:,i), length(coeff(:,i))/4, 4);
    ylimits = [min(min(pcReshaped)), max(max(pcReshaped))];
    figure2();
    subplot(3, 3, 6)
    plot(pcReshaped(:,1), 'LineWidth', 2)
    ylim(ylimits)
    
    subplot(3,3, 2)
    plot(pcReshaped(:,2), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 4)
    plot(pcReshaped(:,3), 'LineWidth', 2)
    ylim(ylimits)
    subplot(3,3, 8)
    plot(pcReshaped(:,4), 'LineWidth', 2)
    ylim(ylimits)    
    suptitle(['PC ', num2str(i)])
    
    end
    end
saveas(gca, [savePath, 'PrincipalComponentsVector',num2str(i), '_', trialName, '.png']);

end

%% Plot variance epxlained
figure2();
plot(cumsum(explained), 'LineWidth', 2)
title('Variance explained plot')
xlabel('PCs included')
ylabel('Variance explained')
set(gca,'TickDir','out', 'box', 'off')
saveas(gca, [savePath, 'ExplainedVariance_', trialName, '.pdf']);
%% Plot Scores w/ combined PC1 and 2
figure2();
scatter3(scores(:,3),scores(:,2), scores(:,1))
hold on
for i = 1:length(scores(:,1))
    switch maxFiringDirAct(i)
        case 1
           arrow = '\rightarrow';
        case 2
            arrow = '\nearrow';
        case 3
            arrow = '\uparrow';
        case 4
            arrow = '\nwarrow';
        case 5
            arrow = '\leftarrow';
        case 6
            arrow = '\swarrow';
        case 7
            arrow = '\downarrow';
        case 8
            arrow = '\searrow';
    end
    text(scores(i,3)+.01, scores(i,2)+.01,scores(i,1)+.01, ['E', num2str(useGuideRep(isTunedInd(i),1)),'U',num2str(useGuideRep(isTunedInd(i),2)), '$', arrow, '$'], 'Interpreter', 'latex')
end
% legend('Wrist flexor spindles', 'Elbow Flexion', 'Lat spindle', 'Wrist Extensor Spindle', 'Biceps Spindle')
xlabel('PC3')
ylabel('PC2')
zlabel('PC1')
axis square
% xlim([-1, 2])
% ylim([-3,2])
% zlim([-3,1])
CaptureFigVid([[1:360]', 20*ones(360,1)], [savePath, 'ClusteringVideo_', trialName])
%% 2D scatter plot of PCs for inspection
figure2()
scatter(scores(:,1), scores(:,2), 'Filled')
hold on

for i = 1:length(scores(:,1))
    switch maxFiringDirAct(i)
        case 1
           arrow = '\rightarrow';
        case 2
            arrow = '\nearrow';
        case 3
            arrow = '\uparrow';
        case 4
            arrow = '\nwarrow';
        case 5
            arrow = '\leftarrow';
        case 6
            arrow = '\swarrow';
        case 7
            arrow = '\downarrow';
        case 8
            arrow = '\searrow';
    end
    text(scores(i,1)+.01, scores(i,2)+.01,  ['E', num2str(useGuideRep(isTunedInd(i),1)),'U',num2str(useGuideRep(isTunedInd(i),2)), '$', arrow, '$'], 'Interpreter', 'latex')
end
set(gca,'TickDir','out', 'box', 'off')
xlabel('PC1')
ylabel('PC2')
title('PCA of spatiotemporal PSTHs')
rectangle('Position',[3,0,6,6],'Curvature', .1,  'EdgeColor', 'r')
xlim([3, 9])
ylim([0, 6])
saveas(gca, [savePath, 'PCScatterBoxZoomed_', trialName, '.png']);

%% Clustering analysis in PC space
close all
k = 4;

[inds, cents, sumd] = kmeans(scores(:,1:6),k);
colors = linspecer(k);

figure2();
hold on
for i =1:k
    scatter3(scores(inds ==i,3), scores(inds==i,2),scores(inds==i,1),[], colors(i,:),'filled')
end
xlabel('PC3')
ylabel('PC2')
zlabel('PC1')
axis square
view(3)
for i = 1:length(scores(:,1))
    switch maxFiringDirAct(i)
        case 1
           arrow = '\rightarrow';
        case 2
            arrow = '\nearrow';
        case 3
            arrow = '\uparrow';
        case 4
            arrow = '\nwarrow';
        case 5
            arrow = '\leftarrow';
        case 6
            arrow = '\swarrow';
        case 7
            arrow = '\downarrow';
        case 8
            arrow = '\searrow';
    end
    text(scores(i,3)+.01, scores(i,2)+.01, scores(i,1)+.01, ['$', arrow, '$'], 'Interpreter', 'latex')
end
CaptureFigVid([[1:360]', 20*ones(360,1)], [savePath, 'kmeans_',num2str(k),'clusters_', trialName])
