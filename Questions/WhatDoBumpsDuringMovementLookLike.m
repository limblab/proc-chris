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
td1 = removeUnsorted(td1Start);

td1 = smoothSignals(td1, struct('signals', ['cuneate_spikes'], 'calc_rate' ,true));
td1 = getMoveOnsetAndPeak(td1);
td1 = td1(~isnan([td1.bumpDir]));
td1 = trimTD(td1, {'idx_bumpTime', -50}, {'idx_bumpTime', 50});


dirsM = unique([td1.target_direction]);
dirsB = unique([td1.bumpDir]);
dirsM = dirsM(~isnan(dirsM));
dirsB = dirsB(~isnan(dirsB));

rightR= [td1.target_direction] == 0;
upR = [td1.target_direction] == pi/2;
leftR = [td1.target_direction] == pi;
downR = [td1.target_direction] == 3*pi/2;

noBump = isnan([td1.bumpDir]);

rightB= [td1.bumpDir] == 0;
upB = [td1.bumpDir] == 90;
leftB = [td1.bumpDir] == 180;
downB = [td1.bumpDir] == 270;

bInds = [rightB', upB', leftB',downB'];
rInds = [rightR', upR', leftR',downR'];

guide = td1(1).cuneate_unit_guide;
for i = 1:length(dirsM)
    for j = 1:length(dirsB)
        firing{i,j} = cat(3, td1(rInds(:, i) & bInds(:,j)).cuneate_spikes);
        vel{i,j} = cat(3, td1(rInds(:,i) & bInds(:,j)).vel);
        
        mFiring{i,j} = mean(firing{i,j} ,3);
        mVel{i,j} = mean(vel{i,j},3);
    end
end
%%

for j = 1:length(dirsM)
        switch dirsM(j) 
            case 0
                subplot(3,3,6)
            case pi/2
                subplot(3,3,2)
            case pi
                subplot(3,3,4)
            case 3*pi/2
                subplot(3,3,8)
                ylabel('Hand speed (cm/s)')
                xlabel('Time relative to Bump')
        end
    data = vel(j,:);
    hold on
    vel1 = squeeze(vecnorm(data{1}, 2, 2));
    vel2 = squeeze(vecnorm(data{2}, 2, 2));
    vel3 = squeeze(vecnorm(data{3}, 2, 2));
    vel4 = squeeze(vecnorm(data{4}, 2, 2));
    xlim([-50, 50])
    time = -50:50;
    plot(time, vel1, 'k')
    plot(time,vel2, 'r')
    plot(time,vel3, 'b')
    plot(time,vel4, 'g')
    
end
subplot(3, 3, 9)
plot([0,1], [1,1],'k')
hold on
plot([0,1] , [.8,.8], 'r')
plot([0,1], [.6, .6], 'b')
plot([0, 1], [.4,.4], 'g')
legend('Right' ,'Up', 'Left','Down')
suptitle1('Kinematic effects of movement bumps')

    
%%
fig1 = figure;
for i = 1:length(guide(:,1))

    if ismember(guide(i,:), crList(:,1:2), 'rows')
        close(fig1)

        fig1 = figure;
        for j = 1:length(dirsM)
        switch dirsM(j) 
            case 0
                subplot(3,3,6)
            case pi/2
                subplot(3,3,2)
            case pi
                subplot(3,3,4)
                
            case 3*pi/2
                subplot(3,3,8)   
        end
        data = mFiring(j,:);
        plot(data{1}(:,i), 'k')
        hold on
        plot(data{2}(:,i), 'r')
        plot(data{3}(:,i),'b')
        plot(data{4}(:,i),'g')
        xlim([0, 100])
        end
        pause
    end
    
    
end