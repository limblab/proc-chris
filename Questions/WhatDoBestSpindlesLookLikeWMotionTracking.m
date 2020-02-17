% clear all
close all
clearvars -except td1 td2 td3
plotRasters = 1;
smoothWidth = .01;
windowInds = true;
% 
monkey1 = 'Butter';
date1 = '20180326';
task1 = 'CO';
num1 = 1;

monkey2 = 'Lando';
date2 = '20170917';
task2 = 'CO';
num2 = 1;

monkey3 = 'Snap';
date3 = '20190829';
task3 = 'CO';
num3 = 2;

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;

monkeyArray = {monkey1, date1, task1, num1;...
               monkey2, date2, task2, num2;...
               monkey3, date3, task3, num3};

for mon = 1:3
    monkey = monkeyArray{mon, 1};
    date = monkeyArray{mon, 2};
    task = monkeyArray{mon, 3};
    num = monkeyArray{mon, 4};
    
    mappingLog = getSensoryMappings(monkey);

    switch mon
        case 1
            array = 'cuneate';
            if ~exist('td1')
                td1 = getTD(monkey, date, task,num);
                if td1(1).bin_size ==.001
                    td1 = binTD(td1, 10);
                end
                td1 = getSpeed(td1);
                td1 = smoothSignals(td1, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td1 = getNorm(td1,struct('signals','vel','field_extra','speed'));
                td1 = getMoveOnsetAndPeak(td1,params);
                td1 = td1(~isnan([td1.idx_movement_on]));
    
                td1 = removeBadNeurons(td1, struct('remove_unsorted', false));
                td1 = removeUnsorted(td1);
                td1 = removeGracileTD(td1);
                td1 = removeNeuronsBySensoryMap(td1, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
                td1 = removeNeuronsByNeuronStruct(td1, struct('flags', {{'~handPSTHMan'}}));
                
            end
            td = td1;
        case 2
            array = 'cuneate';

            if ~exist('td2')
                td2 = getTD(monkey, date, task,num);
                if td2(1).bin_size ==.001
                    td2 = binTD(td2, 10);
                end
                td2 = getSpeed(td2);
                td2 = smoothSignals(td2, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td2 = getNorm(td2,struct('signals','vel','field_extra','speed'));
                td2 = getMoveOnsetAndPeak(td2,params);
                td2 = td2(~isnan([td2.idx_movement_on]));

                td2 = removeBadNeurons(td2, struct('remove_unsorted', false));
                td2 = removeUnsorted(td2);
                td2 = removeGracileTD(td2);
%                 td2 = removeNeuronsBySensoryMap(td2, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
%                 td2 = removeNeuronsByNeuronStruct(td2, struct('flags', {{'~handPSTHMan'}}));

            end
            td = td2;
        case 3
            array = 'cuneate';

            if ~exist('td3')
                td3 = getTD(monkey, date, task,num);
                for i = 1:length(td3)
                    td3(i).opensim = [];
                end
                if td3(1).bin_size ==.001
                    td3 = binTD(td3, 10);
                end
                td3 = getSpeed(td3);
                td3 = smoothSignals(td3, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td3 = getNorm(td3,struct('signals','vel','field_extra','speed'));
                td3 = getMoveOnsetAndPeak(td3,params);
                td3 = td3(~isnan([td3.idx_movement_on]));
    
                td3 = removeBadNeurons(td3, struct('remove_unsorted', false));
                td3 = removeUnsorted(td3);
%                 td3 = removeGracileTD(td3);
%                 td3 = removeNeuronsBySensoryMap(td3, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
%                 td3 = removeNeuronsByNeuronStruct(td3, struct('flags', {{'~handPSTHMan'}}));

            end
            td = td3;     
    end
    
end

