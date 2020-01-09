%% Setting up parameters
close all
clearvars -except td
snapDate = '20190829';
monkey = 'Snap';

root = false;
useBumps = false;
onlyMapped = true;
%% More setup
date = snapDate;
number =2;
type = 'RefFrameEnc';
mapping = getSensoryMappings(monkey);
%% Load file if needed
if exist('td')~=1
    td = getTD(monkey, date, 'CO',number);
    td = removeBadNeurons(td, struct('remove_unsorted', false));
    td = removeUnsorted(td);
    td = removeGracileTD(td);
    td = removeNeuronsBySensoryMap(td, struct('rfFilter', {{'handUnit', true; 'distal', true}})); 
    td = removeNeuronsByNeuronStruct(td, struct('flags', {{'~handPSTHMan'}}));
    td = smoothSignals(td, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));
end
%% Data cleaning
td = removeBadOpensim(td);
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
%% Get opensim and remove distal muscles

if ~root
    forces = round([58.2, 38.7, 135.6, 135.6, 116.1, 406.5, 44.8, 174.3, 129.0, 129.0, 129.0, 154.8, 116.1,290.4,135.0, 135.6,116.1,135.6]);  
else
    forces = round(sqrt([58.2, 38.7, 135.6, 135.6, 116.1, 406.5, 44.8, 174.3, 129.0, 129.0, 129.0, 154.8, 116.1,290.4,135.0, 135.6,116.1,135.6]));  
end

close all
distalM = [1,2,6,7,12,13, 14,15,16,17,18,19,20,21,22, 27, 30, 31, 33, 35, 36];

mapped1 = [4 2 6 13 17 4 4 4 17];

osNames = td1(1).opensim_names;
os = cat(3,td1.opensim);
mVel = os(:,54:end,:);
mVel(:,distalM,:) =[];
hVel = cat(3, td1.vel);
mNames = osNames(54:end);
mNames(distalM) =[];
if onlyMapped
    mNames = mNames(mapped1);
    mVel = mVel(:, mapped1,:);
    forces = forces(mapped1);
end
%% Scale # of spindles to the force production capabilities of the muscles

%% Plot the color map that I'll use later for reference
colors = linspecer(length(dirsM));
figure
for dir = 1:length(dirsM)
    polarscatter(dirsM(dir), 1, 32,'filled',  'MarkerFaceColor', colors(dir,:))
    hold on

end
title('Random colormap')
%% Iterate through muscles
clear endVel
highFRScaled = [];
for i = 1:length(mVel(1,:,1))
    
    figure
    hold on
    %% For each muscle, take each direction and take the last few velocities (the end of the window)
    for dir = 1:length(dirsM)
        dirVel = squeeze(mVel(:,i,[td1.(dirBM)] == dirsM(dir)));
        endVel(dir) = mean(mean(dirVel(speedInds,:)));
%         keyboard
        mDir = mean(squeeze(dirVel),2);
        plot(mDir, 'Color', colors(dir,:))

    end
    %% Plot the velocities to show which has the highest lengthening
    title(mNames{i})
    endVel(endVel<0) = 0.00000001;
    figure
    for dir = 1:length(dirsM)
        polarscatter(dirsM(dir), endVel(dir), 32, 'filled', 'MarkerFaceColor', colors(dir,:))
        hold on

    end
    title(mNames{i})
    [~, highFR(i)] = max(endVel);
    highFRScaled = [highFRScaled; highFR(i)*ones(forces(i), 1)];
%     pause
end
%% Plot the directions of highest firing for these spindles
close all
figure
polarhistogram(dirsM(highFR), 10)
title('Highest Firing unscaled')
figure
polarhistogram(dirsM(highFRScaled), 8)
title('Highest Firing scaled')

% t122 = compareUniformity(nAll,[], dirsM(highFRScaled)');
%% Do the neuron PDs simply
guide = td1(1).cuneate_unit_guide;
numFoldsPD = 10;
for i = 1:length(guide(:,1))
    disp(['Working on unit ' num2str(i)])
    perms = randi(length(td1), length(td1), numFoldsPD); 
    for j = 1:numFoldsPD
        hVel1 = cat(1,td(perms(:,j)).vel);
        fr1 = cat(1,td(perms(:,j)).cuneate_spikes);
        lm1 = fitlm(hVel1, fr1(:,i));
        pd1{i}(j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
    end
    t1 = sort(pd1{i});
    [mPD(i), hPD(i), lPD(i)] = circ_mean(t1');
end
%%

%% Now do the PDs in a better way
% keyboard
for i = 1:length(mVel(1,:,1))
 perms = randi(length(td1), length(td1), forces(i)); 
 for j = 1:length(forces)
     hVel1 = cat(1, td1(perms(:,j)).vel);
     os1 = cat(1, td1(perms(:,j)).opensim);
     os1 = os1(:, 54:end);
     os1(:,distalM) = [];
     if onlyMapped
        os1 = os1(:,mapped1);
     end
     lm1 = fitlm(hVel1, os1(:,i));
     pd{i}(j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
 end
end
%%
close all
tmp = [pd{:}];
figure
polarhistogram(tmp, 12, 'FaceColor', 'b', 'FaceAlpha', 1)
title('Muscle PDs in same way as neuron PDs')
pds =[mPD', hPD', lPD'];

good = hPD-lPD<pi/4;
good = good';
pds = [pds, good];
pds(pds(:,4)==0,:) =[];
figure
polarhistogram(pds(:,1), 12, 'FaceColor', 'b', 'FaceAlpha', 1)
title('Neuron PDs')

figure
scatter(1:length(pds(:,1)), pds(:,1))
hold on
scatter(1:length(pds(:,1)), pds(:,2))
scatter(1:length(pds(:,1)), pds(:,3))
title('Neuron PDs and CIs')
mMuscPD = rad2deg(circ_mean(tmp'))
mCNPD = rad2deg(circ_mean(mPD'))

mLen = quantile(bootstrp(1000, @norm, tmp),[.025, .5, .975]);
cnLen = bootstrp(1000,@norm, mPD);

UmusclesVsCN =compareUniformity(mPD', [],tmp');

hanDate = '20171122';
array = 'cuneate';
windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
neuronsH = getNeurons('Han', hanDate, 'COactpas', 'LeftS1Area2', [windowAct;windowPas]);
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted', 'sinTunedAct'}});
nH = neuronStructPlot(neuronsH, params);

UmuscleVsS1 = compareUniformity(nH, [], mPD');
UcnVsS1 = compareUniformity(nH,[], tmp');
