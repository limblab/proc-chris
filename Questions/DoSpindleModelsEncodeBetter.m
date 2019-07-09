clear all
close all
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Lando\20170917\TD\Lando_CO_20170917_001_TD_spindleModel.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180326\TD\Butter_CO_20180326_TD_001.mat')
array = 'cuneate';

td = removeBadNeurons(td, struct('remove_unsorted', true, 'min_fr',.01));
td = getNorm(td,struct('signals','vel','norm_name','speed'));

td = getMoveOnsetAndPeak(td, struct('start_idx', 'idx_goCueTime', 'end_idx', 'idx_endTime'));
[~, td] = getTDidx(td, 'result', 'R');
% td = td(~isnan([td.idx_bumpTime]));
% td = trimTD(td, 'idx_bumpTime',{'idx_bumpTime', 12});
td = trimTD(td, 'idx_movement_on', 'idx_endTime');
td = smoothSignals(td, struct('signals', 'cuneate_spikes'));

td = removeBadOpensim(td);


td = binTD(td, 10);

td = dupeAndShift(td, 'opensim', 4);
% td = dupeAndShift(td, 'spindleFR', 7);
%%
for i = 1:5
disp( ['Working on CV fold ', num2str(i)])
trainInds = randperm(length(td), floor(.9*length(td)));
tdTrain = td(trainInds);
tdTest = td(setdiff(1:length(td), trainInds));
%%

    spikes = [array, '_spikes'];
    params.model_type = 'glm';
    params.num_boots = 0;
    params.eval_metric = 'pr2';
    % params.glm_distribution
    disp('Full model')
    params.in_signals= {'pos';'vel';'speed';'acc'};
    params.model_name = 'Full';
    params.out_signals = {spikes};
    [tdTrain, model1] = getModel(tdTrain, params);
    [tdTest, model1T] = getModel(tdTest, model1);
    fullPR2(:,i) = squeeze(evalModel(tdTest, params));

    disp('Joint model')
    params.in_signals = {'opensim', 1:14};
    params.model_name = 'Joints';
    [tdTrain, model2] = getModel(tdTrain, params);
    [tdTest, model2T] = getModel(tdTest, model2);
    jointPR2(:,i) = squeeze(evalModel(tdTest,params));

    disp('Muscle model')
    params.in_signals = {'opensim', 15:92};
    params.model_name = 'Muscles';
    [tdTrain, model3] = getModel(tdTrain, params);
    [tdTest, model3T] = getModel(tdTest, model3);
    musclePR2(:,i) = squeeze(evalModel(tdTest, params));
% 
%     params.in_signals = {'spindleFR'};
%     params.model_name = 'Spindle';
%     [tdTrain, model4] = getModel(tdTrain, params);
%     [tdTest, model4T] = getModel(tdTest, model4);
%     spindlePR2(:,i) = squeeze(evalModel(tdTest, params));

    disp('Muscle Future model')

    params.in_signals = {'opensim_shift', 15:92};
    params.model_name = 'muscleFuture';
    [tdTrain, model5] = getModel(tdTrain, params);
    [tdTest, model5T] = getModel(tdTest, model5);
    futureMusPR2(:,i) = squeeze(evalModel(tdTest, params));
% 
%     params.in_signals = {'spindleFR_shift'};
%     params.model_name = 'spindleFuture';
%     [tdTrain, model6] = getModel(tdTrain, params);
%     [tdTest, model6T] = getModel(tdTest, model6);
%     futureSpindlePR2(:,i) = squeeze(evalModel(tdTest, params));
end
%%
fullPR21 = mean(fullPR2')';
jointPR21 = mean(jointPR2')';
musclePR21 = mean(musclePR2')';
futureMusPR21 = mean(futureMusPR2')';
% spindlePR21 = mean(spindlePR2')';
data = [fullPR21, jointPR21, musclePR21];
figure
bar(data)
%%

tablePR2 = table(td(1).cuneate_unit_guide, fullPR21, jointPR21, musclePR21, futureMusPR21, 'VariableNames', {'UnitGuide', 'Endpoint', 'Joint', 'Muscle', 'FutureMuscle'});
scatter(musclePR2, futureMusPR2)
hold on
% scatter(spindlePR2, futureSpindlePR2)
plot([0,1],[0,1])
