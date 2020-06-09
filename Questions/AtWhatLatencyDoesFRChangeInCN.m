clearvars -except td1 td2 td3 td4 td5
close all
butterDate = '20190129';
snapDate = '20190829';
crackleDate = '20190418';
duncanDate = '20190710';
monkeyS1 = 'Duncan';
hanDate = '20171122';
array = 'cuneate';

recompute = false;
doEncoding= false;
doDecoding = false;

windowAct= {'idx_movement_on', -30; 'idx_movement_on',13}; %Default trimming windows active
windowPas1 = {'idx_bumpTime', -10; 'idx_bumpTime',13};

windowAct1= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
neuronsCombined = [];

neuronsB = getNeurons('Butter', butterDate,'CObump','cuneate',[windowAct1; windowPas]);
neuronsS = getNeurons('Snap', snapDate, 'CObump','cuneate',[windowAct1; windowPas]);
neuronsC = getNeurons('Crackle', crackleDate, 'CObump','cuneate',[windowAct1; windowPas]);
neuronsH = getNeurons('Han', hanDate,'COactpas', 'LeftS1Area2',[windowAct1; windowPas]);
neuronsD = getNeurons('Duncan', duncanDate,'CObump','leftS1', [windowAct1;windowPas]);

%%
for i = 1:5
    switch i
        case 1
            monkey= 'Butter';
            date = butterDate;
            number= 1;
            if ~exist('td1')
                td1 = getTD(monkey, date, 'CO',2);
                    td1 = tdToBinSize(td1, 10);

            end
            td = td1;
            neurons = neuronsB;
        case 2
            monkey = 'Snap';
            date = snapDate;
            number =2;
            if ~exist('td2')
                td2 = getTD(monkey, date, 'CO',number);
                td2 = tdToBinSize(td2, 10);

            end
            td = td2;
            neurons = neuronsS;
        case 3
            monkey = 'Crackle';
            date = crackleDate;
            number =1;
            if ~exist('td3')
                td3 = getTD(monkey, date, 'CO', number);
                td3 = tdToBinSize(td3, 10);

            end
            td = td3;
            neurons = neuronsC;
        case 4
            monkey = 'Duncan';
            date = duncanDate;
            number = 1;
            if ~exist('td4')
                td4 = getTD(monkey,date,'CObumpmove', number);
                td4 = tdToBinSize(td4, 10);

            end
            td = td4;
            array = 'leftS1';
            if strcmp(monkey, 'Duncan') 
                td(~isnan([td.idx_bumpTime]) & [td.idx_goCueTime]< [td.idx_bumpTime])=[];
                td([td.tgtDist]<8) = [];
            end
            neurons = neuronsD;
        case 5
            monkey = 'Han';
            date = hanDate;
            array = 'LeftS1Area2';
            number = 1;
            if ~exist('td5')
                td5 = getTD(monkey, date, 'COactpas', number);
                td5 = tdToBinSize(td5, 10);

            end
            td = td5;
            neurons = neuronsH;

    end
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
            temp = findchangepts(mean(squeeze(fr1(:,unit,:)),2), 'MaxNumChanges',1);
            if ~isempty(temp)
                cpAvg(unit, dirNum) = temp;
                figure
                plot(mean(squeeze(fr1(:,unit,:)),2))
                hold on
                plot([temp, temp],[0,max(mean(squeeze(fr1(:,unit,:)),2))], '--')
                title([monkey, ' Unit ', num2str(guide(unit,1)), ' ID ', num2str(guide(unit,2))])
            end

        end
    end
    
    for dirNum = 1:length(dirsB)
        tdDir = tdPas([tdPas.bumpDir] == dirsB(dirNum));
        fr1 = cat(3, tdDir.([array, '_spikes']));
        for unit = 1:length(fr1(1,:,1))
            temp = findchangepts(mean(squeeze(fr1(:,unit,:)),2), 'MaxNumChanges',1);
            if ~isempty(temp)
                cpAvgBump(unit, dirNum) = temp;
            end
        end
    end
    
    cpAvgMon{i} = cpAvg;
    
    cpAvgMonBump{i} = cpAvgBump;
    for j = 1:length(fr1(1,:,1))
        switch i 
            case 1
                neuronsB.changePointAvg(j,:) = cpAvg(j,:);
                neuronsB.changePointAvgBump(j,:) = cpAvgBump(j,:);
            case 2
                neuronsS.changePointAvg(j,:) = cpAvg(j,:);
                neuronsS.changePointAvgBump(j,:) = cpAvgBump(j,:);
            case 3
                neuronsC.changePointAvg(j,:) = cpAvg(j,:);
                neuronsC.changePointAvgBump(j,:) = cpAvgBump(j,:);
            case 4
                neuronsD.changePointAvg(j,:) = cpAvg(j,:);
                neuronsD.changePointAvgBump(j,:) = cpAvgBump(j,:);
            case 5
                neuronsH.changePointAvg(j,:) = cpAvg(j,:);
                neuronsH.changePointAvgBump(j,:) = cpAvgBump(j,:);
        end
    end
    
