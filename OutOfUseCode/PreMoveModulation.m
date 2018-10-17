close all
close all
%load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 0;
params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
params.extra_time = [.4,.4];
td = parseFileByTrial(cds, params);
td = getMoveOnsetAndPeak(td);
bumpTdFlag = ~isnan([td.idx_bumpTime]);
noBumpTdFlag = ~bumpTdFlag;

bumpTrials = td(bumpTdFlag);
noBumpTrials = td(noBumpTdFlag);
totalFiring = cell(length(bumpTrials(1).Cuneate_spikes(1,:)),1);
for i = 1:length(bumpTrials)
    spikes = bumpTrials(i).Cuneate_spikes;
    startIdx = bumpTrials(i).idx_startTime;
    endIdx = bumpTrials(i).idx_bumpTime-1;
    for j = 1:length(spikes(1,:))
        totalFiring{j} = [totalFiring{j}; spikes(startIdx:endIdx,j)];
    end
end

for i = 1:length(noBumpTrials)
    spikes = noBumpTrials(i).Cuneate_spikes;
    startIdx = noBumpTrials(i).idx_startTime;
    endIdx = noBumpTrials(i).idx_goCueTime-1;
    for j = 1:length(spikes(1,:))
        totalFiring{j} = [totalFiring{j}; spikes(startIdx:endIdx,j)];
    end
end
%%
meanFiring = cellfun(@mean, totalFiring);

priorTime = 10;
changeTime = 15;
beforeFiring= cell(length(bumpTrials(1).Cuneate_spikes(1,:)),1);
startIdx = td(1).idx_movement_on -priorTime;
endIdx = td(1).idx_movement_on -1;
beforeFiringSum = zeros(length(startIdx-changeTime:endIdx),length(bumpTrials(1).Cuneate_spikes(1,:)));
for i = 1:length(td)
    spikes = td(i).Cuneate_spikes;
    startIdx = td(i).idx_movement_on-priorTime;
    endIdx = td(i).idx_movement_on - 1;
    for j = 1:length(spikes(1,:))
        beforeFiring{j} = [beforeFiring{j}; spikes(startIdx:endIdx,j)];
        beforeFiringSum(:,j) = beforeFiringSum(:,j) + spikes(startIdx-changeTime:endIdx,j);
    end
end
meanBefore = cellfun(@mean, beforeFiring);
sigFlag =  zeros(length(spikes(1,:)),1);
for i = 1:length(spikes(1,:))
    meanFire = totalFiring{i};
    meanOnes = ones(length(meanFire), 1);
    beforeFire = beforeFiring{i};
    beforeTwos = 2*ones(length(beforeFire), 1);
    totFire = [meanFire; beforeFire];
    onesTwos = [meanOnes; beforeTwos];
    [p{i}, stats{i}]=anovan(totFire, onesTwos, 'display', 'off'); 
    if p{i} <.05/length(spikes(1,:))
        sigFlag(i) = 1;
    end
end

for i = 1:length(sigFlag)
    if sigFlag(i)
        findchangepts(beforeFiringSum(:,i))
    end
end