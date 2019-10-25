% clear all
close all
clear all
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
% 
date = '20190327';
monkey = 'Crackle';
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
afterMove = .6;

td =getTD(monkey, date, 'CO',1);
td = getSpeed(td);

td = smoothSignals(td, struct('signals', [unitNames, '_spikes'], 'calc_rate',true, 'width', .03));

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
td = removeUnsorted(td);
guide = td(1).cuneate_unit_guide;
tdAct = trimTD(td, 'idx_movement_on', {'idx_movement_on', 13});
tdPas = td(~isnan([td.idx_bumpTime]));
tdPas = trimTD(tdPas, 'idx_bumpTime', {'idx_bumpTime', 13});
%%
actFR = cat(1, tdAct.cuneate_spikes);
pasFR = cat(1, tdPas.cuneate_spikes);

velAct = cat(1,tdAct.vel);
velPas = cat(1, tdPas.vel);
ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'MM/dd/yyyy')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
sAct = zeros(length(ml),1);
sPas = zeros(length(ml),1);
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

mappedSorted = ml(mapped);
sAct = sAct(mapped);
sPas = sPas(mapped);
spindle = spindle(mapped);
%%
figure
scatter(sAct(spindle), sPas(spindle),'r', 'filled')
hold on
scatter(sAct(~spindle'), sPas(~spindle),'b', 'filled')
legend({'Spindles', 'Non-spindles'})
plot([0, 3], [0,3])
xlabel('Active sensitivity')
ylabel('Passive sensitivity')
title('Act vs pas sensitivity')
fitlm(sAct(spindle), sPas(spindle))