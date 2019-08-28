%% Load all files for comparison
clearvars -except tdStart
% monkey = 'Lando';
% date = '20170223';
% array = 'LeftS1';
% task = 'RW';
% params.doCuneate = false;
% 
crList =  [1 2 1 2; ...
           2 1 2 1;...
           3 1 3 1;...
           11 1 11 1; ...
           12 1 12 1;...
           14 1 14 1; ...
           16 1 16 1;...
           17 1 17 1;...
           18 1 18 1;...
           18 2 18 3;...
           20 1 20 1; ...
           20 2 20 2; ...
           22 1 22 1; ...
           22 2 22 2; ...
           23 1 23 1; ...
           24 2 24 2; ...
           24 3 24 3; ...
           27 1 27 1; ...
           27 2 27 2; ...
           33 1 33 1; ...
           36 1 36 1; ...
           38 1 38 1; ...
           40 1 40 1; ...
           41 1 41 1;...
           42 1 42 1; ...
           45 1 45 1; ...
           50 1 50 1; ...
           62 1 62 1; ...
           67 1 67 1; ...
           72 1 72 2; ...
           74 1 74 1;...
           76 1 76 1];
monkey = 'Snap';
date = '20190823';
array = 'cuneate';
task = 'CO';
params.doCuneate = true;

mappingLog = getSensoryMappings(monkey);
if ~exist('tdStart')
    tdStart =getTD(monkey, date, task,1);
    tdStart = tdToBinSize(tdStart, 10);
end
tdButter = smoothSignals(tdStart, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .05));

tdButter = getNorm(tdButter,struct('signals','vel','norm_name','speed'));
tdButter = getSpeed(tdButter);

tdButter = getMoveOnsetAndPeak(tdButter);
% getGracile
% tdButter = smoothSignals(tdButter, struct('signals', 'cuneate_spikes'));

%% Preprocess them (binning, trimming etc)
param.min_fr = 1;
% tdButter= removeBadNeurons(tdButter, param);
tdButter = removeUnsorted(tdButter);
tdButter = tdButter(getTDidx(tdButter, 'result','R'));   
% tdButter = getRWMovements(tdButter);


% tdButter= removeBadTrials(tdButter);
tdButter = tdButter(~isnan([tdButter.idx_movement_on]));
tdButter = tdToBinSize(tdButter, 10);
tdButter = trimTD(tdButter, {'idx_movement_on',-30}, {'idx_movement_on', 60});
% tdButter= removeBadTrials(tdButter);
% tdButter(isnan([tdButter.idx_endTime])) =[];
tdButter([tdButter.idx_endTime] ==1) = [];
butterNaming = tdButter.([array, '_unit_guide']);
sortedFlag = butterNaming(:,2) ~= 0;
[tdButter, cunFlag] = getTDCuneate(tdButter);

tdButter = rectifyTDSignal(tdButter, struct('signals', 'vel'));
tdButter = rectifyTDSignal(tdButter, struct('signals', 'vel','rect_type', 'hw'));

%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';
% params.glm_distribution
varsToUse = {{'pos';'vel';'acc';'speed';'force'}, ...
             {'vel';'acc';'speed'; 'force'},...
             {'pos';'speed';'acc'; 'force'},...
             {'pos';'vel';'speed';'force'},...
             {'pos';'vel';'acc';'speed'},...
             {'pos';'vel';'acc'; 'force'},...
             {'pos'},...
             {'vel'},...
             {'vel_hw'},...
             {'vel_fw'},...
             {'acc'},...
             {'force'},...
             {'speed'},...
             {'speed';'vel'},...
             {'pos';'vel';'acc';'vel_fw'; 'force'}};
               
     %%     
 guide = tdButter(1).cuneate_unit_guide;
     
for i = 1:length(varsToUse)
    disp(['Working on  ' strjoin(varsToUse{i})])
    params.in_signals= varsToUse{i};
    params.model_name = strjoin(varsToUse{i}, '_');
    modelNames{i} = strjoin(varsToUse{i}, '_');
    params.out_signals = {spikes};
    tdButter= getModel(tdButter, params);
    pr2(i,:) = squeeze(evalModel(tdButter, params));
end
%%
T = array2table(pr2',...
    'VariableNames',modelNames);
t2 = table(guide(:,1), guide(:,2), 'VariableNames', {'Elec', 'Unit'});

encTable = [t2, T];
mkdir([getPathFromTD(tdButter),filesep, 'NeuronStruct', filesep, 'Encoding',filesep])
save([getPathFromTD(tdButter), 'NeuronStruct', filesep, 'Encoding',filesep,'EncodingModelsPR2', monkey, '_', date, '.mat'], 'encTable')
    
%%
%% Compute the relative R2 between the combined speed velocity model and the model with just one or the other.
% the removal which causes the model to suffer 
params.model_name = {'speed', 'speed_vel'};
relSpeedR2 = evalModel(tdButter, params);
params.model_name = {'vel', 'speed_vel'};
relVelR2 = evalModel(tdButter, params);

figure;h = histogram(relSpeedR2,20);hold on;edges = h.BinEdges; histogram(relVelR2,edges);legend({'AddingVelocity', 'AddingSpeed'});ylabel('# of neurons');xlabel('RelativeR2');
title([monkey, ' ', array, ' Relative R2 gained by adding other model parameter'])

