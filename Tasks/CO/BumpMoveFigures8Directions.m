% clear all
close all
clear all
% clearvars -except cds
% load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 1;
savePDF = true;
% params.event_list = {'bumpTime'; 'bumpDir'};
% params.extra_time = [.4,.6];
% params.include_ts = true;
% params.include_start = true;
% params.include_naming = true;
% td = parseFileByTrial(cds, params);
% td = td(~isnan([td.target_direction]));
% params.start_idx =  'idx_goCueTime';
% params.end_idx = 'idx_endTime';
% td = getMoveOnsetAndPeak(td, params);

date = '20181214';
monkey = 'Butter';
unitNames = 'cuneate';

mappingLog = getSensoryMappings(monkey);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO');
td = removeBadNeurons(td);
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'rawAlignedPlots',filesep];
mkdir([savePath, 'Cuneate']);
mkdir([savePath, 'Gracile']);


elec2MapName = td(1).cuneate_naming;
for i = 1:length(td(1).(unitSpikes)(1,:))
    gracileFlag(i) = getGracile('Butter', elec2MapName(elec2MapName(:,1) == td(1).cuneate_unit_guide(i,1),2));
end

w = gausswin(5);
w = w/sum(w);


numCount = 1:length(td(1).(unitSpikes)(1,:));
%% Data Preparation and sorting out trials

dirsM = unique([td.target_direction]);
dirsM = dirsM(~isnan(dirsM));


for i = 1:length(dirsM)
    tdDir{i} = td([td.target_direction] == dirsM(i));
end
bumpTrials = td(~isnan([td.bumpDir])); 
dirsBump = unique([td.bumpDir]);
dirsBump = dirsBump(~isnan(dirsBump));

for i = 1:length(dirsBump)
    tdBump{i}= td([td.bumpDir] == dirsBump(i));
end

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
            suptitle([title1, ' Active'])
            if gracileFlag(num1)
            suptitle([title1, ' Active GRACILE'])
            end
        else
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
                save2pdf([savePath, 'Cuneate',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.pdf'],bump)
                set(move, 'Renderer', 'Painters');
                save2pdf([savePath,'Cuneate', filesep,strrep(title1, ' ', '_'), '_Move_', num2str(date), '.pdf'],move)
                saveas(bump,[savePath, 'Cuneate',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.png'])
                saveas(move,[savePath, 'Cuneate',filesep, strrep(title1, ' ', '_'), '_Move_', num2str(date), '.png'])
            end

    end

        
    end

   


%% Short time

