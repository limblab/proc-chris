% clear all
close all
clear all
dateArr = {'20190128','20190418', '20190829', '20181211', '20170917', '20170913','20170105','20191106','20200729', '20180403'};
monkeyArr = {'Butter','Crackle', 'Snap', 'Butter', 'Lando', 'Chips', 'Han', 'Duncan', 'Rocket', 'Butter'};
numArr = [1,1,2,1,1,1,1,1,1,1];



for mon = [5]
clearvars -except dateArr monkeyArr numArr mon
suffix = 'NeuronStruct_MappedNeurons';

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;
windowAct= {'idx_movement_on_min', 0; 'idx_movement_on_min',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

% date1 = dateArr{mon};
% monkey = monkeyArr{mon};
% numT = numArr(mon);
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';

% td =getTD(monkey, date1, 'CO',numT);
td = getPaperFiles(mon);
date1 =td(1).date;
date1 = dateToLabDate(date1);
monkey = td(1).monkey;
filds = fieldnames(td);
array = filds(contains(filds, '_spikes'),:);
unitNames = getArrayName(td);

monkey = td(1).monkey;
task = td(1).task;


neurons = getPaperNeurons(mon, windowAct, windowPas);


plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
% 

% date = '20190822';
% monkey = 'Snap';
% unitNames= 'cuneate';
alignMove = 'movement_on_min';
alignBump = 'bumpTime';

mappingLog = getSensoryMappings(monkey);



td = getSpeed(td);
if td(1).bin_size ==.001
    td = binTD(td, 10);
end
target_direction = 'target_direction';
if length(td) == 1
    disp('Splitting')
    td = splitTD(td, struct('split_idx_name', 'idx_startTime', 'linked_fields', {{'bumpDir', 'ctrHold', 'ctrHoldBump', 'result', 'tgtDir', 'trialID'}} ));
    target_direction = 'tgtDir';
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeakBacktrace(td, params);
    td = removeBadTrials(td);
else
end
td = normalizeTDLabels(td);
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getNorm(td,struct('signals','vel','field_extra','speed'));


[~,td] = getTDidx(td, 'result', 'R');
td = removeUnsorted(td);
td = getMoveOnsetAndPeakBackTrace(td,params);
td(isnan([td.idx_movement_on_min])) = [];

td = td(~isnan([td.idx_movement_on_min]));
td = removeBadNeurons(td, struct('remove_unsorted', false));
% td = removeUnsorted(td);
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep, date1, filesep, 'plotting', filesep, 'rawAlignedPlots',filesep];
if contains(unitNames, 'cuneate')
    mkdir([savePath, 'Cuneate']);
    mkdir([savePath, 'Gracile']);

    if isfield(td(1),'cuneate_naming') & isMapped
    elec2MapName = td(1).cuneate_naming;
    for i = 1:length(td(1).(unitSpikes)(1,:))
        gracileFlag(i) = getGracile(monkey, elec2MapName(elec2MapName(:,1) == td(1).cuneate_unit_guide(i,1),2));
    end
    else
        gracileFlag = zeros(length(td(1).(unitSpikes)(1,:)),1);
    end
else 
    gracileFlag = zeros(length(td(1).(unitSpikes)(1,:)),1);
end
w = [.0439; .4578;1;.4578;.0439];
w = w/sum(w);


numCount = 1:length(td(1).(unitGuide)(:,1));
%% Data Preparation and sorting out trials

dirsM = getMovementDirections(td);

tdAct = td;
[~, tdAct] = getTDidx(tdAct, 'result' ,'R');
% tdAct = removeHighSpeedAtOnset(tdAct);
% 
% tdAct = removeMovingAtGoCue(td);
if strcmp(monkey, 'Duncan') 
    tdAct(~isnan([td.idx_bumpTime]) & [td.idx_goCueTime]< [td.idx_bumpTime])=[];
end
for i = 1:length(dirsM)
    tdDir{i} = tdAct([tdAct.(target_direction)] == dirsM(i));
    tdDir{i}(~isnan([tdDir{i}.idx_bumpTime])) =[];
