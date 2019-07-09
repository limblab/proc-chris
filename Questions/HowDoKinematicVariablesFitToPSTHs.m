%% Basic parameter setup
close all
clearvars -except td1Start td2Start
plotFigs = true;
%% File parameters
date = '20180530';
monkey = 'Butter';
unitNames= 'cuneate';
%% Load the TDs (if they haven't yet been loaded) and do the time-intensive processing
if ~exist('td1Start') | ~exist('td2Start')
    td1Start =getTD(monkey, date, 'COmoveBump',1);
    td2Start = getTD(monkey, '20180607','CO',1);
    % Add a speed term
    td1Start = getNorm(td1Start,struct('signals','vel','field_extra','speed')); 
    td2Start = getNorm(td2Start,struct('signals','vel','field_extra','speed'));
    % bin to 10 ms
    td1Start = tdToBinSize(td1Start, 10);
    td2Start = tdToBinSize(td2Start,10);
    td1Start= removeUnsorted(td1Start);
    td2Start= removeUnsorted(td2Start);
end
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
%%

td1 = smoothSignals(td1Start, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .01));
td2 = smoothSignals(td2Start, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .01));

% Getting move onset
td2 = getMoveOnsetAndPeak(td2);
td1 = getMoveOnsetAndPeak(td1);

disp('Trimming Files')
preMove1 = trimTD(td1, {'idx_goCueTime', -10}, {'idx_goCueTime', -5}); %Premovement
scaleMove = td1(isnan([td1.bumpDir]));
% Get the reach direction PSTH plots for both files
noBumpAct1 = trimTD(scaleMove, {'idx_goCueTime', 50}, {'idx_goCueTime', 63});
psthTD1 = trimTD(scaleMove, {'idx_movement_on', 0}, {'idx_movement_on',60});
psthTD2 = trimTD(td2, {'idx_movement_on', -30}, {'idx_movement_on',60});
td1 = trimTD(td1, {'idx_goCueTime', 50}, {'idx_goCueTime', 63}); % Bump

dirsM = unique([td2.target_direction]);
dirsB = unique([td2.bumpDir]);
dirsM = dirsM(~isnan(dirsM));
dirsB = dirsB(~isnan(dirsB));

guide = td2(1).cuneate_unit_guide;
%%
psth = [];
vel = [];
pos = [];
acc= [];
force = [];
for j = 1:length(dirsM)
    td2Dir{j} = psthTD2([psthTD2.target_direction] == dirsM(j));
    
    firing = cat(3, td2Dir{j}.cuneate_spikes);
    psth = [psth; squeeze(mean(firing, 3))];
    velAll = cat(3, td2Dir{j}.vel);
    vel = [vel; squeeze(mean(velAll, 3))];
    posAll = cat(3, td2Dir{j}.pos);
    pos = [pos; squeeze(mean(posAll, 3))];
    accAll = cat(3, td2Dir{j}.acc);
    acc=  [acc; squeeze(mean(accAll, 3))];
    forceAll = cat(3,td2Dir{j}.force);
    force = [force; squeeze(mean(forceAll, 3))];
    
end

velAbs = abs(vel);
vel_hw = vel;
vel_hw(vel_hw <0) = 0;
accAbs = abs(acc);

forceAbs = abs(force);
speed = rownorm(vel)';

combos = {[pos, vel, acc,speed, force],...
          [vel, acc, speed, force],...
          [pos, speed, acc, force]...
          [pos, vel, speed, force],...
          [pos, vel, acc, speed],...
          [pos, vel, acc, force], ...
          [pos], ...
          [vel],...
          [vel_hw],...
          [velAbs],...
          [acc],...
          [force],...
          [speed],...
          [speed, vel]};
      
comboNames = {{'pos' 'vel' 'acc' 'speed' 'force'},...
             {'vel' 'acc', 'speed', 'force'},...
             {'pos', 'speed', 'acc', 'force'},...
             {'pos', 'vel', 'speed', 'force'},...
             {'pos','vel', 'acc', 'speed'}, ...
             {'pos','vel', 'acc', 'force'}, ...
             {'pos'},...
             {'vel'},...
             {'vel_hw'},...
             {'vel_fw'},...
             {'acc'},...
             {'force'},...
             {'speed'},...
             {'speed', 'vel'}};
          
for mdlNum = 1:length(combos)
    close all
for i = 1:length(crList(:,1))
%     close all
    ind2 = find(guide(:,1) == crList(i,3) &...
        guide(:,2) == crList(i,4));
    guideCR(i,:) = [guide(ind2,1), guide(ind2,2)];
    combo = combos{mdlNum};
    lm1 = fitlm(combo, psth(:,ind2));
    r2(i) = lm1.Rsquared.Adjusted;
    psthPred1 = predict(lm1, combo);
    psthPred(:,i,:) = reshape(psthPred1, [], 4);
    psthAct(:,i,:) = reshape(psth(:,ind2), [], 4);
    if plotFigs
    figure
    max1 = max([max(max(psthPred(:,i,:))),max(max(psthAct(:,i,:)))]);
    subplot(3,3,7)
    tx = text(0, 0, ['R2 = ', num2str(r2(i))]);
    extent = tx.Extent;
    xlim([extent(1), extent(1) + extent(3)])
    ylim([extent(2), extent(2) + extent(4)])
    set(gca,'ycolor','w')
    set(gca,'xcolor','w')
    for j = 1:4

        switch j
            case 1
                subplot(3,3,6)
            case 2
                subplot(3,3,2)
            case 3
                subplot(3,3,4)
            case 4
                subplot(3,3,8)
        end
        
        plot(psthPred(:,i,j))
        hold on
        plot(psthAct(:,i,j))
        xlim([0, length(psthPred(:,1,1))])
        ylim([0, max1+5])
    end
    subplot(3,3,9)
    plot([0,1], [1,1])
    hold on
    plot([0,1], [0,0])
    legend('Predicted', 'Actual')
    suptitle(['Electrode: ', num2str(guide(ind2,1)),' Unit ', num2str(guide(ind2,2))])
    pause
    end
end
r2All(mdlNum,:) = r2;
r2(isnan(r2)) = [];
figure
histogram(r2)
title(strjoin(comboNames{mdlNum}, '_'))
mdlName{mdlNum} = strjoin(comboNames{mdlNum},'_');
meanR2(mdlNum) = mean(r2);
xlim([0,1])
end
%%
T = array2table(r2All',...
    'VariableNames',mdlName);
t2 = table(guideCR(:,1), guideCR(:,2), 'VariableNames', {'Elec', 'Unit'});

psthTable = [t2, T];

mkdir([getPathFromTD(td2),filesep, 'NeuronStruct', filesep, 'Encoding',filesep])
save([getPathFromTD(td2), 'NeuronStruct', filesep, 'Encoding',filesep,'PSTHFitTable', monkey, '_20180607.mat'], 'psthTable')
  %%
figure
scatter(r2All(2,:), r2All(1,:))
hold on
plot([0,1], [0,1])
xlabel(comboNames{2})
ylabel(comboNames{1})
