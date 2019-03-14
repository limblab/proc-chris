% clear all
close all
clear all
plotRasters = 1;
savePlots = 1;
savePDF = true;
% 
% date = '20190129';
% monkey = 'Butter';
% unitNames = 'cuneate';

date = '20190312';
monkey = 'Crackle';
unitNames= 'cuneate';

mappingLog = getSensoryMappings(monkey);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO');
target_direction = 'target_direction';
if length(td) == 1
    disp('Splitting')
    td = splitTD(td, struct('split_idx_name', 'idx_startTime', 'linked_fields', {{'bumpDir', 'ctrHold', 'ctrHoldBump', 'result', 'tgtDir', 'trialID'}} ));
    target_direction = 'tgtDir';
    td = getMoveOnsetAndPeak(td);
    td = removeBadTrials(td);
else
end
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
params.min_ds = 1;
params.s_thresh = 8;
td = getMoveOnsetAndPeak(td,params);

if td(1).bin_size ==.001
    td = binTD(td, 10);
end
td = td(~isnan([td.idx_movement_on]));
td = removeBadNeurons(td);
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'rawAlignedPlots',filesep];
if contains(unitNames, 'cuneate')
    mkdir([savePath, 'Cuneate']);
    mkdir([savePath, 'Gracile']);


    elec2MapName = td(1).cuneate_naming;
    for i = 1:length(td(1).(unitSpikes)(1,:))
        gracileFlag(i) = getGracile(monkey, elec2MapName(elec2MapName(:,1) == td(1).cuneate_unit_guide(i,1),2));
    end
else 
    gracileFlag = zeros(length(td(1).(unitSpikes)(1,:)),1);
end
w = gausswin(5);
w = w/sum(w);


numCount = 1:length(td(1).(unitSpikes)(1,:));
%% Data Preparation and sorting out trials

dirsM = unique([td.(target_direction)]);
dirsM = dirsM(~isnan(dirsM));


for i = 1:length(dirsM)
    tdDir{i} = td([td.(target_direction)] == dirsM(i));
    tdDir{i} = tdDir{i}(isnan([tdDir{i}.bumpDir]));
end
bumpTrials = td(~isnan([td.bumpDir])); 
dirsBump = unique([td.bumpDir]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));


for i = 1:length(dirsBump)
    tdBump{i}= td([td.bumpDir] == dirsBump(i));
end

%%

    preMove = trimTD(td, {'idx_movement_on', -10}, {'idx_movement_on', -5});
    postMove = trimTD(td, {'idx_movement_on', 0}, {'idx_movement_on',13});
    postMove = postMove(isnan([postMove.bumpDir]));
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
    preBump = trimTD(tdTemp, {'idx_bumpTime', -10}, {'idx_bumpTime', 5});

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
    theta = linspace(0, 7*pi/4, length(dirsM));
%% 
maxSpeed = 60;

paramsBump.yMax = maxSpeed;
paramsBump.align= 'bumpTime';
paramsBump.xBound = [-.3, .3];
paramsBump.array = unitNames;

paramsMove.yMax = maxSpeed;
paramsMove.align= 'movement_on';
paramsMove.xBound = [-.3, .3];
paramsMove.array =unitNames;
    
