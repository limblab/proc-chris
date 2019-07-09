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

date = '20180530';
monkey = 'Butter';
unitNames= 'cuneate';

% mappingLog = getSensoryMappings(monkey);

before = .3;
after = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'COmoveBump',1);
td = getNorm(td,struct('signals','vel','field_extra','speed'));
startInd = 'idx_bumpTime';

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
td = getMoveOnsetAndPeak(td,params);

if td(1).bin_size ==.001
    td = binTD(td, 10);
end
td = td(~isnan([td.idx_movement_on]));
td = removeBadNeurons(td, struct('remove_unsorted', false));
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'rawAlignedPlots',filesep];
if contains(unitNames, 'cuneate')
    mkdir([savePath, 'Cuneate']);
    mkdir([savePath, 'Gracile']);

    if isfield(td(1),'cuneate_naming')
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
w = gausswin(5);
w = w/sum(w);


numCount = 1:length(td(1).(unitSpikes)(1,:));
%% Data Preparation and sorting out trials

dirsM = unique([td.(target_direction)]);
dirsM = dirsM(~isnan(dirsM));
bumpTrials = td(~isnan([td.bumpDir])); 
dirsBump = unique([td.bumpDir]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));

for i = 1:length(dirsM)
    for j= 1:length(dirsBump)
        tdDir{i,j} = td([td.(target_direction)] == dirsM(i)& [td.bumpDir] == dirsBump(j));
    end
end
maxSpeed = 60;

%%
for num1 = numCount
    close all
    params.neuron = num1;
    title1 = [monkey, ' ', unitNames, ' Electrode' num2str(td(1).(unitGuide)(num1,1)), ' Unit ', num2str(td(1).(unitGuide)(num1,2))];

    for i = 1:length(dirsM)
        maxFiring = 0;
        fhT{i} = figure;
        for j = 1:length(dirsBump)
            switch dirsBump(j)
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

            kin{i} = zeros(length(tdDir{i,j}), length(tdDir{i,j}(1).(startInd)-(before*100):tdDir{i,j}(1).(startInd)+(after*100)), 2);
            for  trial = 1:length(tdDir{i,j})
                kin{i}(trial,:,:) = tdDir{i,j}(trial).vel(tdDir{i,j}(trial).(startInd)-(before*100):tdDir{i,j}(trial).(startInd)+(after*100),:);
            end
            meanKin = squeeze(mean(kin{i}));
            speedKin = sqrt(meanKin(:,1).^2 + meanKin(:,2).^2);

            plot(linspace(-1*before, after, length(speedKin(:,1))), speedKin(:,1), 'k')
            ylim([0, maxSpeed])
            if plotRasters
                params.xBound = [-1*before*(1/tdDir{i,j}(1).bin_size), after*(1/tdDir{i,j}(1).bin_size)];
                params.align = 'bumpTime';
                unitRaster(tdDir{i,j}, params);
            end
            switch dirsBump(j)
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
            
            tdTrim = trimTD(tdDir{i,j}, {startInd, -1*before*100}, {startInd, after*100});
            firing = cat(3, tdTrim.(unitSpikes));
            meanMoveFiring = 100*mean(squeeze(firing(:,num1,:)),2);
            bar(linspace(-1*before, after, length(meanMoveFiring)), conv(meanMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
            xlim([-1*before, after])
            maxFiring = max(max(conv(meanMoveFiring, w, 'same')), maxFiring);
            suptitle(['ReachDir: ', num2str(dirsM(i)), ' Elec: ' , num2str(td(1).(unitGuide)(num1,1)), ' Unit: ', num2str(td(1).(unitGuide)(num1,2))])
        end
        if gracileFlag(num1)
            set(fhT{i}, 'Renderer', 'Painters');
            save2pdf([savePath, 'Gracile',filesep, strrep(title1, ' ', '_'),'_', num2str(dirsM(i)),'_', num2str(date), 'GRACILE.pdf'],fhT{i})
            saveas(fhT{i},[savePath,'Gracile',filesep, strrep(title1, ' ', '_'),'_', num2str(dirsM(i)),'_', num2str(date), 'GRACILE.png'])
        else
            set(fhT{i}, 'Renderer', 'Painters');
            save2pdf([savePath, 'Cuneate',filesep, strrep(title1, ' ', '_'),'_', num2str(dirsM(i)),'_', num2str(date), '.pdf'],fhT{i})
            saveas(fhT{i},[savePath,'Cuneate',filesep, strrep(title1, ' ', '_'),'_', num2str(dirsM(i)),'_', num2str(date), '.png'])
        end
    end
end

%% Short time

