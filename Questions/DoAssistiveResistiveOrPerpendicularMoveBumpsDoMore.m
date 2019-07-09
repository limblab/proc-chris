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
tdCBump = getTD(monkey, '20180607', 1);
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
goCueDif = [td.idx_goCueTime] -[td.idx_movement_on];
td = td(goCueDif> -40 & goCueDif <-20);
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];

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
tdNoBump1 = td(isnan([td.idx_bumpTime]));
tdMove = trimTD(td, {'idx_goCueTime', 0}, {'idx_goCueTime', 50});
tdNoBump = td(isnan([td.idx_bumpTime]));
tdNoBump = trimTD(tdNoBump, {'idx_goCueTime', 50}, {'idx_goCueTime', 63});

tdBump = td(~isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, 'idx_bumpTime', {'idx_bumpTime', 13});
for i = 1:length(dirsM)
    tNoBump{i} = tdNoBump([tdNoBump.target_direction] == dirsM(i));
    for j = 1:length(dirsBump)
        tBump{i,j} = tdBump([tdBump.target_direction] == dirsM(i) & [tdBump.bumpDir] == dirsBump(j));
    end
end
for i = 1:length(numCount)
    for p = 1:length(dirsBump)
        tdTemp = tdBump([td.bumpDir] == dirsBump(p));
        bumpFiring = cat(3, tdTemp.cuneate_spikes)/td(1).bin_size;
        
    end
end
%% For each neuron
for i = 1:length(numCount)
    for a = 1:length(dirsM)
        firing = cat(3, tNoBump{a}.cuneate_spikes)/td(1).bin_size;
        meanFiring(i,a) = mean(mean(squeeze(firing(:, i, :))));
        for p = 1:length(dirsBump)
            firing = cat(3, tBump{a, p}.cuneate_spikes)/td(1).bin_size;
            meanFiringBump(i,a, p) = mean(mean(squeeze(firing(:, i, :))));
        end
    end
    
end
%%
params.out_signals = 'cuneate_spikes';
params.out_signal_names = td(1).cuneate_unit_guide;

neurons = getTDPDsSpeedCorr(tdNoBump, params);
%%
tuned = checkIsTuned(neurons, pi/2);
%%
for i = 1:length(numCount)
    [~,maxReachDir]  = max(meanFiring(i,:));
    cwRot = [4, 1,2,3];
    neuronDir(i) = maxReachDir;
    dAssist(i) = (meanFiringBump(i, maxReachDir, maxReachDir) -  meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
    dResist(i) = (meanFiringBump(i, maxReachDir, mod(maxReachDir+2, 4)+1)-  meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
    dPerpCCW(i) = (meanFiringBump(i, maxReachDir, mod(maxReachDir, 4)+1) - meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
    dPerpCW(i) = (meanFiringBump(i, maxReachDir, cwRot(maxReachDir)) -  meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
end
tuned = logical(tuned);
tunedDAssist = dAssist(tuned);
tunedDResist = dResist(tuned);
tunedDPerpCCW = dPerpCCW(tuned);
tunedDPerpCW = dPerpCW(tuned);

%%
figure
scatter(tunedDAssist, tunedDResist)
hold on
plot([-1, 3], [-1, 3])
title('Assistive bumps vs. Resistive Bumps')
axis equal
xlabel('Normalized Assistive FR change')
ylabel('Normalized Resistive FR change')

figure
scatter(tunedDAssist, tunedDPerpCCW)
hold on
plot([-1, 3], [-1, 3])
title('Assistive bumps vs. Perpendicular Bumps (CCW)')
axis equal
xlabel('Normalized Assistive FR change')
ylabel('Normalized CCW FR change')

figure
scatter(tunedDAssist, tunedDPerpCW)
hold on
plot([-1, 3], [-1, 3])
title('Assistive bumps vs. Perpendicular Bumps (CW)')
axis equal
xlabel('Normalized Assistive FR change')
ylabel('Normalized Perpendicular (CW) FR change')
%%
figure
subplot(4, 1,1)
histogram(tunedDAssist, 20)
xlim([-1, 3])
title('Assistive Bump')
subplot(4,1,2)
histogram(tunedDResist, 20)
xlim([-1, 3])
title('Resistive Bump')

subplot(4,1,3)

histogram(tunedDPerpCW, 20)
xlim([-1, 3])
title('Perpendicular CW')
subplot(4,1,4)
histogram(tunedDPerpCCW, 20)
xlim([-1, 3])
title('Perpendicular CCW')
%%
figure
histogram(tunedDAssist,20)
hold on
histogram(tunedDResist, 20)

%%
pos = cat(1, tdNoBump1.pos);
posBump = cat(1, tdBump.pos);
figure
scatter(pos(:,1), pos(:,2))
hold on
scatter(posBump(:,1), posBump(:,2))
title('Bumps during Movement')
xlabel('X Pos (cm)')
ylabel('Y Pos (cm)')
legend({'Normal Reaches', 'Bump Times'})
%%
for i = 1:length(numCount)
    [~,maxReachDir]  = max(meanFiring(i,:));
    cwRot = [4, 1,2,3];
    neuronDir(i) = maxReachDir;
    dAssist(i) = (meanFiringBump(i, maxReachDir, maxReachDir) -  meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
    dResist(i) = (meanFiringBump(i, maxReachDir, mod(maxReachDir+2, 4)+1)-  meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
    dPerpCCW(i) = (meanFiringBump(i, maxReachDir, mod(maxReachDir, 4)+1) - meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
    dPerpCW(i) = (meanFiringBump(i, maxReachDir, cwRot(maxReachDir)) -  meanFiring(i, maxReachDir))/ meanFiring(i, maxReachDir);
end
tuned = logical(tuned);
tunedDAssist = dAssist(tuned);
tunedDResist = dResist(tuned);
tunedDPerpCCW = dPerpCCW(tuned);
tunedDPerpCW = dPerpCW(tuned);
