% clear all
close all
clear all
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
% 
date = '20190829';
monkey = 'Snap';
unitNames = 'cuneate';
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
% date = '20190822';
% monkey = 'Snap';1
% unitNames= 'cuneate';

mappingLog = getSensoryMappings(monkey);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO',2);
td = getSpeed(td);

target_direction = 'target_direction';
if length(td) == 1
    disp('Splitting')
    td = splitTD(td, struct('split_idx_name', 'idx_startTime', 'linked_fields', {{'bumpDir', 'ctrHold', 'ctrHoldBump', 'result', 'tgtDir', 'trialID'}} ));
    target_direction = 'tgtDir';
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    [~, td] = getTDidx(td, 'result' ,'R');
    td = getMoveOnsetAndPeak(td, params);
    td = removeBadTrials(td);
else
end
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getNorm(td,struct('signals','vel','field_extra','speed'));

td = getMoveOnsetAndPeak(td,params);


if td(1).bin_size ==.001
    td = binTD(td, 10);
end

td = td(~isnan([td.idx_movement_on]));
td = removeBadNeurons(td, struct('remove_unsorted', false));
% td = removeUnsorted(td);
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'rawPeakBumpAlignedPlots',filesep];
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


numCount = 1:length(td(1).(unitSpikes)(1,:));
%% Data Preparation and sorting out trials

dirsM = unique([td.(target_direction)]);
dirsM = dirsM(~isnan(dirsM));
dirsM(mod(dirsM, pi/8) ~= 0) = [];


for i = 1:length(dirsM)
    tdDir{i} = td([td.(target_direction)] == dirsM(i));
%     tdDir{i} = trimTD(tdDir{i}, {'idx_bumpTime', 13}, 'idx_endTime');
%     tdDir{i} = tdDir{i}([tdDir{i}.idx_endTime] - [tdDir{i}.idx_goCueTime] < 1/tdDir{i}(1).bin_size);
end
bumpTrials = td(~isnan([td.bumpDir])); 
dirsBump = unique([td.bumpDir]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));

params.peak_name = 'bump_peak_speed';
params.onset_name = 'bump_movement_on';
params.start_idx = 'idx_bumpTime';
params.end_idx = 'idx_goCueTime';
params.peak_idx_end = 13;
for i = 1:length(dirsBump)
    tdBump{i}= getMoveOnsetAndPeak(td([td.bumpDir] == dirsBump(i)), params);

end

%%

    preMove = trimTD(td, {'idx_movement_on', -10}, {'idx_movement_on', -5});
    postMove = trimTD(td, {'idx_movement_on', 0}, {'idx_movement_on',13});
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
    
    tdTemp = td(~isnan([td.bumpDir]));
    preBump = trimTD(tdTemp, {'idx_bumpTime', -10}, {'idx_bumpTime', -5});

    postBump = trimTD(tdTemp, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
    for i = 1:length(dirsBump)
        postBumpDir{i}= postBump([postBump.bumpDir] == dirsBump(i));
        postBumpFiring{i} = cat(3, postBumpDir{i}.(unitSpikes)).*100;
        postBumpStat(i).meanCI(:,1) = squeeze(mean(mean(postBumpFiring{i}, 3),1))';
        postBumpStat(i).meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(postBumpFiring{i}))')';

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
paramsBump.align= 'bump_peak_speed';
paramsBump.xBound = [-.3, .3];
paramsBump.array = unitNames;

paramsMove.yMax = maxSpeed;
paramsMove.align= 'peak_speed';
paramsMove.xBound = [-.3, .3];
paramsMove.array =unitNames;
    