end
%%
saveNeurons(neuronsB, 'MappedNeurons')
saveNeurons(neuronsS, 'MappedNeurons')
saveNeurons(neuronsC, 'MappedNeurons')
saveNeurons(neuronsD, 'MappedNeurons')
saveNeurons(neuronsH, 'MappedNeurons')
%%
neuronsB1 = neuronsB(logical(neuronsB.isSorted) & logical(neuronsB.sinTunedPas),:);
neuronsC1 = neuronsC(logical(neuronsC.isSorted) & logical(neuronsC.sinTunedPas),:);
neuronsS1 = neuronsS(logical(neuronsS.isSorted) & logical(neuronsS.sinTunedPas),:);
neuronsH1 = neuronsH(logical(neuronsH.isSorted) & logical(neuronsH.sinTunedPas),:);
neuronsD1 = neuronsD(logical(neuronsD.isSorted) & logical(neuronsD.sinTunedPas),:);

meanLag = zeros(5,1);

neurons1 = neuronsB1;
latencies = neurons1.changePointAvg;
latencies = latencies(:);
latencies(latencies==0)=[];
figure
subplot(5,1,1)
histogram(latencies)
title('Butter')
meanLag(1) = mean(latencies);
xlim([0,45])

neurons1 = neuronsC1;
latencies = neurons1.changePointAvg;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,2)
histogram(latencies)
title('Crackle')
meanLag(2) = mean(latencies);
xlim([0,45])


neurons1 = neuronsS1;
latencies = neurons1.changePointAvg;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,3)
histogram(latencies)
title('Snap')
meanLag(3) = mean(latencies);
xlim([0,45])


neurons1 = neuronsH1;
latencies = neurons1.changePointAvg;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,4)
histogram(latencies)
title('Han')
meanLag(4) = mean(latencies);
xlim([0,45])


neurons1 = neuronsD1;
latencies = neurons1.changePointAvg;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,5)
histogram(latencies)
title('Duncan')
meanLag(5) = mean(latencies);
xlim([0,45])

%%

neurons1 = neuronsB1;
latencies = neurons1.changePointAvgBump;
latencies = latencies(:);
latencies(latencies==0)=[];
figure
subplot(5,1,1)
histogram(latencies)
title('Butter')
meanLag(1) = mean(latencies);

neurons1 = neuronsC1;
latencies = neurons1.changePointAvgBump;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,2)
histogram(latencies)
title('Crackle')
meanLag(2) = mean(latencies);


neurons1 = neuronsS1;
latencies = neurons1.changePointAvgBump;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,3)
histogram(latencies)
title('Snap')
meanLag(3) = mean(latencies);


neurons1 = neuronsH1;
latencies = neurons1.changePointAvgBump;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,4)
histogram(latencies)
title('Han')
meanLag(4) = mean(latencies);


neurons1 = neuronsD1;
latencies = neurons1.changePointAvgBump;
latencies = latencies(:);
latencies(latencies==0)=[];
subplot(5,1,5)
histogram(latencies)
title('Duncan')
meanLag(5) = mean(latencies);
