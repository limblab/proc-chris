% clear all
%clearvars -except cds td ex3
%load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 0;
params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
params.extra_time = [.4,.6];
td = parseFileByTrial(cds, params);
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';

td = td(~isnan([td.target_direction]));
td = getMoveOnsetAndPeak(td, params);

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
unitsToPlot = [19]; %Bump Tuned
% unitsToPlot = [3,4,5,7,8,9,10,11,12,13,14,16,17,18,19,42,21,22,23,24,28,29,31,36,38]; % MoveTuned
  numCount = 1:length(td1(1).cuneate_spikes(1,:));
% unitsToPlot = numCount;
numCount = unitsToPlot;
%% Data Preparation and sorting out trials
td1 = td;
bumpTrials = td1(~isnan([td1.bumpDir])); 
upMove = td1([td.target_direction] == pi/2 & isnan([td1.bumpDir]));
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
    downBumpPec(:,i) = downBump(i).opensim(downBump(i).idx_bumpTime:downBump(i).idx_bumpTime+10,muscleNum);
end

upBumpPec = zeros(11, length(upBump));
for i =1:length(upBump)
    upBumpPec(:,i) = upBump(i).opensim(upBump(i).idx_bumpTime:upBump(i).idx_bumpTime+10,muscleNum);
end

leftBumpPec = zeros(11, length(leftBump));
for i =1:length(leftBump)
    leftBumpPec(:,i) = leftBump(i).opensim(leftBump(i).idx_bumpTime:leftBump(i).idx_bumpTime+10,muscleNum);
end

rightBumpPec = zeros(11, length(rightBump));
for i =1:length(rightBump)
    rightBumpPec(:,i) = rightBump(i).opensim(rightBump(i).idx_bumpTime:rightBump(i).idx_bumpTime+10,muscleNum);
end

downMovePec = zeros(11, length(downMove));
for i = 1:length(downMovePec(1,:))
    downMovePec(:,i) = downMove(i).opensim(downMove(i).idx_movement_on:downMove(i).idx_movement_on+10,muscleNum);
end

upMovePec = zeros(11, length(upMove));
for i =1:length(upMovePec(1,:))
    upMovePec(:,i) = upMove(i).opensim(upMove(i).idx_movement_on:upMove(i).idx_movement_on+10,muscleNum);
end

leftMovePec = zeros(11, length(leftMove));
for i =1:length(leftMovePec(1,:))
    leftMovePec(:,i) = leftMove(i).opensim(leftMove(i).idx_movement_on:leftMove(i).idx_movement_on+10,muscleNum);
end

rightMovePec = zeros(11, length(rightMove));
for i =1:length(rightMovePec(1,:))
    rightMovePec(:,i) = rightMove(i).opensim(rightMove(i).idx_movement_on:rightMove(i).idx_movement_on+10,muscleNum);
end
%%
% pecMax = max(cds.analog{1,3}.pectoralis_sup_len(1:217544));
%close all
muscleNum =33;
timeVec = linspace(0, .1, length(upBumpPec(:,1)));
figure
subplot(3,3,2)
plot(timeVec,upBumpPec, 'r')
hold on
plot(timeVec, upMovePec, 'b')
xlim([0,.1])

xlim([0,.1])
subplot(3,3,4) 
plot(timeVec,leftBumpPec, 'r')
hold on
plot(timeVec, leftMovePec, 'b')
xlim([0,.1])

subplot(3,3,6)
plot(timeVec,rightBumpPec, 'r')
hold on
plot(timeVec, rightMovePec, 'b')
xlim([0,.1])

subplot(3,3,8)
plot(timeVec,downBumpPec, 'r')
hold on
plot(timeVec, downMovePec, 'b')
xlim([0,.1])
suptitle(strrep(td(1).opensim_names{muscleNum}, '_', ' '))
%%
figure 
timeVec = linspace(0, .1, length(upBumpPec(:,1)));
figure
subplot(3,3,2)
plot(timeVec,mean(upBumpPec,2), 'r')
hold on
plot(timeVec, mean(upMovePec,2), 'b')

xlim([0,.1])
subplot(3,3,4) 
plot(timeVec,mean(leftBumpPec,2), 'r')
hold on
plot(timeVec, mean(leftMovePec,2), 'b')
xlim([0,.1])

subplot(3,3,6)
plot(timeVec,mean(rightBumpPec,2), 'r')
hold on
plot(timeVec, mean(rightMovePec,2), 'b')
xlim([0,.1])

subplot(3,3,8)
plot(timeVec,mean(downBumpPec,2), 'r')
hold on
plot(timeVec, mean(downMovePec,2), 'b')
xlim([0,.1])
legend('show')
suptitle(strrep(td(1).opensim_names{muscleNum}, '_', ' '))


   %% Short time
startDownBump = downBumpPec(1,:);
startDownMove = downMovePec(1,:);

startUpBump = upBumpPec(1,:);
startUpMove = upMovePec(1,:);

startRightBump = rightBumpPec(1,:);
startRightMove = rightMovePec(1,:);

startLeftBump = leftBumpPec(1,:);
startLeftMove = leftMovePec(1,:);

endLeftBump = leftBumpPec(end,:);
endLeftMove = leftMovePec(end,:);

endRightBump = rightBumpPec(end,:);
endRightMove = rightMovePec(end,:);

endUpBump = upBumpPec(end,:);
endUpMove = upMovePec(end,:);

endDownBump = downBumpPec(end,:);
endDownMove = downMovePec(end,:);

difBumpLeft = endLeftBump - startLeftBump;
difBumpRight = endRightBump - startRightBump;
difBumpUp = endUpBump - startUpBump;
difBumpDown = endDownBump - startDownBump;

difMoveLeft = endLeftMove -  startLeftMove;
difMoveRight = endRightMove - startRightMove;
difMoveUp = endUpMove - startUpMove;
difMoveDown = endDownMove - startDownMove;

%%
close all
figure
histogram(difBumpLeft)
hold on
histogram(difMoveLeft)
legend('show')

figure
histogram(difBumpRight)
hold on
histogram(difMoveRight)
legend('show')

figure
histogram(difBumpUp)
hold on
histogram(difMoveUp)
legend('show')

figure
histogram(difBumpDown)
hold on
histogram(difMoveDown)
legend('show')