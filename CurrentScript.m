load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170511\TD\Lando_RW_20170511_TD.mat')
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170511\Lando_RW_20170511_2_CDS.mat')
td = binTD(td, 5);

cuneateSpikes = cat(1, td.RightCuneate_spikes);
s1Spikes = cat(1, td.LeftS1_spikes);
bothSpikes = [cuneateSpikes, s1Spikes];

motionTrack = cat(1, td.opensim);

handlePos = cat(1, td.pos);
handleVel = cat(1, td.vel);
handleAcc = cat(1,td.acc);

muscleCols = 1:39;
dofCols = 40:46;

muscles = [motionTrack(:, muscleCols), gradient(motionTrack(:, muscleCols)',.05)'];
dofs = [motionTrack(:, dofCols), gradient(motionTrack(:,dofCols), .05)];
goodTimeCount = ones(length(findGoodTime(muscles(:,1))),1);
for i = 1:length(muscles(1,1:39))
    goodTimeCount = goodTimeCount + findGoodTime(muscles(:,i));
end
goodTimeTrack = goodTimeCount >20;
goodSpeed = sqrt(sum(abs(handleVel).^2,2))>1;

goodTime = goodSpeed & goodTimeTrack;

goodVel = handleVel(goodTime,:);
goodMuscles = muscles(goodTime,:);
goodDoFs = dofs(goodTime,:);
goodPos = handlePos(goodTime,:);
goodAcc = handleAcc(goodTime,:);
goodCuneate = cuneateSpikes(goodTime,:);
goodS1 = s1Spikes(goodTime,:);
speed = sqrt(sum(abs(goodVel).^2,2));

for i =1 :length(goodMuscles(1,:))
    hasanMuscles = goodMuscles(:,i) - max(goodMuscles(:,i));
end
hasanMuscles = goodMuscles;

%%
for i = 1
    [ t,mu,dmudt,spindleOut(:,i)] = runHasan(goodMuscles(:,i),goodMuscles(:,i+39), 1);
    disp(num2str(i))
end
path1='C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170511\';
fileN = [path1, 'Lando_20170511_CompiledMeters'];
save(fileN, 'spindleOut', 'goodVel', 'goodMuscles', 'goodDoFs', 'goodPos', 'goodAcc', 'goodCuneate', 'goodS1');
%%
close all
for i = 1:length(goodCuneate(1,:))
    figure
    scatter(spindleOut(:,1), goodCuneate(:,i))
end

%%
close all
for i = 1:length(muscles(1,1:39))
    figure
    plot(findGoodTime(muscles(:,i)))
    hold on
end