% clear all
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170320/Lando_COactpas_20170320_001_TD_wNaming.mat')
% params.cutoff = pi/4;
% params.arrays ={'LeftS1','RightCuneate'};
% params.windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
% params.windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
% params.distribution = 'normal';
% params.date = '03202017';
% params.train_new_model = false;
% params.cuneate_flag = true;
% 
% processedTrial03202017 = compiledCOActPasAnalysis(td, params);
% %%
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170903/Lando_COactpas_20170903_001_TD_wNaming.mat')
% params.cutoff = pi/4;
% params.arrays ={'LeftS1','RightCuneate'};
% params.windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
% params.windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
% params.distribution = 'normal';
% params.date = '09032017';
% params.train_new_model = false;
% params.cuneate_flag = true;
% 
% processedTrial09032017 = compiledCOActPasAnalysis(td, params);
% 
% 
% %% 
% load('/media/chris/HDD/Data/MonkeyData/CDS/Lando/20170917/Lando_COactpas_20170917_001_TD_wNaming.mat')
% params.cutoff = pi/4;
% params.arrays ={'area2','cuneate'};
% params.windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
% params.windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
% params.distribution = 'normal';
% params.date = '09172017';
% 
% params.train_new_model = false;
% params.cuneate_flag = true;
% 
% processedTrial09172017 = compiledCOActPasAnalysis(td, params);


%%
% get bins
close all
bins = linspace(-pi,pi,5);
bins = bins(2:end);
trial = processedTrial09172017;
whichUnits = find(trial(2).actPDTable.sinTuned);
compareTuning({trial(2).tuningCurveAct, trial(2).tuningCurvePas},...
    {trial(2).actPDTable, trial(2).pasPDTable},bins, ...
    whichUnits);
[fh1, output1] = rotate_tuning_curves(trial(2).tuningCurveAct(whichUnits([1:11,13]),:), trial(2).tuningCurvePas(whichUnits([1:11,13]),:), bins);

clear whichUnits
trial = processedTrial03202017;
whichUnits = find(trial(1).actPDTable.sinTuned);
compareTuning({trial(1).tuningCurveAct, trial(1).tuningCurvePas},...
    {trial(1).actPDTable, trial(1).pasPDTable},bins, ...
    whichUnits);
[fh1, output1] = rotate_tuning_curves(trial(1).tuningCurveAct(whichUnits,:), trial(1).tuningCurvePas(whichUnits,:), bins);


%%
close all

cuneateCompiledProcessed(1) = processedTrial03202017(2).actPasStats;
cuneateCompiledProcessed(2) = processedTrial09032017(2).actPasStats;
cuneateCompiledProcessed(3) = processedTrial09172017(2).actPasStats;

s1CompiledProcessed(1) = processedTrial03202017(1).actPasStats;

angBump = cat(2,cuneateCompiledProcessed.angBump);
angMove = cat(2,cuneateCompiledProcessed.angMove);
tuned = cat(2,cuneateCompiledProcessed.tuned);
pasActDif = cat(2,cuneateCompiledProcessed.pasActDif);
dcBump = cat(2, cuneateCompiledProcessed.dcBump);
dcMove = cat(2,cuneateCompiledProcessed.dcMove);
modDepthMove = cat(2,cuneateCompiledProcessed.modDepthMove);
modDepthBump = cat(2, cuneateCompiledProcessed.modDepthBump);

cuneateCompiledPDsActive =[processedTrial03202017(2).actPDTable; processedTrial09032017(2).actPDTable; processedTrial09172017(2).actPDTable];
cuneateCompiledPDsPassive = [processedTrial03202017(2).pasPDTable;processedTrial09032017(2).pasPDTable; processedTrial09172017(2).pasPDTable];

for i =1:height(cuneateCompiledPDsActive)
   activePDCI = cuneateCompiledPDsActive.velPDCI(i,:);
   passivePDCI = cuneateCompiledPDsPassive.velPDCI(i,:);
   
   widthActive(i) = activePDCI(2)-activePDCI(1);
   widthPassive(i) = passivePDCI(2)-passivePDCI(1);
   
   difWidthCuneate(i) =widthPassive(i)-widthActive(i);
   
end