%     tdDir{i} = trimTD(tdDir{i}, {'idx_bumpTime', 13}, 'idx_endTime');
%     tdDir{i} = tdDir{i}([tdDir{i}.idx_endTime] - [tdDir{i}.idx_goCueTime] < 1/tdDir{i}(1).bin_size);
end

bumpTrials = td(~isnan([td.bumpDir])); 
bumpTrials([bumpTrials.idx_bumpTime]> [bumpTrials.idx_goCueTime])=[];
bumpDirs = mod([bumpTrials.bumpDir], 360);
for trial = 1:length(bumpDirs)
    bumpTrials(trial).bumpDir = bumpDirs(trial);
end
dirsBump = getBumpDirections(bumpTrials);
params.peak_name = 'bump_peak_speed';
params.onset_name = 'bump_movement_on';
params.start_idx = 'idx_bumpTime';
params.end_idx = 'idx_goCueTime';
params.peak_idx_end = 13;
for i = 1:length(dirsBump)
    tdBump{i}= getMoveOnsetAndPeak(bumpTrials([bumpTrials.bumpDir] == dirsBump(i)), params);

end

%%

    preMove = trimTD(td, {'idx_movement_on_min', -10}, {'idx_movement_on_min', -5});
    postMove = trimTD(td, {'idx_movement_on_min', 0}, {'idx_movement_on_min',40});
%     postMove = postMove(isnan([postMove.bumpDir]));
    preMoveFiring = cat(3, preMove.(unitSpikes)).*100;
    
    preMoveStat.meanCI(:,1) = squeeze(mean(mean(preMoveFiring, 3),1))';
    preMoveStat.meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(preMoveFiring))')';

    
    for i = 1:length(dirsM)
        postMoveDir{i} = postMove([postMove.(target_direction)] == dirsM(i));
        postMoveFiring{i} = cat(3, postMoveDir{i}.(unitSpikes))*100;
        postMoveStat(i).meanCI(:,1) = squeeze(mean(mean(postMoveFiring{i}, 3),1))';
        postMoveStat(i).meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(postMoveFiring{i}))')';

    end
    
    tdTemp = bumpTrials(~isnan([bumpTrials.bumpDir]));
    preBump = trimTD(tdTemp, {'idx_bumpTime', -10}, {'idx_bumpTime', -5});

    postBump = trimTD(tdTemp, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
    for i = 1:length(dirsBump)
        postBumpDir{i}= postBump([postBump.bumpDir] == dirsBump(i));
        postBumpFiring{i} = cat(3, postBumpDir{i}.(unitSpikes)).*100;
        postBumpStat(i).meanCI(:,1) = squeeze(mean(mean(postBumpFiring{i}, 3),1))';
        if length(postBumpDir{i}) > 2 
            postBumpStat(i).meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(postBumpFiring{i}))')';
        else
            postBumpStat(i).meanCI(:,2:3) = [postBumpStat(i).meanCI(:,1), postBumpStat(i).meanCI(:,1)];
        end
    end
    preBumpFiring = cat(3, preBump.(unitSpikes)).*100;
    
    preBumpStat.meanCI(:,1) = squeeze(mean(mean(preBumpFiring, 3),1))';
    preBumpStat.meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(preBumpFiring))')';

    t = cat(3, postMoveStat.meanCI);
    bumpTot = cat(3, postBumpStat.meanCI);
    moveTot = cat(3, postMoveStat.meanCI);
    bumpPre = cat(2, preBumpStat.meanCI);
    movePre = cat(2, preMoveStat.meanCI);
    thetaM = linspace(0, max(dirsM), length(dirsM));
    thetaB = linspace(0, max(dirsBump), length(dirsBump));
%% 
maxSpeed = 60;

paramsBump.yMax = maxSpeed;
paramsBump.align= alignBump;
paramsBump.xBound = [-.3, .3];
paramsBump.array = unitNames;

