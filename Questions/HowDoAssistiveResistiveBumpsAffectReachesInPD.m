%% Basic parameter setup
close all
clearvars -except td1Start td2Start

%% File parameters
date = '20180530';
monkey = 'Butter';
unitNames= 'cuneate';
%% Load the TDs
if ~exist('td1Start') | ~exist('td2Start')
td1Start =getTD(monkey, date, 'COmoveBump',1);
td2Start = getTD(monkey, '20180607','CO',1);

td1Start = getNorm(td1Start,struct('signals','vel','field_extra','speed'));
td2Start = getNorm(td2Start,struct('signals','vel','field_extra','speed'));

td1Start = tdToBinSize(td1Start, 10);
td2Start = tdToBinSize(td2Start,10);
end

%% Load the Neuron structs
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\neuronStruct\Butter_20180607_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons2 = neurons;
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180530\neuronStruct\Butter_20180530_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons1 = neurons;
clear neurons;
%% Compute the neuron matching
% crList= findMatchingNeurons(neurons1, neurons2);
crList =  [1 2 1 2; ...
           2 1 2 1;...
           3 1 3 1;...
           11 1 11 1; ...
           12 1 12 1;...
           14 1 14 1; ...
           16 1 16 1;...
           17 1 17 1;...
           18 1 18 1;...
           18 2 18 3;...
           20 1 20 1; ...
           20 2 20 2; ...
           22 1 22 1; ...
           22 2 22 2; ...
           23 1 23 1; ...
           24 2 24 2; ...
           24 3 24 3; ...
           27 1 27 1; ...
           27 2 27 2; ...
           33 1 33 1; ...
           36 1 36 1; ...
           38 1 38 1; ...
           40 1 40 1; ...
           41 1 41 1;...
           42 1 42 1; ...
           45 1 45 1; ...
           50 1 50 1; ...
           62 1 62 1; ...
           67 1 67 1; ...
           72 1 72 2; ...
           74 1 74 1;...
           76 1 76 1];
           
           
%% Compute the bump effect and move effect from 0607
td2 = removeUnsorted(td1Start);

td2 = smoothSignals(td2, struct('signals', ['cuneate_spikes'], 'calc_rate' ,true));
td2 = getMoveOnsetAndPeak(td2);

