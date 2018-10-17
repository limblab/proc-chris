% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170511\TD\Lando_RW_20170511_TD.mat')
% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170511\Lando_RW_20170511_2_CDS.mat')
close all
clearvars -except cds
%load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 0;
params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
params.extra_time = [.4,.6];
td = parseFileByTrial(cds, params);
td = td(~isnan([td.target_direction]));
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getMoveOnsetAndPeak(td, params);

td = binTD(td, 10);
cuneateSpikes = cat(1, td.cuneate_spikes);
s1Spikes = cat(1, td.area2_spikes);
bothSpikes = [cuneateSpikes, s1Spikes];

motionTrack = cat(1, td.opensim);

handlePos = cat(1, td.pos);
handleVel = cat(1, td.vel);
handleAcc = cat(1,td.acc);

muscleCols = 15:53;
dofCols = 1:7;
muscleNames1 = td.opensim_names;
muscleNames = muscleNames1(15:53);

muscles = [motionTrack(:, muscleCols), gradient(motionTrack(:, muscleCols)',.05)'];
dofs = [motionTrack(:, dofCols), gradient(motionTrack(:,dofCols), .05)];
goodTimeCount = ones(length(findGoodTime(muscles(:,1))),1);
for i = 1:length(muscles(1,1:39))
    goodTimeCount = goodTimeCount + findGoodTime(muscles(:,i));
end
%%
goodTimeTrack = goodTimeCount >20;
goodSpeed = sqrt(sum(abs(handleVel).^2,2))>3;

goodTime = goodSpeed & goodTimeTrack;

%goodTime = goodSpeed;
emgTable = cat(1, td.emg);

goodVel = handleVel(goodTime,:);
goodMuscles = muscles(goodTime,:);
goodDoFs = dofs(goodTime,:);
goodPos = handlePos(goodTime,:);
goodAcc = handleAcc(goodTime,:);
goodEMG = emgTable(goodTime, :);
goodCuneate = cuneateSpikes(goodTime,:);
goodS1 = s1Spikes(goodTime,:);
speed = sqrt(sum(abs(goodVel).^2,2));

%fitlm([goodMuscles(:, 28),goodMuscles(:,28+39), goodEMG(:,19), goodEMG(:,19).*goodMuscles(:,28+39)], goodCuneate(:,2))
%%
close all
for j = 1:length(goodCuneate(1,:))
    for i = 1:39
        mdl1{i} = fitglm([goodMuscles(:, i),goodMuscles(:,i+39)], goodCuneate(:,j));
        r2(i,j) = mdl1{i}.Rsquared.Adjusted;
        disp(['Electrode', num2str(i), ' Muscle ', num2str(j)]) 
    end
    [~, ind(j)] = max(r2(:,j));
end

% 
%%
% for i =1 :length(goodMuscles(1,:))
%     hasanMuscles = goodMuscles(:,i) - max(goodMuscles(:,i));
% end
% hasanMuscles = goodMuscles;

%%
% for i = 1
%     [ t,mu,dmudt,spindleOut(:,i)] = runHasan(goodMuscles(:,i),goodMuscles(:,i+39), 1);
%     disp(num2str(i))
% end
% path1='C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170511\';
% fileN = [path1, 'Lando_20170511_CompiledMeters'];
% save(fileN, 'spindleOut', 'goodVel', 'goodMuscles', 'goodDoFs', 'goodPos', 'goodAcc', 'goodCuneate', 'goodS1');
%%
% close all
% for i = 1:length(goodCuneate(1,:))
%     figure
%     scatter(spindleOut(:,1), goodCuneate(:,i))
% end

%%
close all
% for i = 1:length(muscles(1,1:39))
%     figure
%     plot(findGoodTime(muscles(:,i)))
%     hold on
% end

%%
% [fit1, dev, stats] = glmfit(goodCuneate, goodVel(:,1), 'poisson');
% [fit2, dev, stats] = glmfit(goodCuneate, goodVel(:,2), 'poisson');
% yfit1 = glmval(fit1, goodCuneate, 'log');
% yfit2 = glmval(fit2, goodCuneate, 'log');
% figure
% plot(yfit1)
% hold on
% plot(goodVel(:,1),'r')
% figure
% plot(yfit2)
% hold on
% plot(goodVel(:,2),'r')