clear all
close all
% load('Butter_03-26-2018_CObump_cuneate_idx_movement_on_idx_endTime_idx_bumpTime_idx_bumpTime_NeuronStruct.mat')
% neuronsAll = neurons;
% load('Butter_03-29-2018_CObump_cuneate_idx_movement_on_idx_endTime_idx_bumpTime_idx_bumpTime_NeuronStruct.mat')
% neuronsAll = [neuronsAll;neurons];
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Neurons\Butter_06-07-2018_CObump_cuneate_idx_movement_on_idx_endTime_idx_bumpTime_idx_bumpTime_NeuronStruct.mat')
% neuronsAll = [neuronsAll;neurons];
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Neurons\Lando_03-20-2017_CObump_RightCuneate_idx_movement_on_idx_endTime_idx_bumpTime_idx_bumpTime_NeuronStruct.mat')
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Neurons\Lando_03-20-2017_CObump_LeftS1_idx_movement_on_idx_endTime_idx_bumpTime_idx_bumpTime_NeuronStruct.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Neurons\Butter_03-26-2018_CObump_cuneate_idx_movement_on_idx_endTime_idx_bumpTime_idx_bumpTime_NeuronStructConservative.mat')

neuronsAll = neurons;
%%
for i = 1:height(neuronsAll)
    bumpFiring = mean([neuronsAll.firing(i).bump.right.all;neuronsAll.firing(i).bump.up.all;neuronsAll.firing(i).bump.left.all;neuronsAll.firing(i).bump.down.all], 2);
    moveFiring = mean([neuronsAll.firing(i).move.right.all;neuronsAll.firing(i).move.up.all;neuronsAll.firing(i).move.left.all;neuronsAll.firing(i).move.down.all],2);
    flagBump = [0* ones(length(neuronsAll.firing(i).bump.right.all(:,1)),1); 1* ones(length(neuronsAll.firing(i).bump.up.all(:,1)),1);2* ones(length(neuronsAll.firing(i).bump.left.all(:,1)),1);3* ones(length(neuronsAll.firing(i).bump.down.all(:,1)),1)];
    flagMove = [0* ones(length(neuronsAll.firing(i).move.right.all(:,1)),1); 1* ones(length(neuronsAll.firing(i).move.up.all(:,1)),1);2* ones(length(neuronsAll.firing(i).move.left.all(:,1)),1);3* ones(length(neuronsAll.firing(i).move.down.all(:,1)),1)];
    
    pBump(i) = anovan(bumpFiring, flagBump,'display','off');
    pMove(i) = anovan(moveFiring, flagMove,'display','off');
end
%%
neuronsAll.fTestBump = [pBump <.05]';
neuronsAll.fTestMove = [pMove <.05]';
neuronsAll.fTest = neuronsAll.fTestBump | neuronsAll.fTestMove;
params.useModDepths = true;
params.size1 = max([neuronsAll.modDepthMove, neuronsAll.modDepthBump]')';
params.tuningCondition = {'isSorted', 'isCuneate', 'fTest'};
neurons1 = neuronStructPlot(neuronsAll, params);