% clear all
close all
clearvars -except td1 td2 td3 td4 td5
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
savePath = 'C:\Users\wrest\Pictures\ActPasKinComparison\';
mkdir(savePath)
% 

monkey1 = 'Butter';
date1 = '20190129';
task1 = 'CO';
num1 = 2;

monkey2 = 'Crackle';
date2 = '20190418';
task2 = 'CO';
num2 = 1;

monkey3 = 'Snap';
date3 = '20190829';
task3 = 'CO';
num3 = 2;

monkey4 = 'Han';
date4 = '20171122';
task4 = 'COactpas';
num4 = 1;

monkey5 = 'Duncan';
date5 = '20190710';
task5 = 'CObumpmove';
num5 = 1;



beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;

monkeyArray = {monkey1, date1, task1, num1;...
               monkey2, date2, task2, num2;...
               monkey3, date3, task3, num3;...
               monkey4, date4, task4, num4;...
               monkey5, date5, task5, num5};


for mon = 1:5
    monkey = monkeyArray{mon, 1};
    date = monkeyArray{mon, 2};
    task = monkeyArray{mon, 3};
    num = monkeyArray{mon, 4};
    
    mappingLog = getSensoryMappings(monkey);

    switch mon
        case 1
            if ~exist('td1')

                td1 = getTD(monkey, date, task,num);
                if td1(1).bin_size ==.001
                    td1 = binTD(td1, 10);
                end
                
                td1 = getSpeed(td1);
                td1 = smoothSignals(td1, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td1 = getNorm(td1,struct('signals','vel','field_extra','speed'));
                td1 = getMoveOnsetAndPeak(td1,params);
            end
            
                array = 'cuneate';

                unit_guide = [array, '_unit_guide'];
            td = td1;
        case 2
            if ~exist('td2')

                td2 = getTD(monkey, date, task,num);
                if td2(1).bin_size ==.001
                    td2 = binTD(td2, 10);
                end
                
                array = 'cuneate';

                unit_guide = [array, '_unit_guide'];
                td2 = getSpeed(td2);
                td2 = smoothSignals(td2, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .03));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td2 = getNorm(td2,struct('signals','vel','field_extra','speed'));
                td2 = getMoveOnsetAndPeak(td2,params);

            end
            
                array = 'cuneate';

                unit_guide = [array, '_unit_guide'];
            td = td2;
        case 3
            if ~exist('td3')

                td3 = getTD(monkey, date, task,num);
                for i = 1:length(td3)
                    td3(i).opensim = [];
                end
                if td3(1).bin_size ==.001
                    td3 = binTD(td3, 10);
                end
                array = 'cuneate';

                unit_guide = [array, '_unit_guide'];
                td3 = getSpeed(td3);
                td3 = smoothSignals(td3, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td3 = getNorm(td3,struct('signals','vel','field_extra','speed'));
                td3 = getMoveOnsetAndPeak(td3,params);

            end

                array = 'cuneate';

                unit_guide = [array, '_unit_guide'];
            td = td3;
        case 4 
            if ~exist('td4')
                array = 'LeftS1Area2';
                unit_guide = [array, '_unit_guide'];

                td4 = getTD(monkey, date, task,num);
                for i = 1:length(td4)
                    td4(i).opensim = [];
                end
                if td4(1).bin_size ==.001
                    td4 = binTD(td4, 10);
                end
                
                td4 = getSpeed(td4);
                td4 = smoothSignals(td4, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .03));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td4 = getNorm(td4,struct('signals','vel','field_extra','speed'));
                td4 = getMoveOnsetAndPeak(td4,params);

            end

                array = 'LeftS1Area2';
                unit_guide = [array, '_unit_guide'];
            td = td4;

        case 5 
            if ~exist('td5')
                array = 'leftS1';
                unit_guide = [array, '_unit_guide'];

                td5 = getTD(monkey, date, task,num);
                for i = 1:length(td5)
                    td5(i).opensim = [];
                end
                if td5(1).bin_size ==.001
                    td5 = binTD(td5, 10);
                end
                
                td5 = getSpeed(td5);
                td5 = smoothSignals(td5, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .03));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td5 = getNorm(td5,struct('signals','vel','field_extra','speed'));
                td5 = getMoveOnsetAndPeak(td5,params);

            end
                if strcmp(monkey, 'Duncan') 
                    td(~isnan([td.idx_bumpTime]) & [td.idx_goCueTime]< [td.idx_bumpTime])=[];
                end
                array = 'leftS1';
                unit_guide = [array, '_unit_guide'];
            td = td5;
    end
    

        
    guide = td(1).(unit_guide);
    tdAct = trimTD(td(~isnan([td.idx_movement_on])), {'idx_movement_on', -20}, {'idx_movement_on', 20});
    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, {'idx_bumpTime',-20}, {'idx_bumpTime', 20});
    if mon~=1
        tdAct(~isnan([tdAct.bumpDir]))=[];
    end
    dirsM = unique([td.target_direction]);
    dirsM(isnan(dirsM)) = [];
    dirsM(mod(dirsM, pi/4) ~=0) = [];
    
    dirsB = unique([td.bumpDir]);
    dirsB(isnan(dirsB)) = [];
    dirsB(mod(dirsB, 45) ~=0) = [];
    
    spdAllAct = squeeze(cat(3, tdAct.speed));
    spdAllPas = squeeze(cat(3, tdPas.speed));
    figure
    plot(10:10:10*length(spdAllAct(:,1)), mean(spdAllAct'),'b')
    hold on
    plot(10:10:10*length(spdAllAct(:,1)), mean(spdAllPas'),'r')
    xlabel('Time (ms)')
    ylabel('Speed (average across all directions)')
    title(monkey)
    
    spdFig = figure();
    
    
    for dir = 1:length(dirsM)
        posAct = cat(1, tdAct([tdAct.target_direction] == dirsM(dir)).pos);
        spdAct = squeeze(cat(3, tdAct([tdAct.target_direction] == dirsM(dir)).speed));
        
        posPas = cat(1, tdPas([tdPas.bumpDir] == dirsB(dir)).pos);
        spdPas = squeeze(cat(3, tdPas([tdPas.bumpDir] == dirsB(dir)).speed));
        spdFig;
        switch dir
            case 1
                subplot(3,3, 6,'Parent', spdFig)

            case 2
                subplot(3,3, 3,'Parent', spdFig)
                
            case 3
                subplot(3,3, 2,'Parent', spdFig)
                
            case 4
                subplot(3,3, 1,'Parent', spdFig)
                
            case 5
                subplot(3,3, 4,'Parent', spdFig)
                
            case 6
                subplot(3,3, 7,'Parent', spdFig)
                
            case 7
                subplot(3,3, 8,'Parent', spdFig)
                
            case 8
                subplot(3,3, 9,'Parent', spdFig)
                
        end
        plot(10:10:10*length(spdAct(:,1)),mean(spdAct'), 'b')
        hold on
        plot(10:10:10*length(spdAct(:,1)),mean(spdPas'), 'r')
%        
    end
        suptitle(monkey)
        
    suffix = monkey;
    if savePlots

      saveas(gca, [savePath, 'ActPasSpeed', suffix, '.pdf']);
      saveas(gca, [savePath, 'ActPasSpeed' ,suffix, '.png']);
    end
    posFig = figure();

    for dir = 1:length(dirsM)
        posAct = cat(1, tdAct([tdAct.target_direction] == dirsM(dir)).pos);
        
        posPas = cat(1, tdPas([tdPas.bumpDir] == dirsB(dir)).pos);
        
        switch dir
            case 1
                subplot(3,3, 6,'Parent', posFig)

            case 2
                subplot(3,3, 3,'Parent', posFig)
                
            case 3
                subplot(3,3, 2,'Parent', posFig)
                
            case 4
                subplot(3,3, 1,'Parent', posFig)
                
            case 5
                subplot(3,3, 4,'Parent', posFig)
                
            case 6
                subplot(3,3, 7,'Parent', posFig)
                
            case 7
                subplot(3,3, 8,'Parent', posFig)
                
            case 8
                subplot(3,3, 9,'Parent', posFig)
                
        end
        scatter(posAct(:,1), posAct(:,2), 'b', 'filled')
        hold on
        scatter(posPas(:,1), posPas(:,2), 'r', 'filled')
%         title(['Direction ' , num2str(dirsM(dir))])
%         legend('Active', 'Passive')
        xlim([-20, 20])
        ylim([-50, -10])
    end
    suptitle(monkey)
    suffix = monkey;
    if savePlots

      saveas(gca, [savePath, 'ActPasPosition', suffix, '.pdf']);
      saveas(gca, [savePath, 'ActPasPosition' ,suffix, '.png']);
    end

end