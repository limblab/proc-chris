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

unitInd = find(guide(:,1)== 83);


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


for i = 1:length(dirsM)
    nonBumps1 = nonBumps([nonBumps.target_direction] == dirsM(i));
    bumpsA = bumpTrialsAss([bumpTrialsAss.target_direction]== dirsM(i));
    bumpsR = bumpTrialsRes([bumpTrialsRes.target_direction]== dirsM(i));
    rT(i) = floor(mean([nonBumps1.idx_movement_on] - [nonBumps1.idx_goCueTime]));
    nB = trimTD(nonBumps1, 'idx_movement_on', {'idx_movement_on', 30});
    pkInds = [nB.idx_peak_speed];
    pkInds(isnan(pkInds)) = [];
    pkInd(i) = floor(mean(pkInds));
    preMoveBumpA = bumpsA([bumpsA.idx_bumpTime] - [bumpsA.idx_goCueTime] < rT(i));
    eMoveBumpA = bumpsA([bumpsA.idx_bumpTime] - (pkInd(i) +[bumpsA.idx_movement_on]) < 0);
    lMoveBumpA = bumpsA([bumpsA.idx_bumpTime] - (pkInd(i) +[bumpsA.idx_movement_on]) >= 0);
    
    preMoveBumpA = trimTD(preMoveBumpA, {'idx_bumpTime',0}, {'idx_bumpTime', 13});
    eMoveBumpA = trimTD(eMoveBumpA, {'idx_bumpTime',0}, {'idx_bumpTime', 13});
    lMoveBumpA = trimTD(lMoveBumpA, {'idx_bumpTime',0}, {'idx_bumpTime', 13});

    
    frPreA(:,i) = squeeze(mean(cat(1, preMoveBumpA.cuneate_spikes),1));
    frEA(:,i) = squeeze(mean(cat(1, eMoveBumpA.cuneate_spikes),1));
    frLA(:,i) = squeeze(mean(cat(1, lMoveBumpA.cuneate_spikes),1));
    
    preMoveBumpR = bumpsR([bumpsR.idx_bumpTime] - [bumpsR.idx_goCueTime] < rT(i));
    eMoveBumpR = bumpsR([bumpsR.idx_bumpTime] - (pkInd(i) +[bumpsR.idx_movement_on]) < 0);
    lMoveBumpR = bumpsR([bumpsR.idx_bumpTime] - (pkInd(i) +[bumpsR.idx_movement_on]) >= 0);
    
    preMoveBumpR = trimTD(preMoveBumpR, {'idx_bumpTime',0}, {'idx_bumpTime', 13});
    eMoveBumpR = trimTD(eMoveBumpR, {'idx_bumpTime',0}, {'idx_bumpTime', 13});
    lMoveBumpR = trimTD(lMoveBumpR, {'idx_bumpTime',0}, {'idx_bumpTime', 13});
    
    preMoveBumpRAll = [preMoveBumpRAll, preMoveBumpR];
    eMoveBumpRAll = [eMoveBumpRAll, eMoveBumpR];
    lMoveBumpRAll = [lMoveBumpRAll, lMoveBumpR];
    
        
    preMoveBumpAAll = [preMoveBumpAAll, preMoveBumpA];
    eMoveBumpAAll = [eMoveBumpAAll, eMoveBumpA];
    lMoveBumpAAll = [lMoveBumpAAll, lMoveBumpA];
    
    
    frPreR(:,i) = squeeze(mean(cat(1, preMoveBumpR.cuneate_spikes),1));
    frER(:,i) = squeeze(mean(cat(1, eMoveBumpR.cuneate_spikes),1));
    frLR(:,i) = squeeze(mean(cat(1, lMoveBumpR.cuneate_spikes),1));
    
  

end


frPreA1 = cat(1,preMoveBumpAAll.cuneate_spikes);
velPreA = cat(1,preMoveBumpAAll.vel);

frEA1 = cat(1, eMoveBumpAAll.cuneate_spikes);
velEA = cat(1, eMoveBumpAAll.vel);

frLA1 = cat(1, lMoveBumpAAll.cuneate_spikes);
velLA = cat(1, lMoveBumpAAll.vel);
    
frPreR1 = cat(1,preMoveBumpRAll.cuneate_spikes);
velPreR = cat(1,preMoveBumpRAll.vel);

frER1 = cat(1, eMoveBumpRAll.cuneate_spikes);
velER = cat(1, eMoveBumpRAll.vel);

