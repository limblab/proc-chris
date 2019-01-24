%% Data loading routine and parameters
clear all

includePassive = false;
includeActive = true;
useMaxOnly = false;
doZscore = true;
doSmoothing = false;

actWindowStart = -50;
actWindowEnd = 300;
pasWindowStart = -50;
pasWindowEnd = 150;


trialName = 'PSTHPCA';
if useMaxOnly
   trialName = [trialName, 'Max'];
else
    trialName = [trialName, 'AllDirs'];
end
if includePassive
    trialName = [trialName, 'Passive'];
end
if includeActive
    trialName = [trialName, 'Active'];
end



monkey = 'Butter';
date = '20181218';
actWindow = {{'idx_movement_on', actWindowStart/10}, {'idx_movement_on', actWindowEnd/10}};
pasWindow = {{'idx_bumpTime', pasWindowStart/10}, {'idx_bumpTime', pasWindowEnd/10}};
preWindow = {{'idx_goCueTime',-5}, {'idx_goCueTime',0}};
% mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO');
array = getTDfields(td, 'arrays');
array_spikes = [array{1}, '_spikes'];
array_unit_guide = [array{1}, '_unit_guide'];
% getSensoryMappings(monkey);

savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'PSTHPCA',filesep];
mkdir(savePath);

if td(1).bin_size == .001
    td = binTD(td, 10);
end
%% Pre-process TD
% td1 = removeBadTrials(td);
if doSmoothing
    td = smoothSignals(td, struct('signals', 'cuneate_spikes','kernel_SD',0.04));
    trialName = [trialName, 'Smoothed'];
end
td = removeBadNeurons(td);
td = removeGracileTD(td);
td =  td(~isnan([td.target_direction]));
guide = td(1).(array_unit_guide);

neuronsToUse = find(td(1).(array_unit_guide)(:,2) >0); %all neurons
cellTemp = num2cell(rad2deg([td.target_direction]));
[td.target_direction] = cellTemp{:};
useGuide = guide(neuronsToUse,:);
useGuideRep = repmat(useGuide, 8,1);

% td = smoothSignals(td, struct('signals', array_spikes,'kernel_SD', .01, 'causal',true));

tdBump = td(~isnan([td.bumpDir]));

tdAct = trimTD(td, actWindow{1}, actWindow{2});
tdPas = trimTD(tdBump, pasWindow{1}, pasWindow{2});
tdPre = trimTD(td, preWindow{1}, preWindow{2});

%% Generate direction vectors for use in calculating PSTHs
dirsAct = unique([tdAct.target_direction]);
dirsAct = dirsAct(~isnan(dirsAct));

