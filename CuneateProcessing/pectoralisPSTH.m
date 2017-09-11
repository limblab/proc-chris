% clear all
%clearvars -except cds td ex3
%load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 0;
params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
params.extra_time = [.4,.6];
td = parseFileByTrial(cds, params);
td = getMoveOnsetAndPeak(td);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
trialCds = cds.trials([cds.trials.result] =='R', :);
startTimes = trialCds.startTime;
w = gausswin(5);
for i = 1:length(td)
    td(i).StartTime = startTimes(i);
end
td1 = td([td.StartTime] <2174);
unitsToPlot = [19]; %Bump Tuned
% unitsToPlot = [3,4,5,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,28,29,31,36,38]; % MoveTuned
  numCount = 1:length(td1(1).RightCuneate_spikes(1,:));
% unitsToPlot = numCount;
numCount = unitsToPlot;
%% Data Preparation and sorting out trials

bumpTrials = td1(~isnan([td1.bumpDir])); 
upMove = td1([td1.target_direction] == pi/2 & isnan([td1.bumpDir]));
leftMove = td1([td1.target_direction] ==pi& isnan([td1.bumpDir]));
downMove = td1([td1.target_direction] ==3*pi/2& isnan([td1.bumpDir]));
rightMove = td1([td1.target_direction]==0& isnan([td1.bumpDir]));

    %% Up Active
upBump = bumpTrials([bumpTrials.bumpDir] == 90);
downBump = bumpTrials([bumpTrials.bumpDir] == 270);
leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
rightBump = bumpTrials([bumpTrials.bumpDir] == 0);

%% 
downBumpPec = zeros(11, length(downBump));
for i = 1:length(downBump)
    downBumpPec(:,i) = downBump(i).opensim(downBump(i).idx_bumpTime:downBump(i).idx_bumpTime+10,28);
end

upBumpPec = zeros(11, length(upBump));
for i =1:length(upBump)
    upBumpPec(:,i) = upBump(i).opensim(upBump(i).idx_bumpTime:upBump(i).idx_bumpTime+10,28);
end

leftBumpPec = zeros(11, length(leftBump));
for i =1:length(leftBump)
    leftBumpPec(:,i) = leftBump(i).opensim(leftBump(i).idx_bumpTime:leftBump(i).idx_bumpTime+10,28);
end

rightBumpPec = zeros(11, length(rightBump));
for i =1:length(rightBump)
    rightBumpPec(:,i) = rightBump(i).opensim(rightBump(i).idx_bumpTime:rightBump(i).idx_bumpTime+10,28);
end

downMovePec = zeros(11, length(downMove));
for i = 1:length(downMove)
    downMovePec(:,i) = downMove(i).opensim(downMove(i).idx_movement_on:downMove(i).idx_movement_on+10,28);
end

upMovePec = zeros(11, length(upMove));
for i =1:length(upMove)
    upMovePec(:,i) = upMove(i).opensim(upMove(i).idx_movement_on:upMove(i).idx_movement_on+10,28);
end

leftMovePec = zeros(11, length(leftMove));
for i =1:length(leftBump)
    leftMovePec(:,i) = leftMove(i).opensim(leftMove(i).idx_movement_on:leftMove(i).idx_movement_on+10,28);
end

rightMovePec = zeros(11, length(rightMove));
for i =1:length(rightBump)
    rightMovePec(:,i) = rightMove(i).opensim(rightMove(i).idx_movement_on:rightMove(i).idx_movement_on+10,28);
end
%%
close all
timeVec = linspace(0, .1, length(upBumpPec(:,1)));
figure
subplot(3,3,2)
plot(timeVec,upBumpPec)
yyaxis right
plot(timeVec, mean(upBumpFiring(10:21,:),2))


xlim([0,.1])
subplot(3,3,4) 
plot(timeVec,leftBumpPec)
yyaxis right
plot(timeVec, mean(leftBumpFiring(10:21,:),2))
xlim([0,.1])

subplot(3,3,6)
plot(timeVec,rightBumpPec)
yyaxis right
plot(timeVec, mean(rightBumpFiring(10:21,:),2))
xlim([0,.1])

subplot(3,3,8)
plot(timeVec,downBumpPec)
yyaxis right
plot(timeVec, mean(downBumpFiring(10:21,:),2))
xlim([0,.1])
suptitle('Pectoralis Kinematics vs. Firing Rate')


timeVec = linspace(0, .1, length(upMovePec(:,1)'));
figure
subplot(3,3,2)
plot(timeVec,upMovePec)
yyaxis right
plot(timeVec, mean(upMoveFiring(10:21,:),2))


xlim([0,.1])
subplot(3,3,4) 
plot(timeVec,leftMovePec)
yyaxis right
plot(timeVec, mean(leftMoveFiring(10:21,:),2))
xlim([0,.1])

subplot(3,3,6)
plot(timeVec,rightMovePec)
yyaxis right
plot(timeVec, mean(rightMoveFiring(10:21,:),2))
xlim([0,.1])

subplot(3,3,8)
plot(timeVec,downMovePec)
yyaxis right
plot(timeVec, mean(downMoveFiring(10:21,:),2))
xlim([0,.1])
suptitle('Pectoralis Kinematics vs. Firing Rate')

   %% Short time
