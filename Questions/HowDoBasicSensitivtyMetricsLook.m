% clear all
close all
clear all
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
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

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;

monkeyArray = {monkey1, date1, task1, num1;...
               monkey2, date2, task2, num2;...
               monkey3, date3, task3, num3};


for mon = 3
    monkey = monkeyArray{mon, 1};
    date = monkeyArray{mon, 2};
    task = monkeyArray{mon, 3};
    num = monkeyArray{mon, 4};
    
    mappingLog = getSensoryMappings(monkey);
    td =getTD(monkey, date, task,num);
    td = getSpeed(td);
    td = smoothSignals(td, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));
    
    target_direction = 'target_direction';

    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getNorm(td,struct('signals','vel','field_extra','speed'));
    td = getMoveOnsetAndPeak(td,params);
    
    if td(1).bin_size ==.001
        td = binTD(td, 10);
    end

    td = td(~isnan([td.idx_movement_on]));
    td = removeBadNeurons(td, struct('remove_unsorted', false));
    td = removeUnsorted(td);
    guide = td(1).cuneate_unit_guide;
    tdAct = trimTD(td, 'idx_movement_on', {'idx_movement_on', 13});
    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, 'idx_bumpTime', {'idx_bumpTime', 13});
    
    actFR = cat(1, tdAct.cuneate_spikes);
    pasFR = cat(1, tdPas.cuneate_spikes);

    velAct = cat(1,tdAct.vel);
    velPas = cat(1, tdPas.vel);
    if ~contains(mappingLog(1).date, '/')
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'yyyyMMdd')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    else
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'MM/dd/yyyy')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    end
    sAct = zeros(length(ml),1);
    sPas = zeros(length(ml),1);   
    mapped = false(length(guide(:,1)),1);
    for i = 1:length(guide)
        unit = find([ml.elec] == guide(i,1));
        if ~isempty(unit)
            mapped(i) = true;
            lmAct = fitlm(velAct, actFR(:,i));
            sAct(i) = norm(lmAct.Coefficients.Estimate(2:3));
            lmPas = fitlm(velPas, pasFR(:,i));
            sPas(i) = norm(lmPas.Coefficients.Estimate(2:3));
            if ml(unit).spindle
                spindle(i) = true;
            else
                spindle(i) = false;
            end
        else
            sAct(i) = 0;
            sPas(i) = 0;
            mapped(i) = false;
        end
    end
    mGuide = guide(mapped);
    sAct = sAct(mapped);
    sPas = sPas(mapped);
    spindle = spindle(mapped);
    
    figure
    scatter(sAct(spindle), sPas(spindle),'r', 'filled')
    hold on
    scatter(sAct(~spindle'), sPas(~spindle),'b', 'filled')
    legend({'Spindles', 'Non-spindles'})
    plot([0, 3], [0,3])
    xlabel('Active sensitivity')
    ylabel('Passive sensitivity')
    title('Act vs pas sensitivity')
    for i = 1:length(sAct)
        dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
        text(sAct(i)+ dx, sPas(i) +dy, num2str(mGuide(i)));
    end
    fitlm(sAct(spindle), sPas(spindle))
end