paramsMove.yMax = maxSpeed;
paramsMove.align= alignMove;
paramsMove.xBound = [-.3, .3];
paramsMove.array =unitNames;
guide = td(1).(unitGuide);
close all
for num1 = numCount
    hasNeuronStruct = ~isempty(neurons);
    if hasNeuronStruct
        neuron = neurons(1,:);
    end
    if hasNeuronStruct & ~isempty(neuron)& ismember('cpQuantAvg', neuron.Properties.VariableNames)
        neuron = neurons([neurons.chan] == guide(num1,1) & [neurons.ID] == guide(num1,2),:);
        cp = neuron.cpDifAvg;
        cpB = neuron.cpDifBumpAvg;
    else
        cp = zeros(length(dirsM),1);
        cpB = zeros(length(dirsBump),1);
    end
    close all
    clear meanKin
    params.neuron = num1;
    bumpX = sum(squeeze(cos(thetaB)'.*squeeze(bumpTot(num1,1,:)))');
    bumpY = sum(squeeze(sin(thetaB)'.*squeeze(bumpTot(num1,1,:)))');

    moveX = sum(squeeze(cos(thetaM)'.*squeeze(moveTot(num1,1,:)))');
    moveY = sum(squeeze(sin(thetaM)'.*squeeze(moveTot(num1,1,:)))');
    
    angMove(num1) = atan2(moveY, moveX);
    angBump(num1) = atan2(bumpY, bumpX);
    
    title1 = [monkey(1:2), '\_', unitNames(1:2), '\_E' num2str(td(1).(unitGuide)(num1,1)), 'U', num2str(td(1).(unitGuide)(num1,2))];
    title2 = [monkey, ' ', unitNames(1:2), ' E' num2str(td(1).(unitGuide)(num1,1)), 'U', num2str(td(1).(unitGuide)(num1,2))];

    maxFiringMove =0;
    maxFiringBump = 0;
    for bumpMove = 1:2
        if bumpMove == 1            
            move = figure('visible','off');
            before = beforeMove;
            after = afterMove;
            startInd = ['idx_', alignMove];
            params = paramsMove;
            params.neuron = num1;
            tdPlot = tdDir;
            dirs = dirsM;
            theta = thetaM;
            cp1 = cp;
            
        elseif bumpMove == 2
            clear meanKin
            bump = figure('visible','off');
            before = beforeBump;
            after = afterBump;
            startInd = ['idx_',alignBump];
            params = paramsBump;
            params.neuron = num1;
            tdPlot = tdBump;
            dirs = dirsBump;
            theta = thetaB;
            cp1 = cpB;
            
           
        end
        if isMapped

        subplot(7, 3, 19:21)
        
        if ~exist('neuron') | isempty(neuron) | ~isfield(neuron, 'desc')
            txt = 'No Mapping';
            daysTxt = 'NA';
        else
            txt = neuron.desc;
            daysDif = neuron.daysDiff;
            daysTxt = [' Days: ', num2str(daysDif)];
            txt = [txt, daysTxt];
        end
        
        tx = text(0,0,txt);
        
        extent = tx.Extent;
     
        xlim([extent(1), extent(1) + extent(3)])
        ylim([extent(2), extent(2) + extent(4)])
        set(gca,'ycolor','w')
        set(gca,'xcolor','w')
        

        end
        for i = 1:length(dirs)
            switch dirs(i)
                case {0 | 0}
                    sp1 = subplot(7,3, 9);
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {45, pi/4}
                    sp2 = subplot(7,3, 3);
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {90, pi/2}
                    sp3 = subplot(7,3, 2);
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {135, 3*pi/4}
                    sp4 = subplot(7,3, 1);
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {180, pi}
                    sp5 = subplot(7,3, 7);
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {225, 5*pi/4}
                    sp6 = subplot(7,3, 13);
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {270, 3*pi/2}
                    sp7 = subplot(7,3, 14);
                    hold on
                case {315, 7*pi/4}
                    sp8 = subplot(7,3, 15);
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
            end
            hold on
            xlim([-1*before, after])

            tdTemp1{i} = trimTD(tdPlot{i}, {startInd, -1*before/tdPlot{i}(1).bin_size}, {startInd, after/tdPlot{i}(1).bin_size});
            tdTemp1{i} = removeWrongSizeTD(tdTemp1{i});
            kin{i} = cat(3, tdTemp1{i}.vel);
%             meanKin(i,:) = rownorm(squeeze(mean(kin{i},3)));
            meanKin(i,:) = mean(cat(3, tdTemp1{i}.speed),3);

            plot(linspace(-1*before, after, length(meanKin(1,:))), meanKin(i,:), 'k')
            hold on
            plot([0,0],[0, maxSpeed], 'b-')
            ylim([0, maxSpeed])
            if plotRasters
                params.xBound = [-1*before, after];
                unitRaster(tdPlot{i}, params);
            else
                scatter(0,0)
            end
            switch bumpMove
                case 1
                switch dirs(i)
                    case 0
                        spr1 = subplot(7,3, 12);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {45, pi/4}
                        spr2 = subplot(7,3, 6);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {90, pi/2}
                        spr3 = subplot(7,3, 5);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {135,3*pi/4}
                        spr4 = subplot(7,3, 4);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {180, pi}
                        spr5 = subplot(7,3, 10);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {225,  5*pi/4}
                        spr6 = subplot(7,3, 16);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {270, 3*pi/2}
                        spr7 = subplot(7,3, 17);
                    case {315,  7*pi/4}
                       spr8 =  subplot(7,3, 18);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                end
                case 2
                switch dirs(i)
                    case 0
                        sprb1 = subplot(7,3, 12);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {45, pi/4}
                        sprb2 = subplot(7,3, 6);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {90, pi/2}
                        sprb3 = subplot(7,3, 5);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {135,3*pi/4}
                        sprb4 = subplot(7,3, 4);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {180, pi}
                        sprb5 = subplot(7,3, 10);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {225,  5*pi/4}
                        sprb6 = subplot(7,3, 16);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    case {270, 3*pi/2}
                        sprb7 = subplot(7,3, 17);
                    case {315,  7*pi/4}
                       sprb8 =  subplot(7,3, 18);
                        set(gca,'TickDir','out', 'box', 'off')
                        set(gca,'xtick',[],'ytick',[])
                    end
            end
            hold on
            xlim([-1*before, after])
            
            tdTrim = trimTD(tdPlot{i}, {startInd, -1*before*100}, {startInd, after*100});
            tdTrim = removeWrongSizeTD(tdTrim);
            firing = cat(3, tdTrim.(unitSpikes));
            meanMoveFiring = 100*mean(squeeze(firing(:,num1,:)),2);
            bar(linspace(-1*before, after, length(meanMoveFiring)), conv(meanMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
            
            xlim([-1*before, after])
            if bumpMove ==1
                maxFiringMove = max(max(conv(meanMoveFiring, w, 'same')), maxFiringMove);
            else
                maxFiringBump = max(max(conv(meanMoveFiring, w, 'same')), maxFiringBump);
            end
            plot([cp1(i)/1000, cp1(i)/1000], [0, max(conv(meanMoveFiring, w, 'same'))])
        end
        

        
        if bumpMove == 1
            bumpHigh =squeeze(bumpTot(num1, 3, :));
            bumpMean = squeeze(bumpTot(num1,1,:));
            bumpLow = squeeze(bumpTot(num1,2,:));

            moveHigh = squeeze(moveTot(num1,3,:));
            moveMean = squeeze(moveTot(num1,1,:));
            moveLow  = squeeze(moveTot(num1,2,:));

            thetaPlot = [theta,theta(1)];
            
            subplot('Position',[.39,.48,.25,.2])
            thetaLong = 0:pi/40:2*pi;
            polarplot(thetaPlot, [moveHigh;moveHigh(1)], 'Color', [.4,.4,1], 'LineWidth', 2)
            hold on
            polarplot(thetaPlot, [moveMean;moveMean(1)], 'Color', [0,0,1], 'LineWidth', 2)
            polarplot(thetaPlot, [moveLow; moveLow(1)], 'Color', [.4,.4,1], 'LineWidth', 2)
            polarplot(thetaLong, [preMoveStat.meanCI(num1,1)*ones(length(thetaLong),1)],'LineWidth',2, 'Color',[.5,.5,.5])
            polarplot([angMove(num1), angMove(num1)], [0, max([bumpHigh])], 'Color', [0,0,1],'LineWidth',2);
            set(gca,'TickDir','out', 'box', 'off')
            set(gca,'thetatick',[])
            suptitle1([title1, ' Active'])
            if gracileFlag(num1)
            suptitle1([title1, ' Active GRACILE'])
            end
        else
            thetaLong = 0:pi/40:2*pi;

            bumpHigh =squeeze(bumpTot(num1, 3, :));
            bumpMean = squeeze(bumpTot(num1,1,:));
            bumpLow = squeeze(bumpTot(num1,2,:));

            thetaPlot = deg2rad([theta,theta(1)]);

            subplot('Position',[.39,.48,.25,.2])
            polarplot(thetaPlot, [bumpHigh; bumpHigh(1)], 'Color', [1,.4,.4], 'LineWidth', 2)
            hold on 
            polarplot(thetaPlot, [bumpMean;bumpMean(1)], 'Color', [1,0,0], 'LineWidth', 2)
            polarplot(thetaPlot, [bumpLow;bumpLow(1)], 'Color', [1,.4,.4], 'LineWidth', 2)
            polarplot(thetaLong, [preMoveStat.meanCI(num1,1)*ones(length(thetaLong),1)],'LineWidth',2, 'Color',[.5,.5,.5])

            polarplot([angBump(num1), angBump(num1)], [0, max([moveHigh])],'Color', [1,0,0], 'LineWidth', 2);
            set(gca,'TickDir','out', 'box', 'off')
            set(gca,'thetatick',[])
            suptitle1([title1, 'passive'])
            if gracileFlag(num1)
            suptitle1([title1, ' Passive GRACILE'])
            end
        end
        disp([num2str(num1), ' of ', num2str(length(numCount))])
    end
    for bm = 1:2
        switch bm
            case 1
                move;
                if length(dirs) == 8
                    pt1 = [spr1,spr2,spr3,spr4,spr5,spr6,spr7,spr8];
                else
                    pt1 = [spr1,spr3, spr5, spr7];
                end
            case 2
                bump;
                if length(dirsBump) == 8
                    pt1 = [sprb1,sprb2,sprb3,sprb4,sprb5,sprb6,sprb7,sprb8];
                else
                    pt1 = [sprb1,sprb3, sprb5, sprb7];
                end
                
        end
      
        for pt = 1:length(pt1)    
            ylim(pt1(pt), [-.00001,max(1.1*max(maxFiringMove))])%, maxFiringBump))])
        end
    end
    if savePlots
        suffix1 = 'MaxMove';
            if gracileFlag(num1)
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, 'Gracile',filesep, strrep(title2, ' ', '_'), '_Bump_', date1, 'GRACILE.pdf'],bump)
                set(move, 'Renderer', 'Painters');
                save2pdf([savePath, 'Gracile', filesep,strrep(title2, ' ', '_'), 'Move',  date1, 'GRACILE.pdf'],move)
                saveas(bump,[savePath,'Gracile',filesep, strrep(title2, ' ', '_'), '_Bump_', date1, 'GRACILE.png'])
                saveas(move,[savePath,'Gracile', filesep, strrep(title2, ' ', '_'), '_Move_',  date1, 'GRACILE.png'])
            else
                mkdir(savePath, unitNames)
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, unitNames,filesep, strrep(title2, ' ', '_'), '_Bump_',  date1, suffix1,'.pdf'],bump)
                set(move, 'Renderer', 'Painters');
                save2pdf([savePath,unitNames, filesep,strrep(title2, ' ', '_'), '_Move_',  date1, suffix1,'.pdf'],move)
                saveas(bump,[savePath, unitNames,filesep, strrep(title2, ' ', '_'), '_Bump_', date1, suffix1,'.png'])
                saveas(move,[savePath, unitNames,filesep, strrep(title2, ' ', '_'), '_Move_', date1, suffix1,'.png'])
            end

    end

        
    end

end  


%% Short time

