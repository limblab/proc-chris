function neurons = fitCOBumpPSTH(td,neurons, params)
plotFigs = false;
array = 'cuneate';
windowEncPSTH = {'idx_movement_on', -30;'idx_movement_on', 50};

%% File parameters
if nargin > 2, assignParams(who,params); end % overwrite parameters
spikeLbl = [array, '_spikes'];
unitLbl = [array, '_unit_guide'];
%%
td = trimTD(td, windowEncPSTH(1,:), windowEncPSTH(2,:));
td2 = smoothSignals(td, struct('signals', spikeLbl, 'calc_rate',true, 'width', .01));

dirsM = unique([td2.target_direction]);
dirsB = unique([td2.bumpDir]);
dirsM = dirsM(~isnan(dirsM));
dirsB = dirsB(~isnan(dirsB));

guide = td2(1).(unitLbl);
%%
psth = [];
vel = [];
pos = [];
acc= [];
force = [];
for j = 1:length(dirsM)
    td2Dir{j} = td2([td2.target_direction] == dirsM(j));
    
    firing = cat(3, td2Dir{j}.(spikeLbl));
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
    
    for i = 1:height(neurons)
        guideCR(i,:) = [guide(i,1), guide(i,2)];
        combo = combos{mdlNum};
        lm1 = fitlm(combo, psth(:,i));
        r2(i) = lm1.Rsquared.Adjusted;
        psthAll{i,mdlNum} = {reshape(psth(:,i), [], length(dirsM))};
    end
    r2All(mdlNum,:) = r2;
    title(strjoin(comboNames{mdlNum}, '_'))
    mdlName{mdlNum} = strjoin(comboNames{mdlNum},'_');
    meanR2(mdlNum) = mean(r2);
end
%%

T = array2table(r2All',...
    'VariableNames',mdlName);
T2 = cell2table(psthAll, ...
    'VariableNames', mdlName);

for i =1:height(neurons)
    neurons.psth(i)  = {T2(i,:)};
end
neurons.psthR2 = T;
end
