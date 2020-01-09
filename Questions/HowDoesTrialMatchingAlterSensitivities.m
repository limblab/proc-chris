% clear all
close all
clearvars -except td1 td2 td3
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
smoothWidth = .01;
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

    switch mon
        case 1
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
                
            end
            td = td1;
        case 2
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

            end
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
                td3 = getSpeed(td3);
                td3 = smoothSignals(td3, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td3 = getNorm(td3,struct('signals','vel','field_extra','speed'));
                td3 = getMoveOnsetAndPeak(td3,params);

            end

            td = td3;
    end
    
    td = td(~isnan([td.idx_movement_on]));
    
    td = removeBadNeurons(td, struct('remove_unsorted', false));
    td = removeUnsorted(td);
    td = removeGracileTD(td);
    td = removeNeuronsBySensoryMap(td, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
    td = removeHighSpeedAtOnset(td);

    guide = td(1).cuneate_unit_guide;
    tdAct = trimTD(td, {'idx_peak_speed', -13}, {'idx_peak_speed', 0});
    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, 'idx_bumpTime', {'idx_bumpTime', 13});
    
    dirsM = unique([td.target_direction]);
    dirsM(isnan(dirsM)) = [];
    dirsM(mod(dirsM, pi/4) ~=0) = [];
    
    dirsB = unique([td.bumpDir]);
    dirsB(isnan(dirsB)) = [];
    dirsB(mod(dirsB, 45) ~=0) = [];
    
    tdActNew =[];
    tdPasNew =[];
    for i = 1:length(dirsM)
        tdAct1 = tdAct([tdAct.target_direction] == dirsM(i));
        tdPas1 = tdPas([tdPas.bumpDir] == dirsB(i));
        velAct =  cat(3, tdAct1.vel);
        velPas = cat(3, tdPas1.vel);
        dists = zeros(length(velAct(1,1,:)), length(velPas(1,1,:)));
        
        for j = 1:length(velAct(1,1,:))
            for k = 1:length(velAct(1,1,:))
                selfDistsAct(j,k) = norm(reshape(velAct(:,:,j),[],1) - reshape(velAct(:,:,k), [],1));
            end
        end
        
        for j = 1:length(velPas(1,1,:))
            for k = 1:length(velPas(1,1,:))
                selfDistsPas(j,k) = norm(reshape(velPas(:,:,j),[],1) - reshape(velPas(:,:,k), [],1));
            end
        end
        
        sSimAct = reshape(triu(selfDistsAct), [], 1);
        sSimAct(sSimAct ==0) = [];
        
        sSimPas = reshape(triu(selfDistsPas), [], 1);
        sSimPas(sSimPas ==0) = [];
        
        
        
        for j = 1:length(velAct(1,1,:))
            for k = 1:length(velPas(1,1,:))
                dists(j,k) = norm(reshape(velAct(:,:,j), [],1) - reshape(velPas(:,:,k), [],1));
            end
        end
        minAct = min(dists');
        [sMinAct, sMinActInds] = sort(minAct);
        sDists = dists(sMinActInds,:);
        maps = [];
        mDists = [];
        for j = 1:length(sDists(:,1))
            [m, mInd] = min(sDists(j,:));
            mDists = [mDists; sDists(j,mInd)];
            maps = [maps;sMinActInds(j), mInd];
            sDists(:,mInd) =  100000000;
        end
        tdAct1 = tdAct1(maps(1:floor(length(maps(:,1))/2),1));
        tdPas1 = tdPas1(maps(1:floor(length(maps(:,1))/2),2));
        
        
        vA = cat(1,tdAct1.vel);
        vP = cat(1,tdPas1.vel);
        
        sA = cat(2,tdAct1.speed);
        sP = cat(2,tdPas1.speed);
        
        figure
        scatter(vA(:,1), vA(:,2), 'r', 'filled')
        hold on
        scatter(vP(:,1), vP(:,2), 'b', 'filled')
        legend('Active', 'Passive')

        figure
        plot(sA, 'r')
        hold on
        plot(sP, 'b')
        
       tdActNew = [tdActNew, tdAct1];
       tdPasNew = [tdPasNew, tdPas1];
    end
    actFR = cat(1, tdActNew.cuneate_spikes);
    pasFR = cat(1, tdPasNew.cuneate_spikes);

    velAct = cat(1,tdActNew.vel);
    velPas = cat(1, tdPasNew.vel);
    
    speedAct = cat(2,tdActNew.speed);
    speedPas = cat(2,tdPasNew.speed);
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
%                 figure
%                 plot(lmAct)
%                 hold on
%                 plot(lmPas)
%                 title(['Elec ', num2str(guide(i,1))])
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
    
    max1 = max([sAct; sPas]);
    
    figure
    scatter(sAct(spindle), sPas(spindle),'r', 'filled')
    hold on
    scatter(sAct(~spindle'), sPas(~spindle),'b', 'filled')
    legend({'Spindles', 'Non-spindles'})
    plot([0, max1], [0,max1])
    xlabel('Active sensitivity')
    ylabel('Passive sensitivity')
    title([monkey, 'Act vs pas sensitivity'])
    for i = 1:length(sAct)
        dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
        text(sAct(i)+ dx, sPas(i) +dy, num2str(mGuide(i)));
    end
    
    fitlm(sAct(spindle), sPas(spindle),'Intercept',false)

end