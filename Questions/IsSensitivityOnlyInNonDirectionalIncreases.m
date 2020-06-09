% clear all
close all
clearvars -except td1 td2 td3 td4 td5

recompute = true;
smoothWidth = .02;
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

sActSpindleComb =[];
sPasSpindleComb = [];

sActNSpindleComb =[];
sPasNSpindleComb =[];

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;
monkeyArray = {monkey1, date1, task1, num1;...
               monkey2, date2, task2, num2;...
               monkey3, date3, task3, num3;...
               monkey4, date4, task4, num4;...
               monkey5, date5, task5, num5};

cnSAct = [];
cnSPas = [];
if recompute
for mon = 1:5
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


                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td1 = getNorm(td1,struct('signals','vel','field_extra','speed'));
                td1 = getMoveOnsetAndPeak(td1,params);
                td1 = td1(~isnan([td1.idx_movement_on]));

                
            end
            td1 = addSensoryMappingToGuide(td1);
            td1 = removeBadNeurons(td1, struct('remove_unsorted', false));
            td1 = removeUnsorted(td1);
            td1 = removeGracileTD(td1);
            td1 = removeNeuronsBySensoryMap(td1, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
            td1 = removeNeuronsByNeuronStruct(td1, struct('flags', {{'~handPSTHMan'}}));
            td = td1;
            mappingGuide{mon} = td(1).cuneate_mapping_guide;

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

            end
            td2 = addSensoryMappingToGuide(td2);

            td2 = removeBadNeurons(td2, struct('remove_unsorted', false));
            td2 = removeUnsorted(td2);
            td2 = removeGracileTD(td2);
            td2 = removeNeuronsBySensoryMap(td2, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
            td2 = removeNeuronsByNeuronStruct(td2, struct('flags', {{'~handPSTHMan'}}));

            td = td2;
            mappingGuide{mon} = td(1).cuneate_mapping_guide;

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
    

            end
%             td3 = removeVisually(td3);
            td3 = addSensoryMappingToGuide(td3);

            td3 = removeBadNeurons(td3, struct('remove_unsorted', false));
            td3 = removeUnsorted(td3);
            td3 = removeGracileTD(td3);
            td3 = removeNeuronsBySensoryMap(td3, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
            td3 = removeNeuronsByNeuronStruct(td3, struct('flags', {{'~handPSTHMan'}}));

            td = td3;
            mappingGuide{mon} = td(1).cuneate_mapping_guide;

        case 4
            array = 'LeftS1Area2';

            if ~exist('td4')
                td4 = getTD(monkey, date, task,num);
                if td4(1).bin_size ==.001
                    td4 = binTD(td4, 10);
                end
                td4 = getSpeed(td4);
                td4 = smoothSignals(td4, struct('signals', ['LeftS1Area2_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td4 = getNorm(td4,struct('signals','vel','field_extra','speed'));
                td4 = getMoveOnsetAndPeak(td4,params);

            end
            td4 = removeUnsorted(td4);
            td = td4;
            
        case 5
            array = 'leftS1';

            if ~exist('td5')
                td5 = getTD(monkey, date, task,num);
                if td5(1).bin_size ==.001
                    td5 = binTD(td5, 10);
                end
                td5 = getSpeed(td5);
                td5 = smoothSignals(td5, struct('signals', ['leftS1_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td5 = getNorm(td5,struct('signals','vel','field_extra','speed'));
                td5 = getMoveOnsetAndPeak(td5,params);
                td5(~isnan([td5.idx_bumpTime]) & [td5.idx_bumpTime]>[td5.idx_goCueTime]) =[];
            end
            td5 = removeUnsorted(td5);
            td5(isnan([td5.idx_movement_on]))= [];
            td = td5;
            
    end
    guide = td.cuneate_unit_guide;
    tdPre = trimTD(td, {'idx_goCueTime',-10}, {'idx_goCueTime', -5});
    preAvg = mean(cat(1,tdPre.cuneate_spikes));
    dirsM = unique([td.target_direction]);
    dirsM(isnan(dirsM)) = [];
    dirsB = unique([td.bumpDir]);
    dirsB(isnan(dirsB)) = [];
    
    avgFR = zeros(8, length(guide(:,1)));
    
    tdAct = trimTD(td, 'idx_movement_on', {'idx_movement_on', 13});
    tdPas = trimTD(td(~isnan([td.idx_bumpTime])), 'idx_bumpTime', {'idx_bumpTime',13});
    for i = 1:length(dirsM)
        tdDir = td([td.target_direction] == dirsM(i));
        tdDir = trimTD(tdDir, 'idx_movement_on', {'idx_movement_on',13});
        avgFR(i,:) = mean(cat(1,tdDir.cuneate_spikes));
    end
    for i = 1:length(avgFR(1,:))
        frDown(i) = any(avgFR(:,i) < preAvg(i));
        frAct = cat(1,tdAct.cuneate_spikes);
        frPas = cat(1,tdPas.cuneate_spikes);
        velAct = cat(1, tdAct.vel);
        velPas = cat(1, tdPas.vel);
        
        lmAct = fitlm(velAct, frAct(:,i));
        lmPas = fitlm(velPas, frPas(:,i));
        
        sAct(i) = norm(lmAct.Coefficients.Estimate(2:3));
        sPas(i) = norm(lmPas.Coefficients.Estimate(2:3));

    end
    sMonAct{mon} = sAct;
    sMonPas{mon} = sPas;
    frMonDown{mon}  = frDown;
end
end
%%
colors = linspecer(3);
figure
keyboard
for mon = 1:3
    hold on
    scatter(sMonPas{mon}(frMonDown{mon}), sMonAct{mon}(frMonDown{mon}), 32, colors(mon,:), 'filled')
end
plot([0, 2.5], [0,2.5])