frLR1 = cat(1, lMoveBumpRAll.cuneate_spikes);
velLR = cat(1, lMoveBumpRAll.vel);

lmPreA1 = fitlm(velPreA, frPreA1(:,unitInd));
lmEA1 = fitlm(velEA, frEA1(:,unitInd));
lmLA1 = fitlm(velLA, frLA1(:,unitInd));

lmPreR1 = fitlm(velPreR, frPreR1(:,unitInd));
lmER1 = fitlm(velER, frER1(:,unitInd));
lmLR1 = fitlm(velLR, frLR1(:,unitInd));


frSpPreA = frPreA(unitInd,:);
frSpEA = frEA(unitInd,:);
frSpLA = frLA(unitInd,:);

figure
pdPreAl = rad2deg(atan2(lmPreA1.Coefficients.Estimate(3), lmPreA1.Coefficients.Estimate(2)));
pdPreR1 = rad2deg(atan2(lmPreR1.Coefficients.Estimate(3), lmPreR1.Coefficients.Estimate(2)));

pdER1 = rad2deg(atan2(lmER1.Coefficients.Estimate(3), lmER1.Coefficients.Estimate(2)));
pdEA1 = rad2deg(atan2(lmEA1.Coefficients.Estimate(3), lmEA1.Coefficients.Estimate(2)));

pdLR1 = rad2deg(atan2(lmLR1.Coefficients.Estimate(3), lmLR1.Coefficients.Estimate(2)));
pdLA1 = rad2deg(atan2(lmLA1.Coefficients.Estimate(3), lmLA1.Coefficients.Estimate(2)));

sensPreA1 = norm(lmPreA1.Coefficients.Estimate(2:3));
sensPreR1 = norm(lmPreR1.Coefficients.Estimate(2:3));
sensEA1 = norm(lmEA1.Coefficients.Estimate(2:3));
sensER1 = norm(lmER1.Coefficients.Estimate(2:3));
sensLA1 = norm(lmLA1.Coefficients.Estimate(2:3));
sensLR1 = norm(lmLR1.Coefficients.Estimate(2:3));


figure
theta = 0:pi/4:2*pi;

polarplot(theta, [frSpPreA, frSpPreA(1)])
hold on
polarplot(theta, [frSpEA, frSpEA(1)])
polarplot(theta, [frSpLA, frSpLA(1)])
title('Assistive Bumps')
legend('PreMove', 'Early Bump', 'Late Bump')


frSpPreR = frPreR(unitInd,:);
frSpER = frER(unitInd,:);
frSpLR = frLR(unitInd,:);



figure
theta = 0:pi/4:2*pi;

polarplot(theta, [frSpPreR, frSpPreR(1)])
hold on
polarplot(theta, [frSpER, frSpER(1)])
polarplot(theta, [frSpLR, frSpLR(1)])
title('Resistive Bumps')
legend('PreMove', 'Early Bump', 'Late Bump')

%%
close all
dir1 = 3;
tdResPD = bumpTrialsRes([bumpTrialsRes.target_direction]== dirsM(dir1));
beforeTime = [tdResPD.idx_goCueTime];
afterTime = [tdResPD.idx_endTime];
tdResPD = trimTD(tdResPD, 'idx_goCueTime', 'idx_endTime');
for i = 1:length(tdResPD)
    trial = tdResPD(i);
    
    colors = linspecer(length(trial.speed));
   
    pos = trial.pos;
    vel = trial.vel;
    velProj = vel*[cos(dirsM(dir1)), sin(dirsM(dir1))]';
    figure
    subplot(5,1, 1:2)
    scatter(pos(:,1), pos(:,2), [], colors)
    hold on
    scatter(pos(trial.idx_bumpTime,1), pos(trial.idx_bumpTime,2), 50, 'k')
    xlim([-15, 15])
    ylim([-50, -20])
    subplot(5,1,3)
    plot(.01:.01:.01*length(velProj),velProj)
    hold on
    plot([.01*trial.idx_bumpTime,.01*trial.idx_bumpTime], [min(velProj), max(velProj)], 'r')
    subplot(5,1,4)
    plot(.01:.01:.01*length(velProj),trial.cuneate_spikes(:,unitInd))
    ylim([0, 150])
    subplot(5,1,5)
    scatter(trial.cuneate_ts{unitInd}-.01*beforeTime(i), zeros(length(trial.cuneate_ts{unitInd}),1)); 
    
    xlim([-.01*beforeTime(i), .01*afterTime(i)])
end