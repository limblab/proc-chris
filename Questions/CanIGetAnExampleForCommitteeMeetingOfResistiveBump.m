% clear all
close all
clearvars -except td1 td2 td3
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
smoothWidth = .03;
windowInds = true;
savePath = 'C:\Users\wrest\Pictures\ActPasDomainComparison\';
% 
monkey1 = 'Snap';
date1 = '20191106';
task1 = 'COmovebump';
num1 = 2;

if ~exist('td3')
    td3 = getTD(monkey1, date1, task1,num1);

    if td3(1).bin_size ==.001
        td3 = binTD(td3, 10);
    end
    td3 = getSpeed(td3);

    target_direction = 'target_direction';

    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td3 = getNorm(td3,struct('signals','vel','field_extra','speed'));
    td3 = getMoveOnsetAndPeak(td3,params);
end
td2 = smoothSignals(td3, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));
td2 = removeUnsorted(td2);
guide = td2(1).cuneate_unit_guide;

unitInd = find(guide(:,1)== 82);


nonBumps = td2(isnan([td3.idx_bumpTime]));
bumpTrials = td2(~isnan([td3.idx_bumpTime]));

bumpTrialsAss = bumpTrials(deg2rad(mod([bumpTrials.bumpDir], 360)) == [bumpTrials.target_direction]);
bumpTrialsRes = bumpTrials(deg2rad(mod([bumpTrials.bumpDir] ,360)) ~= [bumpTrials.target_direction]);


dirsM = unique([td2.target_direction]);
dirsM(isnan(dirsM)) = [];
dirsM(mod(dirsM, pi/4) ~=0) = [];

dirsB = unique([td2.bumpDir]);
dirsB(isnan(dirsB)) = [];
dirsB(mod(dirsB, 45) ~=0) = [];

preMoveBumpRAll = [];
eMoveBumpRAll = [];
lMoveBumpRAll = [];

preMoveBumpAAll = [];
eMoveBumpAAll = [];
lMoveBumpAAll = [];
bumpTrialsRes = trimTD(bumpTrialsRes, 'idx_movement_on', 'idx_endTime');
bumpTrialsAss = trimTD(bumpTrialsAss, 'idx_movement_on', 'idx_endTime');
nonBumps = trimTD(nonBumps, 'idx_movement_on', 'idx_endTime');

for i = 1:length(dirsM)
    res = bumpTrialsRes([bumpTrialsRes.target_direction] == dirsM(i));
    ass = bumpTrialsAss([bumpTrialsAss.target_direction] == dirsM(i));
    no = nonBumps([nonBumps.target_direction]== dirsM(i));
    [frRes(i,:), resCI(i,:,:)] = getMeanTD(res, struct('signal', 'cuneate_spikes'));
    [frAss(i,:), assCI(i,:,:)] = getMeanTD(ass, struct('signal', 'cuneate_spikes'));
    [frNo(i,:), noCI(i,:,:)] = getMeanTD(no, struct('signal', 'cuneate_spikes'));
end
%%
theta = linspace(0,2*pi, 9);
for i = 1:length(guide)
    figure
    polarplot(theta, [frNo(:,i);frNo(1,i)], 'r')
    hold on
    polarplot(theta, [frRes(:,i);frRes(1,i)], 'g')
%     polarplot(theta, [frAss(:,i);frAss(1,i)], 'b')
    legend('No bump', 'Resistive Bump')
    
    polarplot(theta, [squeeze(noCI(:,1,i));squeeze(noCI(1,1,i))], 'r','HandleVisibility','off')
    polarplot(theta, [squeeze(noCI(:,2,i));squeeze(noCI(1,2,i))], 'r','HandleVisibility','off')
    
    polarplot(theta, [squeeze(resCI(:,1,i));squeeze(resCI(1,1,i))], 'g','HandleVisibility','off')
    polarplot(theta, [squeeze(resCI(:,2,i));squeeze(resCI(1,2,i))], 'g','HandleVisibility','off')
    
%     polarplot(theta, [squeeze(assCI(:,1,i));squeeze(assCI(1,1,i))], 'b','HandleVisibility','off')
%     polarplot(theta, [squeeze(assCI(:,2,i));squeeze(assCI(1,2,i))], 'b','HandleVisibility','off')
%     
end