close all
for num1 = numCount
    close all
    clear meanKin
    params.neuron = num1;
    bumpX = sum(squeeze(cos(thetaB)'.*squeeze(bumpTot(num1,1,:)))');
    bumpY = sum(squeeze(sin(thetaB)'.*squeeze(bumpTot(num1,1,:)))');

    moveX = sum(squeeze(cos(thetaM)'.*squeeze(moveTot(num1,1,:)))');
    moveY = sum(squeeze(sin(thetaM)'.*squeeze(moveTot(num1,1,:)))');
    
    angMove(num1) = atan2(moveY, moveX);
    angBump(num1) = atan2(bumpY, bumpX);
    
    title1 = [monkey, ' ', unitNames, ' Electrode' num2str(td(1).(unitGuide)(num1,1)), ' Unit ', num2str(td(1).(unitGuide)(num1,2))];
    maxFiringMove =0;
    maxFiringBump = 0;
    for bumpMove = 1:2
        if bumpMove == 1            
            move = figure('visible','off');
            before = beforeMove;
            after = afterMove;
            startInd = 'idx_peak_speed';
            params = paramsMove;
            params.neuron = num1;
            tdPlot = tdDir;
            dirs = dirsM;
            theta = thetaM;
           
            
        elseif bumpMove == 2
            clear meanKin
            bump = figure('visible','off');
            before = beforeBump;
            after = afterBump;
            startInd = 'idx_bump_peak_speed';
            params = paramsBump;
            params.neuron = num1;
            tdPlot = tdBump;
            dirs = dirsBump;
            theta = thetaB;
           
        end
        if isMapped

        subplot(7, 3, 19:21)
        neuron.date = date;
        neuron.monkey = monkey;
        neuron.chan = td(1).(unitGuide)(num1,1);
        neuron.unitNum  = td(1).(unitGuide)(num1,2);
        neuron.mapName = getMapName(td, neuron.chan);
        mapping = getClosestMap(neuron, mappingLog);
        if ischar(mapping)
            txt = 'No Mapping';
            daysTxt = 'NA';
        else
            txt = mapping.desc;
            daysDif = mapping.daysDif;
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
            kin{i} = cat(3, tdTemp1{i}.vel);
            meanKin(i,:) = rownorm(squeeze(mean(kin{i},3)));

            plot(linspace(-1*before, after, length(meanKin(1,:))), meanKin(i,:), 'k')
            hold on
            plot([0,0],[0, maxSpeed], 'b-')
            ylim([0, maxSpeed])
            if plotRasters
                params.xBound = [-1*before, after];
                unitRaster(tdPlot{i}, params);
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
            firing = cat(3, tdTrim.(unitSpikes));
            meanMoveFiring = 100*mean(squeeze(firing(:,num1,:)),2);
            bar(linspace(-1*before, after, length(meanMoveFiring)), conv(meanMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
            xlim([-1*before, after])
            if bumpMove ==1
                maxFiringMove = max(max(conv(meanMoveFiring, w, 'same')), maxFiringMove);
            else
                maxFiringBump = max(max(conv(meanMoveFiring, w, 'same')), maxFiringBump);
            end
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

            polarplot(thetaPlot, [moveHigh;moveHigh(1)], 'Color', [.4,.4,1], 'LineWidth', 2)
            hold on
            polarplot(thetaPlot, [moveMean;moveMean(1)], 'Color', [0,0,1], 'LineWidth', 2)
            polarplot(thetaPlot, [moveLow; moveLow(1)], 'Color', [.4,.4,1], 'LineWidth', 2)

            polarplot([angMove(num1), angMove(num1)], [0, max([bumpHigh])], 'Color', [0,0,1],'LineWidth',2);
            set(gca,'TickDir','out', 'box', 'off')
            set(gca,'thetatick',[],'rtick',[])
            suptitle1([title1, ' Active'])
            if gracileFlag(num1)
            suptitle1([title1, ' Active GRACILE'])
            end
        else
            bumpHigh =squeeze(bumpTot(num1, 3, :));
            bumpMean = squeeze(bumpTot(num1,1,:));
            bumpLow = squeeze(bumpTot(num1,2,:));

            thetaPlot = deg2rad([theta,theta(1)]);

            subplot('Position',[.39,.48,.25,.2])
            polarplot(thetaPlot, [bumpHigh; bumpHigh(1)], 'Color', [1,.4,.4], 'LineWidth', 2)
            hold on 
            polarplot(thetaPlot, [bumpMean;bumpMean(1)], 'Color', [1,0,0], 'LineWidth', 2)
            polarplot(thetaPlot, [bumpLow;bumpLow(1)], 'Color', [1,.4,.4], 'LineWidth', 2)

            polarplot([angBump(num1), angBump(num1)], [0, max([moveHigh])],'Color', [1,0,0], 'LineWidth', 2);
            set(gca,'TickDir','out', 'box', 'off')
            set(gca,'thetatick',[],'rtick',[])
            suptitle1([title1, 'passive'])
            if gracileFlag(num1)
            suptitle1([title1, ' Passive GRACILE'])
            end
        end
        disp(num1)
    end
    for bm = 1:2
        switch bm
            case 1
                move;
                pt1 = [spr1,spr2,spr3,spr4,spr5,spr6,spr7,spr8];

            case 2
                bump;
                pt1 = [sprb1,sprb2,sprb3,sprb4,sprb5,sprb6,sprb7,sprb8];

                
        end
      
        for pt = 1:length(pt1)    
            ylim(pt1(pt), [0,max(1.1*max(maxFiringMove, maxFiringBump))])
        end
    end
    if savePlots
            if gracileFlag(num1)
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, 'Gracile',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), 'GRACILE.pdf'],bump)
                set(move, 'Renderer', 'Painters');
                save2pdf([savePath, 'Gracile', filesep,strrep(title1, ' ', '_'), 'Move', num2str(date), 'GRACILE.pdf'],move)
                saveas(bump,[savePath,'Gracile',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), 'GRACILE.png'])
                saveas(move,[savePath,'Gracile', filesep, strrep(title1, ' ', '_'), '_Move_', num2str(date), 'GRACILE.png'])
            else
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, unitNames,filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.pdf'],bump)
                set(move, 'Renderer', 'Painters');
                save2pdf([savePath,unitNames, filesep,strrep(title1, ' ', '_'), '_Move_', num2str(date), '.pdf'],move)
                saveas(bump,[savePath, unitNames,filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.png'])
                saveas(move,[savePath, unitNames,filesep, strrep(title1, ' ', '_'), '_Move_', num2str(date), '.png'])
            end

    end

        
    end

   


%% Short time

