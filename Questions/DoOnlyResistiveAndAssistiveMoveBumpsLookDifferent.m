%% Basic parameter setup
close all
clearvars -except td1Start td2Start
plotResponses = false; % if you want to plot the actual and predicted responses
plotPerpFiring = true; % if you want to plot the firing rates in a scatter plot
normalizeFR = true; % To normalize firing rate to premovement firing
sqrtTransform = true;
useLMTransform = true; % To transform the two days into same scale with a simple linear regression on the PSTHs
plotRescaling = true; % To plot the rescaling of the PSTHs post-modeling
zeroBump = true; % Testing the effect of zeroing out the bump prediction on fits
zeroMove = false; % Testing the effect of zeroing out the move prediction on fits
meanSubtract= false; % Whether to subtract the mean in the R2 calculation (makes it only count predictive accuracy above predicting the mean firing rate)
actSubtract = true; % Subtract the active condition to determine the contribution of just the bump to the residual
useMaxBumpDir = false;
%% File parameters
date = '20180530';
monkey = 'Butter';
unitNames= 'cuneate';
%% Load the TDs (if they haven't yet been loaded) and do the time-intensive processing
if ~exist('td1Start') | ~exist('td2Start')
    
td1Start =getTD(monkey, date, 'COmoveBump',1);
td2Start = getTD(monkey, '20180607','CO',1);
% Add a speed term
td1Start = getNorm(td1Start,struct('signals','vel','field_extra','speed')); 
td2Start = getNorm(td2Start,struct('signals','vel','field_extra','speed'));
% bin to 10 ms
td1Start = tdToBinSize(td1Start, 10);
td2Start = tdToBinSize(td2Start,10);
end

%% Load the Neuron structs (not necessary anymore, but the code is useful)
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\neuronStruct\Butter_20180607_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons2 = neurons;
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180530\neuronStruct\Butter_20180530_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons1 = neurons;
clear neurons;
%% Compute the neuron matching (the manual list if based on visual PSTH and waveshape inspection)
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
% Smoothing firing rates w/ 50 ms gaussian kernel
td1 = smoothSignals(td1Start, struct('signals', ['cuneate_spikes']));
td2 = smoothSignals(td2Start, struct('signals', ['cuneate_spikes']));

% Getting move onset
td2 = getMoveOnsetAndPeak(td2);
td1 = getMoveOnsetAndPeak(td1);

% Trimming premovement and movement windows for the center-bump trials
preMove2 = trimTD(td2, {'idx_goCueTime', -10}, {'idx_goCueTime', -5});
tdMove2= trimTD(td2, {'idx_goCueTime',50}, {'idx_goCueTime', 63}); % when the bump "would have" been
tdBump2= td2(~isnan([td2.idx_bumpTime])); % Get just the bump trials
tdBump2 = trimTD(tdBump2, 'idx_bumpTime', {'idx_bumpTime', 13}); % get the center-hold bumps

%% Parse all directions in both days
dirsM = unique([tdMove2.target_direction]);
dirsB = unique([tdBump2.bumpDir]);
dirsM = dirsM(~isnan(dirsM));
dirsB = dirsB(~isnan(dirsB));

%% Compute the bump effect and move effect from 0530
%% Trim 0530 file into premovement and bump times
disp('Trimming Files')
preMove1 = trimTD(td1, {'idx_goCueTime', -10}, {'idx_goCueTime', -5}); %Premovement
scaleMove = td1(isnan([td1.bumpDir]));
% Get the reach direction PSTH plots for both files
noBumpAct1 = trimTD(scaleMove, {'idx_goCueTime', 50}, {'idx_goCueTime', 63});
scale1 = trimTD(scaleMove, {'idx_movement_on', -30}, {'idx_movement_on',30});
scale2 = trimTD(td2, {'idx_movement_on', -30}, {'idx_movement_on',30});
td1 = trimTD(td1, {'idx_goCueTime', 50}, {'idx_goCueTime', 63}); % Bump

unitG1= td1(1).cuneate_unit_guide; % Get unit guide for 0530
unitG2 = td2(1).cuneate_unit_guide; % Get unit guide for 0607

firingPre1 = cat(1, preMove1.cuneate_spikes)/preMove1(1).bin_size; % Premove Firing for 0530
firingPre2 = cat(1, preMove2.cuneate_spikes)/preMove2(1).bin_size; % Premove Firing for 0607

firingMeanPre2 = mean(firingPre2); % mean Premove Firing
firingMeanPre1 = mean(firingPre1); % mean Premove Firing

firingScale1 = cat(3, scale1.cuneate_spikes)/scale1(1).bin_size; %
firingScale2 = cat(3, scale2.cuneate_spikes)/scale2(1).bin_size;

% This is only used if the LM model isn't selected
firingMeanScale1 = firingMeanPre1;
firingMeanScale2 = firingMeanPre2;
disp('Scaling to the same units')

%%
for j = 1:length(dirsM)
    for k = 1:length(dirsB)
        firingMB = cat(1, td1([td1.target_direction] == dirsM(j) & [td1.bumpDir] == dirsB(k)));
        meanFiringMB = mean(firingMB)
    end
end
