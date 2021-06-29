function neurons = doChangepointDelta(neurons,td)

%% Preparation of parameters
plotEx = true;
plotExBump = false;
windowPre ={'idx_movement_on_min', -15; 'idx_movement_on_min',-10};
windowPreBump = {'idx_bumpTime', -10; 'idx_bumpTime', -5};
windowAct= {'idx_movement_on_min', -15; 'idx_movement_on_min',20}; %Default trimming windows active
windowPas1 = {'idx_bumpTime', -5; 'idx_bumpTime',10};

alphaBump = 0.0001;
alphaMove= 0.001;

monkey = neurons(1,:).monkey;
date1 = neurons(1,:).date;
filds = fieldnames(td);
array = filds(contains(filds, '_spikes'),:);
array = array{1}(1:end-7);
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date1, filesep, 'plotting', filesep, 'changePoint',filesep];
mkdir(strjoin(savePath,''))
%% Time to get the TDs ready  

activeTime = 10*windowAct{1,2}:10:10*windowAct{2,2};
preActTime = -150:10:-100;
 temp = num2cell(mod([td.bumpDir], 360));
[td.bumpDir] = temp{:};
guide = td(1).([array, '_unit_guide']);
onsetInd = -1*windowAct{1,2};
td = doDefaultSmoothing(td);
tdAct = td;
tdAct = tdAct(strcmp({tdAct.result},'R'));

tdPas = td(~isnan([td.bumpDir]));

params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
tdAct  = getSpeed(tdAct);
tdAct = getMoveOnsetAndPeak(tdAct,params);
tdAct = tdAct(~isnan([tdAct.idx_movement_on]));
tdAct = tdAct(isnan([tdAct.idx_bumpTime]));

tdPre = trimTD(tdAct, windowPre(1,:), windowPre(2,:));
tdPreBump = trimTD(tdPas, windowPreBump(1,:), windowPreBump(2,:));

tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
tdPas = trimTD(tdPas, windowPas1(1,:), windowPas1(2,:));
%% Compute directions to do changepoint about

dirsB = unique([tdPas.bumpDir]);
dirsB(isnan(dirsB)) = [];
dirsB(mod(dirsB, 45) ~= 0) = [];

dirs = unique([tdAct.target_direction]);
dirs(isnan(dirs)) = [];
dirs(mod(dirs, pi/8) ~= 0 ) = [];
dirs = sort(dirs);
guide = td(1).([array,'_unit_guide']);
%% Prep placeholders, and iterate across directions and units

firingPre = cat(1, tdPre.([array,'_spikes'])); % Firing in the premovement window
changeIndMat = zeros(length(dirs),length(guide(:,1)));
for dirNum = 1:length(dirs) % For each direction
    tdDirPre = tdPre([tdAct.target_direction] == dirs(dirNum));
    tdDir = tdAct([tdAct.target_direction] == dirs(dirNum));
    
    
    fr1 = cat(3, tdDir.([array, '_spikes']));
    fr1 = permute(fr1, [3,1,2]);
    frPre = cat(3, tdDirPre.([array,'_spikes']));
    frPre = permute(frPre, [3,1,2]);
    mFRPre = squeeze(mean(frPre,2));
    ciFRPre = squeeze(bootci(1000, @mean, frPre));

    ciMFRPre = bootci(100,{@mean, mFRPre}, 'alpha', alphaMove);
    mFRPreMean = mean(mFRPre);
    mFR = squeeze(mean(fr1));
    for trial = 1:length(mFRPre(:,1))
        for unit = 1:length(guide(:,1)) % For each unit
            trialFRDif(unit,trial,:) = fr1(trial,:,unit) - mFRPre(trial,unit);
        end
    end
    meanDifFR = squeeze(mean(trialFRDif, 2));
    ciDifRF = squeeze(bootci(1000, @mean, permute(trialFRDif,[2,1,3])));
%     flag = abs(meanDifFR) > 5;
%     [~, firstInd]=max(flag,[],2);
    for i = 1:length(guide(:,1))
        flag = meanDifFR(i,:) + mFRPreMean(i) > ciMFRPre(2,i) & meanDifFR(i,:) >3;
        flag2 = meanDifFR(i,:) + mFRPreMean(i) < ciMFRPre(1,i) & meanDifFR(i,:) <-3;