td1 = td2(~isnan([td2.bumpDir]));
td1 = trimTD(td1, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
td2 = trimTD(td2, {'idx_goCueTime', 50}, {'idx_goCueTime', 63});

dirsM = unique([td1.target_direction]);
dirsB = unique([td1.bumpDir]);
dirsM = dirsM(~isnan(dirsM));
dirsB = dirsB(~isnan(dirsB));

rightR= [td1.target_direction] == 0;
upR = [td1.target_direction] == pi/2;
leftR = [td1.target_direction] == pi;
downR = [td1.target_direction] == 3*pi/2;

noBump = td2(isnan([td2.bumpDir]));
noBumpR = [noBump.target_direction] ==0;
noBumpU = [noBump.target_direction] ==pi/2;
noBumpL = [noBump.target_direction] ==pi;
noBumpD = [noBump.target_direction] ==3*pi/2;

rNoBumpInds = [noBumpR', noBumpU', noBumpL', noBumpD'];

rightB= [td1.bumpDir] == 0;
upB = [td1.bumpDir] == 90;
leftB = [td1.bumpDir] == 180;
downB = [td1.bumpDir] == 270;

bInds = [rightB', upB', leftB',downB'];
rInds = [rightR', upR', leftR',downR'];



guide = td1(1).cuneate_unit_guide;
for i = 1:length(dirsM)
    noBumpFiring = sqrt(cat(3, noBump(rNoBumpInds(:,i)).cuneate_spikes));
    mNoBumpFiring = mean(noBumpFiring, 3);
    mNoBumpRate(i,:) = mean(mNoBumpFiring);
    noBumpSpeed =cat(3, noBump(rNoBumpInds(:,i)).vel);
    mNoBumpSpeed1 = squeeze(mean(noBumpSpeed,3));
    mNoBumpSpeed(:,i) = squeeze(mean(rownorm(mNoBumpSpeed1)));
    
    speedNoBumpCI(i,:) = bootci(1000, @mean, rownorm(squeeze(mean(noBumpSpeed,1))'));
    for j = 1:length(dirsB)
        firing{i,j} = sqrt(cat(3, td1(rInds(:, i) & bInds(:,j)).cuneate_spikes));
        vel{i,j} = cat(3, td1(rInds(:,i) & bInds(:,j)).vel);
        bootTemp = squeeze(mean(firing{i,j}));
        speedTemp = rownorm(squeeze(mean(vel{i,j}))');
        frCI(i,j,:,:) = bootci(100, @mean, bootTemp');
        speedCI(i,j,:) = bootci(100, @mean, speedTemp);
        mFiring{i,j} = mean(firing{i,j} ,3);
        mRate(i,j,:) = mean(mFiring{i,j});
        mVel{i,j} = mean(vel{i,j},3);
    end
end
%%
close all
sigInd = zeros(length(mRate(1,1,:)),1);
[~, maxFDir] = max(mNoBumpRate', [],2);
for i = 1:length(mRate(1,1,:))
    assistiveFR(i) = mRate(maxFDir(i), maxFDir(i), i);
    assFRCI(:,i) = frCI(maxFDir(i), maxFDir(i), :,i);
    
    resistiveFR(i) = mRate(maxFDir(i), getResistive(maxFDir(i)), i);
    resFRCI(:,i) = frCI(maxFDir(i), getResistive(maxFDir(i)), :,i);
    
    reachFR(i) = mNoBumpRate(maxFDir(i),i);
    
    assSpeed(i) = mean(rownorm(mVel{maxFDir(i), maxFDir(i)}));
    resSpeed(i)  = mean(rownorm(mVel{maxFDir(i), getResistive(maxFDir(i))}));
    assSpeedCI(i,:) = squeeze(speedCI(maxFDir(i), maxFDir(i),:));
    resSpeedCI(i,:) = squeeze(speedCI(maxFDir(i), getResistive(maxFDir(i)),:));
    if reachFR(i) > assFRCI(2,i) | reachFR(i) < assFRCI(1,i) | reachFR(i) > resFRCI(2,i) | reachFR(i) < resFRCI(1,i)
        sigInd(i) = true;
    end
end

reachFR(~sigInd) = [];
assistiveFR(~sigInd) = [];
resistiveFR(~sigInd) = [];
resFRCI(:,~sigInd) = [];
assFRCI(:,~sigInd) = [];
assSpeed(~sigInd) = [];
resSpeed(~sigInd) = [];
assSpeedCI(~sigInd,:) = [];
resSpeedCI(~sigInd,:) = [];
figure
scatter(assistiveFR, resistiveFR)
hold on
errorbar(assistiveFR, resistiveFR, resFRCI(1,:)-resistiveFR, resFRCI(2,:) - resistiveFR, assFRCI(1,:)-assistiveFR, assFRCI(2,:)-assistiveFR, 'k.')  
plot([0, max(assistiveFR, resistiveFR)], [0, max(assistiveFR, resistiveFR)])
xlabel('Assistive Bump FR')
ylabel('Resistive Bump FR')
title('Effect of assistive or resistive bump in PD on FR')
set(gca,'TickDir','out', 'box', 'off')

figure
scatter(assSpeed, resSpeed);
hold on
errorbar(assSpeed, resSpeed, resSpeedCI(:,1)' - resSpeed, resSpeedCI(:,2)' - resSpeed, assSpeedCI(:,1)' - assSpeed, assSpeedCI(:,2)'-assSpeed, 'k.' )
plot([0, max(assSpeed, resSpeed)], [0, max(assSpeed, resSpeed)])
title('Assistive vs resistive hand speeds in each direction')
xlabel('Assistive hand speed')
ylabel('Resistive hand speed')

fitlm(assistiveFR, resistiveFR)
%%
figure
scatter(assistiveFR-reachFR, resistiveFR-reachFR)
xlabel('Assistive Bump FR Change')
ylabel('Resistive Bump FR Change')
title('Effect of assistive or resistive bump in PD on FR')

lm1= fitlm(assistiveFR-reachFR, resistiveFR-reachFR)
plot(lm1)
%%

function out = getResistive(ind)
    switch ind
        case 1
            out = 3;
        case 2
            out = 4;
        case 3
            out = 1;
        case 4
            out = 2;
    end
end