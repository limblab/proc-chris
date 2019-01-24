%% This script generates PCA on the full tuning curves (cols are the directions, rows are neurons)
%% First PC is the sinusoidally tuned neuron pointing down and left
%% It encompasses 95% of the variance
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

useGuide = guide(neuronsToUse,:);
useGuideRep = repmat(useGuide, 8,1);
cellTemp = num2cell(rad2deg([td1.target_direction]));
[td1.target_direction] = cellTemp{:};

tdAct = trimTD(td1, actWindow{1}, actWindow{2});
tdPas = trimTD(td1, pasWindow{1}, pasWindow{2});
tdPre = trimTD(td1, preWindow{1}, preWindow{2});

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
    meanFiringAct(i,:) = mean(meanTrialFiringAct{i}').*100;
    
end
tabAct = table(raw',meanFirAct, 'VariableNames', {'RawAct', 'MeanAct'}, 'RowNames', dirsActStr);

for i = 1:length(dirsPas)
    
    raw{i}  = cat(3, tdPas([tdPas.bumpDir] == dirsPas(i)).cuneate_spikes);
        raw{i} = raw{i}(:, neuronsToUse,:);
    meanFirPas(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringPas{i} = squeeze(mean(raw{i}));
    meanFiringPas(i,:) = mean(meanTrialFiringPas{i}').*100;


end
raw1 = cat(3, tdPre.cuneate_spikes);
raw1 = raw1(:,neuronsToUse,:);
meanFirPre = mean(squeeze(mean(raw1,3))*100);
meanTrialFiringPre = squeeze(mean(raw1));
tabPas = table(raw',meanFirPas, 'VariableNames', {'RawPas', 'MeanPas'}, 'RowNames', dirsPasStr);

for i = 1:length(dirsAct)
    for j= 1:length(meanFirAct(1,1,:))
        groups = [ones(length(meanTrialFiringPre(j,:)),1); 2*ones(length(meanTrialFiringAct{i}(j,:)),1)];
        isTunedMat(j,i) = anovan([meanTrialFiringPre(j,:), meanTrialFiringAct{i}(j,:)], groups, 'display' ,'off');
    end
end


isTunedInd = find(any(isTunedMat'<.01));

firingTable = [tabAct,tabPas];
%%

[coeffAct, scoreAct, latentAct, t2act, expAct] = pca(meanFiringAct(:,isTunedInd)');
[coeffPas, scorePas, latentPas, t2pas, expPas] = pca(meanFiringPas(:,isTunedInd)');

figure2();
scatter3(scoreAct(:,3), scoreAct(:,2), scoreAct(:,1))
hold on
for i = 1:length(scoreAct(:,1))
   
    text(scoreAct(i,3)+.01, scoreAct(i,2)+.01,scoreAct(i,1)+.01, ['E', num2str(useGuideRep(isTunedInd(i),1)),'U',num2str(useGuideRep(isTunedInd(i),2))])
end

xlabel('PC3')
ylabel('PC2')
zlabel('PC1')
axis square
CaptureFigVid([[1:360]', 20*ones(360,1)], 'ClusteringVideoTuningCurvePCA.mpg')


%%
figure2();
plot(linspace(0, 315, 8),coeffAct(:,1))
hold on
plot(linspace(0, 315, 8),coeffAct(:,2))
plot(linspace(0, 315, 8),coeffAct(:,3))
plot(linspace(0, 315, 8),coeffAct(:,4))
title('PCA templates for PSTH')
xlabel('Angle(degrees)')
ylabel('firing (Hz)')
legend('PCA1', 'PCA2', 'PCA3','PCA4')
set(gca,'TickDir','out', 'box', 'off')

figure2();
plot(cumsum(expAct))
title('Variance explained plot')
xlabel('PCs included')
ylabel('Variance explained')
set(gca,'TickDir','out', 'box', 'off')