compiledTuningMetricsCuneate = ([dcMove;dcBump;modDepthMove; modDepthBump; difWidthCuneate; abs([cuneateCompiledPDsActive.velPD]'-[cuneateCompiledPDsPassive.velPD]')]');

angBumpS1 = cat(2,s1CompiledProcessed.angBump);
angMoveS1 = cat(2,s1CompiledProcessed.angMove);
tunedS1 = cat(2,s1CompiledProcessed.tuned);
pasActDifS1 = cat(2,s1CompiledProcessed.pasActDif);
dcBumpS1 = cat(2, s1CompiledProcessed.dcBump);
dcMoveS1 = cat(2,s1CompiledProcessed.dcMove);
modDepthMoveS1 = cat(2,s1CompiledProcessed.modDepthMove);
modDepthBumpS1 = cat(2, s1CompiledProcessed.modDepthBump);

S1CompiledPDsActive = processedTrial03202017(1).actPDTable;
S1CompiledPDsPassive = processedTrial03202017(1).pasPDTable;

for i =1:height(S1CompiledPDsActive)
   activePDCI = S1CompiledPDsActive.velPDCI(i,:);
   passivePDCI = S1CompiledPDsPassive.velPDCI(i,:);
   
   widthActive(i) = activePDCI(2)-activePDCI(1);
   widthPassive(i) = passivePDCI(2)-passivePDCI(1);
   
   difWidthS1(i) =widthPassive(i)-widthActive(i);
end

compiledTuningMetricsS1 =([dcMoveS1;dcBumpS1;modDepthMoveS1; modDepthBumpS1; difWidthS1; abs([S1CompiledPDsActive.velPD]'- [S1CompiledPDsPassive.velPD]')]');

[~, pcaS1] = pca(compiledTuningMetricsS1);
[~,pcaCuneate]= pca(compiledTuningMetricsCuneate);

figure
scatter3(pcaS1(:,1), pcaS1(:,2), pcaS1(:,3),'b')
hold on
scatter3(pcaCuneate(:,1), pcaCuneate(:,2), pcaCuneate(:,3), 'r')
xlabel('pca1')
ylabel('pca2')
zlabel('pca3')

compiledTuningMetrics = [compiledTuningMetricsS1;compiledTuningMetricsCuneate];
response = categorical([ones(length(compiledTuningMetricsS1(:,1)),1);zeros(length(compiledTuningMetricsCuneate(:,1)),1)]);

[B, dev, stats] =mnrfit(compiledTuningMetrics, response)

%%
close all
for i = 1:length(compiledTuningMetricsS1(1,:))
    figure
    histogram(compiledTuningMetricsCuneate(:,i));
    hold on
    histogram(compiledTuningMetricsS1(:,i));
    
end
%%
% 
% scatter3(compiledTuningMetricsCuneate(:,1), compiledTuningMetricsCuneate(:,2), compiledTuningMetricsCuneate(:,3), 'r')
% hold on
% scatter3(compiledTuningMetricsS1(:,1), compiledTuningMetricsS1(:,2), compiledTuningMetricsS1(:,3), 'b')
% 
% xlabel('Difference between average bump response vs. Avg Move response')
% ylabel('Difference between active and passive modulation depths')
% zlabel('Difference between PD Confidence intervals')
%%
clear cuneateCompiledProcessed
clear s1CompiledProcessed
load('CompiledFiles.mat')
cuneateCompiledProcessed(1) = processedTrial03202017(2).actPasStats;
cuneateCompiledProcessed(2) = processedTrial09032017(2).actPasStats;
cuneateCompiledProcessed(3) = processedTrial09172017(2).actPasStats;

s1CompiledProcessed(1) = processedTrial03202017(1).actPasStats;

inStruct.date = 'CombinedDates 03202017, 09032017, 09172017';
inStruct.array= cuneateCompiledProcessed(1).array;
inStruct.angBump = cat(2,cuneateCompiledProcessed.angBump);
inStruct.angMove = cat(2,cuneateCompiledProcessed.angMove);
inStruct.tuned = cat(2,cuneateCompiledProcessed.tuned);
inStruct.pasActDif = cat(2,cuneateCompiledProcessed.pasActDif);
inStruct.dcBump = cat(2, cuneateCompiledProcessed.dcBump);
inStruct.dcMove = cat(2,cuneateCompiledProcessed.dcMove);
inStruct.modDepthMove = cat(2,cuneateCompiledProcessed.modDepthMove);
inStruct.modDepthBump = cat(2, cuneateCompiledProcessed.modDepthBump);

coActPasPlotting(inStruct)

inStructS1.date = 'CombinedDates 03202017, 09032017, 09172017';
inStructS1.array= s1CompiledProcessed(1).array;
inStructS1.angBump = cat(2,s1CompiledProcessed.angBump);
inStructS1.angMove = cat(2,s1CompiledProcessed.angMove);
inStructS1.tuned = cat(2,s1CompiledProcessed.tuned);
inStructS1.pasActDif = cat(2,s1CompiledProcessed.pasActDif);
inStructS1.dcBump = cat(2, s1CompiledProcessed.dcBump);
inStructS1.dcMove = cat(2,s1CompiledProcessed.dcMove);
inStructS1.modDepthMove = cat(2,s1CompiledProcessed.modDepthMove);
inStructS1.modDepthBump = cat(2, s1CompiledProcessed.modDepthBump);
coActPasPlotting(inStructS1)