%         close all
        
        elec = guide(i,1);
        id = guide(i,2);
        
        changeFlag = (flag & [flag(2:end), 0]) |(flag2 & [flag2(2:end), 0]);
        changeInd = find(changeFlag, 1);

        if plotEx & elec == 27 & id ==2 & any([1:8] ==dirNum)
            figure
            plot(activeTime, meanDifFR(i,:))
            hold on
            plot(activeTime, squeeze(ciDifRF(1,i,:)), 'r')
            plot(activeTime, squeeze(ciDifRF(2,i,:)), 'r')
%             plot(preActTime, squeeze(ciFRPre(1,:,i)), 'b')
%             plot(preActTime, squeeze(ciFRPre(2,:,i)), 'b')
%             plot(activeTime,  
            title(['Elec ', num2str(guide(i,1)), ' Unit ' ,num2str(guide(i,2)), ' Dir ', num2str(dirNum)])
        end
        if ~isempty(changeInd) 
            if plotEx & elec == 27 & id ==2 & any( [1:8] ==dirNum)
                plot([activeTime(changeInd), activeTime(changeInd)], [0, max(abs(meanDifFR(i,:)))])
                set(gca,'TickDir','out', 'box', 'off')
                xlabel('Time relative to MoveOnset(ms)')
                ylabel('Firing rate change from baseline (Hz)')
            end
            changeIndMat(dirNum,i) = (changeInd+ windowAct{1,2})*10;
        else
            changeIndMat(dirNum,i) = -500;
        end
    end
end
 
neurons.cpDifAvg = changeIndMat';

firingPreB = cat(1, tdPreBump.([array,'_spikes'])); % Firing in the premovement window
changeIndMatB = zeros(length(dirsB),length(guide(:,1)));
for dirNum = 1:length(dirsB) % For each direction
    tdDirPreB = tdPreBump([tdPas.bumpDir] == dirsB(dirNum));
    tdDirB = tdPas([tdPas.bumpDir] == dirsB(dirNum));
    
    
    frB1 = cat(3, tdDirB.([array, '_spikes']));
    frB1 = permute(frB1, [3,1,2]);
    frPreB = cat(3, tdDirPreB.([array,'_spikes']));
    frPreB = permute(frPreB, [3,1,2]);
    mFRPreB = squeeze(mean(frPreB,2));
    ciMFRPreB = bootci(100, {@mean, mFRPreB}, 'alpha', alphaBump);
    mFRPreMeanB = mean(mFRPreB);
    mFR = squeeze(mean(frB1));
    for trial = 1:length(mFRPreB(:,1))
        for unit = 1:length(guide(:,1)) % For each unit
            trialFRDifB(unit,trial,:) = frB1(trial,:,unit) - mFRPreB(trial,unit);
        end
    end
    meanDifFRB = squeeze(mean(trialFRDifB, 2));
%     flag = abs(meanDifFR) > 5;
%     [~, firstInd]=max(flag,[],2);
    for i = 1:length(guide(:,1))
        flagB = meanDifFRB(i,:) + mFRPreMeanB(i) > ciMFRPreB(2,i) & meanDifFRB(i,:) >3;
        flag2B = meanDifFRB(i,:) + mFRPreMeanB(i) < ciMFRPreB(1,i) & meanDifFRB(i,:) <-3;
%         close all
        
        changeFlagB = (flagB & [flagB(2:end), 0]) |(flag2B & [flag2B(2:end), 0]);
        changeIndB = find(changeFlagB, 1);
        if plotExBump
            figure
            plot(meanDifFRB(i,:))
            hold on
        end
        if ~isempty(changeIndB)
            if plotExBump
                plot([changeIndB, changeIndB], [0, max(abs(meanDifFRB(i,:)))])
            end
            changeIndMatB(dirNum,i) = (changeIndB+ windowPas1{1,2})*10;
        else
            changeIndMatB(dirNum,i) = -500;
        end
    end
end
 
neurons.cpDifBumpAvg = changeIndMatB';

end