%% Make direction strings for future parsing
dirsActStr = strtrim(cellstr(num2str(dirsAct'))');
dirsActStr = strcat('D',dirsActStr);
%% Same with passive
dirsPas = unique([tdPas.bumpDir]);
dirsPas = dirsPas(~isnan(dirsPas));
dirsPasStr = strtrim(cellstr(num2str(dirsPas'))');
dirsPasStr = strcat('D',dirsPasStr);
%% Iterate through directions, calculate the mean firing (PSTH) from the selected window, and the overall average firing rate during each trial
for i = 1:length(dirsAct)
    raw{i}  = cat(3, tdAct([tdAct.target_direction] == dirsAct(i)).(array_spikes));
    raw{i} = raw{i}(:, neuronsToUse,:);
    meanFirAct(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringAct{i} = squeeze(mean(raw{i}));
end
tabAct = table(raw',meanFirAct, 'VariableNames', {'RawAct', 'MeanAct'}, 'RowNames', dirsActStr);
%% Calculate the pre-movement firing rate (pre-go cue baseline)
raw1 = cat(3, tdPre.(array_spikes));
raw1 = raw1(:,neuronsToUse,:);
meanFirPre = mean(squeeze(mean(raw1,3))*100);
meanTrialFiringPre = squeeze(mean(raw1));
%% Do the same for passive
for i = 1:length(dirsPas)
    
    raw{i}  = cat(3, tdPas([tdPas.bumpDir] == dirsPas(i)).(array_spikes));
    raw{i} = raw{i}(:, neuronsToUse,:);
    meanFirPas(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringPas{i} = squeeze(mean(raw{i}));

end
tabPas = table(raw',meanFirPas, 'VariableNames', {'RawPas', 'MeanPas'}, 'RowNames', dirsPasStr);

%% Determine if the neuron is tuned in a direction given an anova test
for i = 1:length(dirsAct)
    for j= 1:length(meanFirAct(1,1,:))
        groups = [ones(length(meanTrialFiringPre(j,:)),1); 2*ones(length(meanTrialFiringAct{i}(j,:)),1)];
        isTunedMat(j,i) = anovan([meanTrialFiringPre(j,:), meanTrialFiringAct{i}(j,:)], groups, 'display' ,'off');
    end
end

isTunedInd = find(any(isTunedMat'<.01));
%% create the firing table
firingTable = [tabAct,tabPas];
%%

%% Compute the PCA plot of selected neurons
close all
allPSTH = [];
rowLabels= [];
count = 0;
%% iterate through tuned neurons, find their max firing direction, and add the PSTH in the direciton of max firing as a row to the PCA matrix
for i = isTunedInd
    count = count + 1;
    [~, maxFiringDirAct(count)] = max(max(meanFirAct(:,:,i)'));
    [~, maxFiringDirPas(count)] = max(max(meanFirPas(:,:,i)'));
    %% Conditionals to check for which PSTHs to include in the PCA
    if includePassive & includeActive
        if useMaxOnly
            allPSTH = [allPSTH; meanFirAct(maxFiringDirAct(count), :, i); meanFirPas(maxFiringDirPas(count),:,i)];
            rowLabels = [rowLabels; repmat(guide(i,:),[2,1]),1:2];

        else
            allPSTH = [allPSTH; meanFirAct(:, :, i); meanFirPas(:,:,i)];
            rowLabels = [rowLabels; repmat(guide(i,:), [16,1]), [1:16]'];
        end
    elseif ~includePassive & includeActive
        if useMaxOnly
            allPSTH = [allPSTH; meanFirAct(maxFiringDirAct(count), :, i)];
            rowLabels = [rowLabels; guide(i,:)];
        else
            allPSTH = [allPSTH; meanFirAct(:, :, i)];
            rowLabels = [rowLabels; repmat(guide(i,:),[8, 1]), [1:8]'];
        end
    elseif includePassive & ~includeActive
        if useMaxOnly
            allPSTH = [allPSTH; meanFirPas(maxFiringDirPas(count), :, i)];
            rowLabels = [rowLabels; guide(i,:)];
        else
            allPSTH = [allPSTH; meanFirPas(:, :, i)];
            rowLabels = [rowLabels; repmat(guide(i,:),[8, 1]), [1:8]'];
        end
    end
end

%% Compute PCA
if doZscore
    allPSTH = zscore(allPSTH,0, 2);
    trialName = [trialName, 'Zscored'];
end

[coeff, scores, latent, t2, explained, mu] = pca(allPSTH);
[W, H] = nnmf(allPSTH, 2);
%% Plot the PCs of the matrix
figure2();
plot(linspace(actWindowStart, actWindowEnd, length(coeff(:,1))),coeff(:,1), 'LineWidth', 2)
hold on
plot(linspace(actWindowStart, actWindowEnd, length(coeff(:,1))),coeff(:,2), 'LineWidth', 2)
plot(linspace(actWindowStart, actWindowEnd, length(coeff(:,1))),coeff(:,3), 'LineWidth', 2)
plot(linspace(actWindowStart, actWindowEnd, length(coeff(:,1))),coeff(:,4), 'LineWidth', 2)
title('PCA templates for PSTH')
xlabel('time (ms)')
ylabel('firing (Hz)')
legend('PCA1', 'PCA2', 'PCA3','PCA4')
set(gca,'TickDir','out', 'box', 'off')
saveas(gca, [savePath, 'PrincipalComponents_', trialName, '.png'])
%% Plot the explained variance of the PSTH
figure2();
scatter(W(:,1), W(:,2))

figure2();
plot(cumsum(explained))
title('Variance explained plot')
xlabel('PCs included')
ylabel('Variance explained')
set(gca,'TickDir','out', 'box', 'off')
saveas(gca, [savePath, 'VarExplained_', trialName, '.png'])

colors = linspecer(5);

%% Generate video of neurons in PC space and their maximal firing directions
figure2();
scatter3(scores(:,3), scores(:,2), scores(:,1))
hold on
if useMaxOnly 
for i = 1:length(scores(:,1))
    switch maxFiringDirPas(i)
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
end
% legend('Wrist flexor spindles', 'Elbow Flexion', 'Lat spindle', 'Wrist Extensor Spindle', 'Biceps Spindle')
xlabel('PC3')
ylabel('PC2')
zlabel('PC1')
axis equal
% xlim([-1, 2])
CaptureFigVid([[1:360]', 20*ones(360,1)], [savePath ,'ClusteringVideo_', trialName])
%% 2d projection of neurons in the computed PC space
figure
scatter(scores(:,1), scores(:,2), 'Filled')
hold on


if useMaxOnly 
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
    text(scores(i,1)+.01, scores(i,2)+.01, ['E', num2str(useGuideRep(isTunedInd(i),1)),'U',num2str(useGuideRep(isTunedInd(i),2)), '$', arrow, '$'], 'Interpreter', 'latex')
end
end
set(gca,'TickDir','out', 'box', 'off')
xlabel('PC1')
ylabel('PC2')
title('Zoomed in PCA of PSTHs on central cluster')
saveas(gca, [savePath, 'PCScatterPlot_', trialName, '.pdf'])
%%
close all
k = 4;

[inds, cents, sumd, D] = kmeans(scores,k);
colors = linspecer(k);

figure2();
hold on
for i =1:k
    scatter3(scores(inds ==i,3), scores(inds==i,2),scores(inds==i,1),[], colors(i,:),'filled')
end
xlabel('PC3')
ylabel('PC2')
zlabel('PC1')
axis equal
view(3)
legend
CaptureFigVid([[1:360]', 20*ones(360,1)], ['kmeans_',num2str(k),'clusters_', trialName])


%%
figure2();
hold on
name1 = [rowLabels(inds ==1,:), D(inds==1,1)];
name2 = [rowLabels(inds ==2,:), D(inds==2,2)];
name3 = [rowLabels(inds ==3,:), D(inds==3,3)];
name4 = [rowLabels(inds ==4,:), D(inds==4,4)];
centroidShapes = [cents*coeff']';
for i = 1:4
    plot(linspace(actWindowStart, actWindowEnd, length(centroidShapes(:,1))),centroidShapes(:,i), 'Color', colors(i,:), 'LineWidth', 2);

end
title('Centroids of clusters projected back into PSTH space')
xlabel('Time (ms)')
ylabel('Firing (normalized AU)')
legend('Cluster 1', 'Cluster 2', 'Cluster 3', 'Cluster 4')
set(gca,'TickDir','out', 'box', 'off')
saveas(gca, [savePath, 'CentroidProjectionPSTH_', trialName, '.png'])
