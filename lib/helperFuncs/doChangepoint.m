function neurons = doChangepoint(neurons,td)
windowAct= {'idx_movement_on', -30; 'idx_movement_on',13}; %Default trimming windows active
windowPas1 = {'idx_bumpTime', -10; 'idx_bumpTime',13};


filds = fieldnames(td);
array = filds(contains(filds, '_spikes'),:);
array = array{1}(1:end-7);
        
 temp = num2cell(mod([td.bumpDir], 360));
[td.bumpDir] = temp{:};
guide = td(1).([array, '_unit_guide']);

%     tdAct = td(isnan([td.bumpDir]));
tdAct = td;
tdPas = td(~isnan([td.bumpDir]));

target_direction = 'target_direction';

params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
tdAct  = getSpeed(tdAct);
tdAct = getMoveOnsetAndPeak(tdAct,params);
tdAct = tdAct(~isnan([tdAct.idx_movement_on]));

paramsSmooth.width = .01;
paramsSmooth.signals = [array, '_spikes'];
paramsSmooth.calc_rate = true;
%     td = smoothSignals(td, paramsSmooth);

tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
tdPas = trimTD(tdPas, windowPas1(1,:), windowPas1(2,:));


dirsB = unique([tdPas.bumpDir]);
dirsB(isnan(dirsB)) = [];
dirsB(mod(dirsB, 45) ~= 0) = [];

dirs = unique([tdAct.target_direction]);
dirs(isnan(dirs)) = [];
dirs(mod(dirs, pi/8) ~= 0 ) = [];

cpAvg = zeros(length(tdAct(1).([array, '_unit_guide'])),length(dirs));
cpAvgBump = zeros(length(tdPas(1).([array, '_unit_guide'])), length(dirsB));

for dirNum = 1:length(dirs)
    tdDir = tdAct([tdAct.target_direction] == dirs(dirNum));
    fr1 = cat(3, tdDir.([array, '_spikes']));
    for unit = 1:length(fr1(1,:,1))
        mFR = mean(squeeze(fr1(:,unit,:)),2);
        temp = findchangepts(mFR, 'MaxNumChanges',1);
        mean1 = mean(mFR(1:temp-1));
        mean2 = mean(mFR(temp:end));
        frPre = mFR(temp-1);
        frPost = mFR(temp);
        prob1 = .00:.1:1.0;

        if ~isempty(temp)
        for i=2:11
            ll(i-1) = norm(frPost - (mean2*prob1(i) + mean1*(1-prob1(i))));
        end
        [~, minLL] = min(ll);
        cpAvg(unit, dirNum) = temp + minLL/10;
        if false
            figure
            plot(mFR)
            hold on
            plot([temp, temp], [0,max(mFR)])
            plot([0, temp-1], [mean1, mean1])
            plot([temp, length(mFR)], [mean2, mean2]);
            title(['CP at ', num2str(cpAvg(unit,dirNum))])
            
        end
    end
end
end
for dirNum = 1:length(dirsB)
    tdDir = tdPas([tdPas.bumpDir] == dirsB(dirNum));
    fr1 = cat(3, tdDir.([array, '_spikes']));
    mFR = mean(squeeze(fr1(:,unit,:)),2);
    temp = findchangepts(mFR, 'MaxNumChanges',1);
    mean1 = mean(mFR(1:temp-1));
    mean2 = mean(mFR(temp:end));
    frPre = mFR(temp-1);
    frPost = mFR(temp);
    prob1 = .00:.1:1.0;
    
    for unit = 1:length(fr1(1,:,1))
        temp = findchangepts(mean(squeeze(fr1(:,unit,:)),2), 'MaxNumChanges',1);
        if ~isempty(temp)
        for i=2:11
            ll(i-1) = norm(frPost - (mean2*prob1(i) + mean1*(1-prob1(i))));
        end
        [~, minLL] = min(ll);
        cpAvgBump(unit, dirNum) = temp + minLL/10;
        end
    end
end
neurons.cpAvg = cell(height(neurons),1);
neurons.cpBumpAvg =cell(height(neurons),1);
for i = 1:length(guide(:,1))
    unitNum = find([guide(i,1) == neurons.chan] & [guide(i,2) == neurons.unitNum]);
    neurons.cpAvg(unitNum,:) = {cpAvg(i, :)};
    neurons.cpBumpAvg(unitNum,:) = {cpAvgBump(i,:)};
end
    
end