% This plot shows that the Vel model gains more from the addition of speed
% than the speed model does from the addition of velocity.
%% Plotting R2s to inspect how they look

figure
scatter(encTable.vel_fw, encTable.vel)
hold on
xlim([0, .8])
ylim([0,.8])
title([monkey, ' ', array, ' R2 for rectified vel vs velocity'])
xlabel('Rect Vel R2')
ylabel('Vel R2')
set(gca,'TickDir','out', 'box', 'off')

%%
Full = encTable.pos_vel_acc_speed_force;
Pos = encTable.pos;
Vel = encTable.vel;
Speed = encTable.speed;
VelSpeed= encTable.speed_vel;
Acc = encTable.acc;

figure
subplot(6,1,1)
histogram(Full,0:.05:1.0)
meanFull = sum(Full)/length(Full);
hold on
title('Full')
xlim([0, 1])
ylim([0,30])
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
scatter(meanFull, 20, '*r')

subplot(6,1,2)
histogram(Pos,0:.05:1.0)
meanPos = mean(Pos);
hold on
title('Position')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
xlim([0, 1])
ylim([0,30])
scatter(meanPos, 20, '*r')


subplot(6,1,3)
histogram(Vel,0:.05:1.0)
meanVel = mean(Vel);
hold on
title('Velocity')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
xlim([0, 1])
ylim([0,30])
scatter(meanVel, 20, '*r')

subplot(6,1,4)
histogram(Speed,0:.05:1.0)
meanSpeed = mean(Speed);
hold on
title('Speed')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [])
xlim([0, 1])
ylim([0,30])
scatter(meanSpeed, 20, '*r')

subplot(6,1,5)
histogram(VelSpeed,0:.05:1.0)
meanVelSpeed = mean(VelSpeed);
hold on
title('VelSpeed')
set(gca,'TickDir','out', 'box', 'off')
suptitle('R2 of Encoding Models')
xlabel('Pseudo R2')
ylabel('# of neurons')
xlim([0, 1])
ylim([0,30])
scatter(meanVelSpeed, 20, '*r')


subplot(6,1,6)
histogram(Acc,0:.05:1.0)
meanAcc = mean(Acc);
hold on
title('Accel')
set(gca,'TickDir','out', 'box', 'off')
suptitle('R2 of Encoding Models')
xlabel('Pseudo R2')
ylabel('# of neurons')
xlim([0, 1])
ylim([0,30])
scatter(meanAcc, 20, '*r')
%%
dirsM = unique([tdButter.target_direction]);
dirsM(isnan(dirsM)) = [];
for i = 1:length(varsToUse)
    
    for j = 1:length(dirsM)
%         keyboard
        predFiring = cat(3, tdButter([tdButter.target_direction] == dirsM(j))...
            .(['glm_',strjoin(varsToUse{i}, '_')]));
        meanFiring(:,j,:) = mean(predFiring, 3);
        actFiring = cat(3, tdButter([tdButter.target_direction] == dirsM(j))...
            .cuneate_spikes);
        meanActFiring(:,j,:) = mean(actFiring,3);
    end
    
%     for k = 1:length(crList(:,1))
%         close all
%         ind2 = find(guide(:,1) == crList(k,3) &...
%         guide(:,2) == crList(k,4));
%         
%         guideCR(k,:) = [guide(ind2,1), guide(ind2,2)];
%         f1 = figure('visible','off');
%         for j = 1:length(dirsM)
%             switch dirsM(j)
%                 case 0
%                     subplot(3,3,6)
%                 case pi/2
%                     subplot(3,3,2)
%                 case pi
%                     subplot(3,3, 4)
%                 case 3*pi/2
%                     subplot(3,3, 8)
%             end
%             plot(meanFiring(:,j,ind2))
%             hold on
%             plot(meanActFiring(:,j,ind2))
%             
%         end
%         subplot(3,3,9)
%         plot([0,1],[0,1])
%         hold on
%         plot([0,1], [1,0])
%         legend('Predicted', 'Actual')
%         suptitle1(['Electrode ', num2str(guide(ind2,1)), ' Unit ', num2str(guide(ind2,2)) ' Model ', strjoin(varsToUse{i}, ' ')])
% %         keyboard
%         mkdir([getPathFromTD(tdButter), 'plotting' , filesep,'SimPSTH',filesep, strjoin(varsToUse{i}, '_'), filesep]);
%         saveas(f1, [getPathFromTD(tdButter), 'plotting' , filesep,'SimPSTH',filesep,strjoin(varsToUse{i}, '_'),filesep, 'GLMSimulatedPSTHElectrode ', num2str(guide(ind2,1)), ' Unit ', num2str(guide(ind2,2)) ' Model ', strjoin(varsToUse{i}, '_'), '.png'])
%     end
end
%%
% close all
vec = 1:length(sortedFlag);
plotParams.array = 'LeftS1';
% for i = vec(sortedFlag)
%     plotParams.outputNum = i;
%     plotTDModelFits(tdButter, plotParams);
% end
% Moral of the story: Encoding models don't fit super well typically, but
% removing speed from the joint model hurts the prediction more than
% removing velocity (eg. the neurons care more about speed than the
% direction)
% Second moral of the story: Rectified velocity does a pretty good job on a
% lot of the units (about half) better than the non-rectified velocity.
% This is interesting and corresponds to my PSTH analysis.
%%