close all
for num1 = numCount
    close all
    params.neuron = num1;
    bumpX = sum(squeeze(cos(theta)'.*squeeze(bumpTot(num1,1,:)))');
    bumpY = sum(squeeze(sin(theta)'.*squeeze(bumpTot(num1,1,:)))');

    moveX = sum(squeeze(cos(theta)'.*squeeze(moveTot(num1,1,:)))');
    moveY = sum(squeeze(sin(theta)'.*squeeze(moveTot(num1,1,:)))');
    
    angMove(num1) = atan2(moveY, moveX);
    angBump(num1) = atan2(bumpY, bumpX);
    
    title1 = [monkey, ' ', unitNames, ' Electrode' num2str(td(1).(unitGuide)(num1,1)), ' Unit ', num2str(td(1).(unitGuide)(num1,2))];
    maxFiring =0;
    for bumpMove = 1:2
        if bumpMove == 1            
            move = figure2();
            before = beforeMove;
            after = afterMove;
            startInd = 'idx_movement_on';
            params = paramsMove;
            params.neuron = num1;
            tdPlot = tdDir;
            dirs = dirsM;
            
           
            
        elseif bumpMove == 2
            bump = figure2();
            before = beforeBump;
            after = afterBump;
            startInd = 'idx_bumpTime';
            params = paramsBump;
            params.neuron = num1;
            tdPlot = tdBump;
            dirs = dirsBump;
            
           
        end
        for i = 1:length(dirs)
            switch dirs(i)
                case {0 | 0}
                    subplot(6,3, 9)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {45, pi/4}
                    subplot(6,3, 3)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {90, pi/2}
                    subplot(6,3, 2)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {135, 3*pi/4}
                    subplot(6,3, 1)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {180, pi}
                    subplot(6,3, 7)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {225, 5*pi/4}
                    subplot(6,3, 13)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {270, 3*pi/2}
                    subplot(6,3, 14)
                case {315, 7*pi/4}
                    subplot(6,3, 15)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
            end
            hold on
            xlim([-1*before, after])

            kin{i} = zeros(length(tdPlot{i}), length(tdPlot{i}(1).(startInd)-(before*100):tdPlot{i}(1).(startInd)+(after*100)), 2);
            for  trial = 1:length(tdPlot{i})
                kin{i}(trial,:,:) = tdPlot{i}(trial).vel(tdPlot{i}(trial).(startInd)-(before*100):tdPlot{i}(trial).(startInd)+(after*100),:);
            end
            meanKin = squeeze(mean(kin{i}));
            speedKin = sqrt(meanKin(:,1).^2 + meanKin(:,2).^2);

            plot(linspace(-1*before, after, length(speedKin(:,1))), speedKin(:,1), 'k')
            ylim([0, maxSpeed])
            if plotRasters
                unitRaster(tdPlot{i}, params);
            end
            switch dirs(i)
                case 0
                    subplot(6,3, 12)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {45, pi/4}
                    subplot(6,3, 6)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {90, pi/2}
                    subplot(6,3, 5)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {135,3*pi/4}
                    subplot(6,3, 4)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {180, pi}
                    subplot(6,3, 10)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {225,  5*pi/4}
                    subplot(6,3, 16)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {270, 3*pi/2}
                    subplot(6,3, 17)
                case {315,  7*pi/4}
                    subplot(6,3, 18)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
            end
            hold on
            xlim([-1*before, after])
            
            tdTrim = trimTD(tdPlot{i}, {startInd, -1*before*100}, {startInd, after*100});
            firing = cat(3, tdTrim.(unitSpikes));
            meanMoveFiring = 100*mean(squeeze(firing(:,num1,:)),2);
            bar(linspace(-1*before, after, length(meanMoveFiring)), conv(meanMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
            xlim([-1*before, after])
            maxFiring = max(max(conv(meanMoveFiring, w, 'same')), maxFiring);
        end

        for pt = [4,5,6,10,12,16,17,18]       
            subplot(6,3,pt)
            ylim([0, max(1,1.1*maxFiring)])
        end
        if bumpMove == 1
            bumpHigh =squeeze(bumpTot(num1, 3, :));
            bumpMean = squeeze(bumpTot(num1,1,:));
            bumpLow = squeeze(bumpTot(num1,2,:));

            moveHigh = squeeze(moveTot(num1,3,:));
            moveMean = squeeze(moveTot(num1,1,:));
            moveLow  = squeeze(moveTot(num1,2,:));

            thetaPlot = [theta,theta(1)];
            
            subplot('Position',[.385,.365,.25,.25])

            polarplot(thetaPlot, [moveHigh;moveHigh(1)], 'Color', [.4,.4,1], 'LineWidth', 2)
            hold on
            polarplot(thetaPlot, [moveMean;moveMean(1)], 'Color', [0,0,1], 'LineWidth', 2)
            polarplot(thetaPlot, [moveLow; moveLow(1)], 'Color', [.4,.4,1], 'LineWidth', 2)

            polarplot([angMove(num1), angMove(num1)], [0, max([bumpHigh])], 'Color', [0,0,1],'LineWidth',2);
            set(gca,'TickDir','out', 'box', 'off')
            set(gca,'thetatick',[],'rtick',[])
            suptitle([title1, ' Active'])
            if gracileFlag(num1)
            suptitle([title1, ' Active GRACILE'])
            end
        else
            bumpHigh =squeeze(bumpTot(num1, 3, :));
            bumpMean = squeeze(bumpTot(num1,1,:));
            bumpLow = squeeze(bumpTot(num1,2,:));

            thetaPlot = [theta,theta(1)];

            subplot('Position',[.385,.365,.25,.25])
            polarplot(thetaPlot, [bumpHigh; bumpHigh(1)], 'Color', [1,.4,.4], 'LineWidth', 2)
            hold on 
            polarplot(thetaPlot, [bumpMean;bumpMean(1)], 'Color', [1,0,0], 'LineWidth', 2)
            polarplot(thetaPlot, [bumpLow;bumpLow(1)], 'Color', [1,.4,.4], 'LineWidth', 2)

            polarplot([angBump(num1), angBump(num1)], [0, max([moveHigh])],'Color', [1,0,0], 'LineWidth', 2);
            set(gca,'TickDir','out', 'box', 'off')
            set(gca,'thetatick',[],'rtick',[])
            suptitle([title1, 'passive'])
            if gracileFlag(num1)
            suptitle([title1, ' Passive GRACILE'])
            end
        end
        disp(num1)
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

