%% Setting up parameters
close all
clearvars -except td
% snapDate = '20190129';
% monkey = 'Butter';

snapDate = '20190829';
monkey = 'Snap';
root = false;
useBumps = false;
%% More setup
date = snapDate;
number =2;
type = 'RefFrameEnc';
mapping = getSensoryMappings('Butter');
%% Load file if needed
if exist('td')~=1
    td = getTD(monkey, date, 'CO',number);
    td = removeBadNeurons(td, struct('remove_unsorted', false));
    td = removeUnsorted(td);
    td = removeGracileTD(td);
    td = removeNeuronsBySensoryMap(td, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
    td = removeNeuronsByNeuronStruct(td, struct('flags', {{'~handPSTHMan'}}));
    td = smoothSignals(td, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));
end
%% Data cleaning
td = tdToBinSize(td, 10);

if ~isfield(td, 'idx_movement_on')
    td = getSpeed(td);
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeak(td, params);
end

if useBumps
    start_time = {'idx_bumpTime', 0};
    end_time = {'idx_bumpTime', 13};
    td1 = td(~isnan([td.idx_bumpTime]));
    dirBM = 'bumpDir';
    dirsM = unique([td1.bumpDir]);
    dirsM(isnan(dirsM)) =[];
    dirsM(mod(dirsM, 45)~=0)=[];
    speedInds = 3:6;
else
    dirBM = 'target_direction';
    start_time = {'idx_movement_on', 0};
    end_time = {'idx_movement_on', 13};
    dirsM = unique([td.target_direction]);
    dirsM(isnan(dirsM)) =[];
    dirsM(mod(dirsM, pi/4)~=0)=[];
    speedInds = 11:14;
    td1 = td;
end
td1 = trimTD(td1, start_time, end_time);
td1 = tdToBinSize(td1, 50);

%% Get opensim and remove distal muscles

%% Do the neuron PDs simply
guide = td1(1).cuneate_unit_guide;
numFoldsPD = 10;
r2 = zeros(length(guide(:,1)), numFoldsPD);
for i = 1:length(guide(:,1))
    disp(['Working on unit ' num2str(i)])
    perms = randi(length(td1), length(td1), numFoldsPD); 
    for j = 1:numFoldsPD
        hVel1 = cat(1,td(perms(:,j)).vel);
        fr1 = cat(1,td(perms(:,j)).cuneate_spikes);
        lm1 = fitlm(hVel1, fr1(:,i));
        pd1{i}(j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
        r2(i,j) = lm1.Rsquared.Ordinary;
    end
    t1 = sort(pd1{i});
    [mPD(i), hPD(i), lPD(i)] = circ_mean(t1');
end
%%
pds =[mPD', hPD', lPD'];

good = hPD-lPD<pi/4;
good = good';
pds = [pds, good];
pds(pds(:,4)==0,:) =[];
figure
polarhistogram(pds(:,1), 12)

figure
scatter(1:length(pds(:,1)), pds(:,1))
hold on
scatter(1:length(pds(:,1)), pds(:,2))
scatter(1:length(pds(:,1)), pds(:,3))
%%

figure
histogram(mean(r2'),10)
mean(mean(r2))
%% Now do the PDs in a better way