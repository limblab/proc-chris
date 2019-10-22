% clear all
close all
clear all
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
% 
date = '20191009';
monkey = 'Snap';
unitNames = 'cuneate';
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
% date = '20190822';
% monkey = 'Snap';
% unitNames= 'cuneate';

mappingLog = getSensoryMappings(monkey);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;

td =getTD(monkey, date, 'BD',1);
td = getSpeed(td);

td(isnan([td.idx_bumpTime])) = [];
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


if td(1).bin_size ==.001
    td = binTD(td, 10);
end

td = removeBadNeurons(td, struct('remove_unsorted', false));

unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'rawAlignedPlots',filesep];
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


bumpTrials = td(~isnan([td.correctAngle])); 
dirsBump = unique([td.correctAngle]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));


for i = 1:length(dirsBump)
    tdBump{i}= td([td.correctAngle] == dirsBump(i));
end

%%




    
    tdTemp = td(~isnan([td.bumpDir]));
    preBump = trimTD(tdTemp, {'idx_bumpTime', -10}, {'idx_bumpTime', -5});

    postBump = trimTD(tdTemp, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
    for i = 1:length(dirsBump)
        postBumpDir{i}= postBump([postBump.correctAngle] == dirsBump(i));
        postBumpFiring{i} = cat(3, postBumpDir{i}.(unitSpikes)).*100;
        postBumpStat(i).meanCI(:,1) = squeeze(mean(mean(postBumpFiring{i}, 3),1))';
        postBumpStat(i).meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(postBumpFiring{i}))')';

    end
    preBumpFiring = cat(3, preBump.(unitSpikes)).*100;
    
    preBumpStat.meanCI(:,1) = squeeze(mean(mean(preBumpFiring, 3),1))';
    preBumpStat.meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(preBumpFiring))')';

    bumpTot = cat(3, postBumpStat.meanCI);
    bumpPre = cat(2, preBumpStat.meanCI);
    thetaB = linspace(0, max(dirsBump), length(dirsBump));
%% 
maxSpeed = 60;

paramsBump.yMax = maxSpeed;
paramsBump.align= 'bumpTime';
paramsBump.xBound = [-.3, .3];
paramsBump.array = unitNames;
    
close all
for num1 = numCount
    close all
    clear meanKin
    params.neuron = num1;
    bumpX = sum(squeeze(cos(thetaB)'.*squeeze(bumpTot(num1,1,:)))');
    bumpY = sum(squeeze(sin(thetaB)'.*squeeze(bumpTot(num1,1,:)))');

    angBump(num1) = atan2(bumpY, bumpX);
    
    title1 = [monkey, ' ', unitNames, ' Electrode' num2str(td(1).(unitGuide)(num1,1)), ' Unit ', num2str(td(1).(unitGuide)(num1,2))];
    maxFiring =0;
    for bumpMove = 2
              
        if bumpMove == 2
            clear meanKin
            bump = figure('visible','off');
            before = beforeBump;
            after = afterBump;
            startInd = 'idx_bumpTime';
            params = paramsBump;
            params.neuron = num1;
            tdPlot = tdBump;
            dirs = floor(rad2deg(dirsBump));
            theta = thetaB;
           
        end
        if isMapped

        subplot(7, 3, 19)
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
            daysTxt = ['Days: ', num2str(daysDif)];
        end
        
        tx = text(0,0,txt);
        
        extent = tx.Extent;
     
        xlim([extent(1), extent(1) + extent(3)])
        ylim([extent(2), extent(2) + extent(4)])
        set(gca,'ycolor','w')
        set(gca,'xcolor','w')
        
        subplot(7, 3, 20)
        tx = text(0,0,daysTxt);
        extent = tx.Extent;
        
        xlim([extent(1), extent(1) + extent(3)])
        ylim([extent(2), extent(2) + extent(4)])
        set(gca,'ycolor','w')
        set(gca,'xcolor','w')
        end
        for i = 1:length(dirs)
            switch dirs(i)
                case {0 | 0}
                    subplot(7,3, 9)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {45, pi/4}
                    subplot(7,3, 3)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {90, pi/2}
                    subplot(7,3, 2)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {135, 3*pi/4}
                    subplot(7,3, 1)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {180, pi}
                    subplot(7,3, 7)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {225, 5*pi/4}
                    subplot(7,3, 13)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {270, 3*pi/2}
                    subplot(7,3, 14)
                    hold on
                case {315, 7*pi/4}
                    subplot(7,3, 15)
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
            switch dirs(i)
                case 0
                    subplot(7,3, 12)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {45, pi/4}
                    subplot(7,3, 6)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {90, pi/2}
                    subplot(7,3, 5)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {135,3*pi/4}
                    subplot(7,3, 4)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {180, pi}
                    subplot(7,3, 10)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {225,  5*pi/4}
                    subplot(7,3, 16)
                    set(gca,'TickDir','out', 'box', 'off')
                    set(gca,'xtick',[],'ytick',[])
                case {270, 3*pi/2}
                    subplot(7,3, 17)
                case {315,  7*pi/4}
                    subplot(7,3, 18)
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
        if length(dirs) == 4
            pt1 = [5, 10, 12, 17];
        else
            pt1 = [4,5,6,10,12,16,17,18];
        end
        for pt = pt1    
            subplot(7,3,pt)
            ylim([0, max(1,1.1*maxFiring)])
        end

        

            bumpHigh =squeeze(bumpTot(num1, 3, :));
            bumpMean = squeeze(bumpTot(num1,1,:));
            bumpLow = squeeze(bumpTot(num1,2,:));

            thetaPlot = [theta,theta(1)];

            subplot('Position',[.39,.48,.25,.2])
            polarplot(thetaPlot, [bumpHigh; bumpHigh(1)], 'Color', [1,.4,.4], 'LineWidth', 2)
            hold on 
            polarplot(thetaPlot, [bumpMean;bumpMean(1)], 'Color', [1,0,0], 'LineWidth', 2)
            polarplot(thetaPlot, [bumpLow;bumpLow(1)], 'Color', [1,.4,.4], 'LineWidth', 2)

            polarplot([angBump(num1), angBump(num1)], [0, max([bumpHigh])],'Color', [1,0,0], 'LineWidth', 2);
            set(gca,'TickDir','out', 'box', 'off')
            set(gca,'thetatick',[],'rtick',[])
            suptitle1([title1, 'passive'])
            if gracileFlag(num1)
            suptitle1([title1, ' Passive GRACILE'])
            end
        disp(num1)
    end
    if savePlots
            if gracileFlag(num1)
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, 'Gracile',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), 'GRACILE.pdf'],bump)
                saveas(bump,[savePath,'Gracile',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), 'GRACILE.png'])
            else
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, unitNames,filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.pdf'],bump)
                saveas(bump,[savePath, unitNames,filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.png'])
            end

    end

        
    end

   


%% Short time

