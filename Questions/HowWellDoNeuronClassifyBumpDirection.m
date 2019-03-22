clear all
close all
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')
numPCs = 5;
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getMoveOnsetAndPeak(td, params);
startTime = -150;
endTime = 150;
numCVFolds = 10;
td = smoothSignals(td, struct('signals', 'cuneate_spikes', 'causal', true,'kernel_SD', 0.01));
td = smoothSignals(td, struct('signals', 'pos', 'causal', true,'kernel_SD', 0.01));
td = smoothSignals(td, struct('signals', 'vel', 'causal', true,'kernel_SD', 0.01));
td = smoothSignals(td, struct('signals', 'acc', 'causal', true,'kernel_SD', 0.01));

td = binTD(td,5);

binWidth = td(1).bin_size*1000;
tdBump = td(~isnan([td.idx_bumpTime]));
tdMove = td(isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, {'idx_bumpTime', floor(startTime/binWidth)}, {'idx_bumpTime', floor(endTime/binWidth)});
tdMove = trimTD(tdMove, {'idx_movement_on', floor(startTime/binWidth)}, {'idx_movement_on', floor(endTime/binWidth)});
% tdMove = trimTD(tdMove, {'idx_tgtOnTime', floor(startTime/10)}, {'idx_tgtOnTime', floor(endTime/10)});

tdBump = dimReduce(tdBump, struct('signals', {{'cuneate_spikes', find(tdBump(1).cuneate_unit_guide(:,2)>0)}}));
tdMove = dimReduce(tdMove, struct('signals', {{'cuneate_spikes', find(tdMove(1).cuneate_unit_guide(:,2)>0)}}));

%%
spike = cat(3, tdMove.cuneate_pca);
dir = floor([tdMove.target_direction]'./(pi/2))+1;

for i = 1:length(spike(:,1,1))
    input = squeeze(spike(i,1:numPCs,:))';
%     input = reshape(input, numPCs*i, size(spike, 3));
    output = dir;
    [b{i}, dev{i}, stats{i}, acc(i,:)] = multinomialLogRegressionCV(input, output, numCVFolds);
    disp(['done with ', num2str(i), ' of ', num2str(length(input(:,1)))])
end

%%
kin = [cat(3, tdMove.pos), cat(3, tdMove.vel), cat(3, tdMove.acc)];
for i = 1:length(kin(:,1,1))
    input = squeeze(kin(i, :,:))';
    output = dir;
    [b{i}, dev{i}, stats{i}, accKin(i,:)] = multinomialLogRegressionCV(input, output, numCVFolds);
end
%%
randNum = normrnd(0, 1, size(kin,1), size(kin,2), size(kin,3));
for i = 1:length(kin(:,1,1))
    input = squeeze(randNum(i, :,:))';
    output = dir;
    [b{i}, dev{i}, stats{i}, accRand(i,:)] = multinomialLogRegressionCV(input, output, numCVFolds);

end

%% Bump classification
spike1 = cat(3, tdBump.cuneate_pca);
dir1 = floor([tdBump.bumpDir]'./90)+1;

for i = 1:length(spike1(:,1,1))
    input1 = squeeze(spike1(i,1:numPCs,:))';
    output1 = dir1;
    [b{i}, dev{i}, stats{i}, accBump(i,:)] = multinomialLogRegressionCV(input1, output1, numCVFolds);

end

%%
kinBump = [cat(3, tdBump.pos), cat(3, tdBump.vel), cat(3, tdBump.acc)];
dir1 = floor([tdBump.bumpDir]'./90)+1;

for i = 1:length(spike1(:,1,1))
    input = squeeze(kinBump(i, :,:))';
    output1 = dir1;
    [b{i}, dev{i}, stats{i}, accKinBump(i,:)] = multinomialLogRegressionCV(input, output1, numCVFolds);

end
%%
figure

accMean = mean(acc,2);
accBumpMean = mean(accBump,2);
accKinBumpMean = mean(accKinBump,2);
accKinMean = mean(accKin,2);
accRandMean = mean(accRand,2);

accStd = std(acc,[],2);
accBumpStd = std(accBump,[],2);
accKinBumpStd = std(accKinBump,[],2);
accKinStd = std(accKin,[],2);
accRandStd = std(accRand,[],2);

errorbar([startTime:binWidth:endTime] + normrnd(0, .5,1, length(accMean)), accMean, accStd)
hold on
errorbar([startTime:binWidth:endTime] + normrnd(0, .5,1, length(accMean)), accBumpMean, accBumpStd)
errorbar([startTime:binWidth:endTime] + normrnd(0, .5,1, length(accMean)), accKinBumpMean, accKinBumpStd)
errorbar([startTime:binWidth:endTime] + normrnd(0, .5,1, length(accMean)), accKinMean, accKinStd)
errorbar([startTime:binWidth:endTime] + normrnd(0, .5,1, length(accMean)), accRandMean, accRandStd)
ylabel('Percent of correctly labelled trials')
xlabel('Time into trial (ms)')
title('Direction Classification from 10 neural PCs')
set(gca,'TickDir','out', 'box', 'off')
xticks([-120,-80,-40,0,40,80,120])
% ylim([0,100])
legend('Move Predictions', 'Bump Predictions', 'Bump Kinematics Predictions', 'Kinematic predictions','Random Predictions')
