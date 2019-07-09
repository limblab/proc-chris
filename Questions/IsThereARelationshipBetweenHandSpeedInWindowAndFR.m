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
td2 = trimTD(td2, {'idx_peak_speed', -15}, {'idx_peak_speed', 15});

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
    noBumpFRWindow{i} = squeeze(mean(noBumpFiring, 1));
    mNoBumpFiring = mean(noBumpFiring, 3);
    mNoBumpRate(i,:) = mean(mNoBumpFiring);
    noBumpSpeed =cat(3, noBump(rNoBumpInds(:,i)).vel);
    noBumpSpeedWindow{i} = squeeze(mean(noBumpSpeed,1));
    mNoBumpSpeed1 = squeeze(mean(noBumpSpeed,3));
    mNoBumpSpeed(:,i) = squeeze(mean(rownorm(mNoBumpSpeed1)));
    
end
%%
close all
[~, maxFDir] = max(mNoBumpRate', [],2);
indList = [];

for i = 1:length(crList(:,1))
    indList = [indList, find(guide(:,1) == crList(i,1) &...
        guide(:,2) == crList(i,2))];
end

for i=indList
    figure
    scatter(rownorm(noBumpSpeedWindow{maxFDir(i)}')', noBumpFRWindow{maxFDir(i)}(i, :))
    pause
end

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