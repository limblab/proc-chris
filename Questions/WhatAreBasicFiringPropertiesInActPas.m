clear all
monkey = 'Butter';
date = '20181218';
actWindow = {{'idx_movement_on', -5}, {'idx_movement_on', 13}};
pasWindow = {{'idx_bumpTime', -5}, {'idx_bumpTime', 13}};
preWindow = {{'idx_goCueTime',-5}, {'idx_goCueTime',0}};
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO');
getSensoryMappings(monkey);

%% Pre-process TD
td1 = removeBadTrials(td);
td1 = removeBadNeurons(td1);
td1 = removeGracileTD(td1);
td1 =  td1(~isnan([td1.target_direction]));
guide = td1(1).cuneate_unit_guide;

neuronsToUse = find(td1(1).cuneate_unit_guide(:,2) >0); %all neurons
% neuronsToUse =  [8 13 18 20 22 26 28 30 65 66 67 69 76 81 115 116 2 7 6 9 62 73 10 11 15];

% [~, neuronsToUse] = intersect(guide,[neuronsChan, neuronsID], 'stable','rows');

useGuide = guide(neuronsToUse,:);
useGuideRep = repmat(useGuide, 8,1);
cellTemp = num2cell(rad2deg([td1.target_direction]));
[td1.target_direction] = cellTemp{:};


% td1 = removeBadNeurons(td1);
td1 = smoothSignals(td1, struct('signals', 'cuneate_spikes','kernel_SD', .01, 'causal',true));

tdAct = trimTD(td1, actWindow{1}, actWindow{2});
tdPas = trimTD(td1, pasWindow{1}, pasWindow{2});
tdPre = trimTD(td1, preWindow{1}, preWindow{2});
%% Make firing structure

%%
dirsAct = unique([tdAct.target_direction]);
dirsAct = dirsAct(~isnan(dirsAct));
dirsActStr = strtrim(cellstr(num2str(dirsAct'))');

dirsActStr = strcat('D',dirsActStr);

dirsPas = unique([tdPas.bumpDir]);
dirsPas = dirsPas(~isnan(dirsPas));
dirsPasStr = strtrim(cellstr(num2str(dirsPas'))');

dirsPasStr = strcat('D',dirsPasStr);
%%
for i = 1:length(dirsAct)
    
    raw{i}  = cat(3, tdAct([tdAct.target_direction] == dirsAct(i)).cuneate_spikes);
    raw{i} = raw{i}(:, neuronsToUse,:);
    meanFirAct(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringAct{i} = squeeze(mean(raw{i}));
end
tabAct = table(raw',meanFirAct, 'VariableNames', {'RawAct', 'MeanAct'}, 'RowNames', dirsActStr);
raw1 = cat(3, tdPre.cuneate_spikes);
raw1 = raw1(:,neuronsToUse,:);
meanFirPre = mean(squeeze(mean(raw1,3))*100);
meanTrialFiringPre = squeeze(mean(raw1));

for i = 1:length(dirsPas)
    
    raw{i}  = cat(3, tdPas([tdPas.target_direction] == dirsPas(i)).cuneate_spikes);
        raw{i} = raw{i}(:, neuronsToUse,:);
    meanFirPas(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringPas{i} = squeeze(mean(raw{i}));

end

for i = 1:length(dirsAct)
    for j= 1:length(meanFirAct(1,1,:))
        groups = [ones(length(meanTrialFiringPre(j,:)),1); 2*ones(length(meanTrialFiringAct{i}(j,:)),1)];
        isTunedMat(j,i) = anovan([meanTrialFiringPre(j,:), meanTrialFiringAct{i}(j,:)], groups, 'display' ,'off');
    end
end
tabPas = table(raw',meanFirPas, 'VariableNames', {'RawPas', 'MeanPas'}, 'RowNames', dirsPasStr);

isTunedInd = find(any(isTunedMat'<.01));

firingTable = [tabAct,tabPas];
%%

%%
% temp = cp_als(tensor(firing.active.all(:, neuronsToUse,:)- mean(firing.active.all(:,neuronsToUse, :))), 2, 'maxiters', 300, 'printitn',10);
% %M_neural = cp_apr(neural_tensor,num_factors,'maxiters',300,'printitn',10);% color by direction
% num_colors = 4;
% dir_colors = linspecer(num_colors);
% trial_dirs = cat(1,td1.target_direction);
% dir_idx = mod(round(trial_dirs/(2*pi/num_colors)),num_colors)+1;
% trial_colors = dir_colors(dir_idx,:);
% 
% % plot tensor decomposition
% plotTensorDecomp(temp,struct('trial_colors',trial_colors,'bin_size',td1(1).bin_size,'temporal_zero',5+1))

%% Compute the PCA plot of selected neurons
close all
allPSTH = [];
%% compute the maximal firing rate direction psth
count = 0;
for i = isTunedInd
    count = count + 1;
    [~, maxFiringDirAct(count)] = max(max(meanFirAct(:,:,i)'));
    [~, maxFiringDirPas(count)] = max(max(meanFirPas(:,:,i)'));
    allPSTH = [allPSTH; meanFirAct(maxFiringDirAct(count), :, i)];
end
%%
% allPSTH = allPSTH';
% allPSTHz = zscore(allPSTH);
% wristFlexors = [98, 19, 23, 25,27,29];
% wristExtensors = [4,12];
% latSpindle = [60];
% elbowFlexion = [172,91 175];
% bicepSpindle = [2];

[coeff, scores, latent, t2, explained, mu] = pca(allPSTH);
[W, H] = nnmf(allPSTH, 2);

figure2();
plot(-50:10:130,coeff(:,1))
hold on
plot(-50:10:130,coeff(:,2))
plot(-50:10:130,coeff(:,3))
plot(-50:10:130,coeff(:,4))
title('PCA templates for PSTH')
xlabel('time (ms)')
ylabel('firing (Hz)')
legend('PCA1', 'PCA2', 'PCA3','PCA4')
set(gca,'TickDir','out', 'box', 'off')

figure2();
scatter(W(:,1), W(:,2))

figure2();
plot(cumsum(explained))
title('Variance explained plot')
xlabel('PCs included')
ylabel('Variance explained')
set(gca,'TickDir','out', 'box', 'off')

colors = linspecer(5);

figure2();
% scatter3(coeff(intersectWF,1), coeff(intersectWF,2), coeff(intersectWF,3),[], colors(1,:))
% hold on
% scatter3(coeff(intersectEF,1), coeff(intersectEF,2), coeff(intersectEF,3),[], colors(2,:))
% scatter3(coeff(intersectLat,1), coeff(intersectLat,2), coeff(intersectLat,3),[], colors(3,:))
% scatter3(coeff(intersectWE,1), coeff(intersectWE,2), coeff(intersectWE,3),[], colors(4,:))
% scatter3(coeff(intersectBic,1), coeff(intersectBic,2), coeff(intersectBic,3),[], colors(5,:))
scatter3(scores(:,3), scores(:,2), scores(:,1))
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
CaptureFigVid([[1:360]', 20*ones(360,1)], 'ClusteringVideoPSTHPCsZscore.mpg')
%%
figure
scatter(scores(:,1), scores(:,2), 'Filled')
hold on
xlim([-200,200])
ylim([-50,50])
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
set(gca,'TickDir','out', 'box', 'off')
xlabel('PC1')
ylabel('PC2')
title('Zoomed in PCA of PSTHs on central cluster')

