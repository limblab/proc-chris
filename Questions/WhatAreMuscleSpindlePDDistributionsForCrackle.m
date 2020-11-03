%% Setting up parameters
close all
clearvars -except td
snapDate = '20190829';
monkey = 'Snap';
monkey2 = 'Crackle';
numSpindles = 1000;
root = true;
useBumps = false;
onlyMapped = true;
geometricCount = true;
doGLM = true;
%% More setup
date = snapDate;
number =2;
type = 'RefFrameEnc';
mapping = getSensoryMappings(monkey);
mapping2 = getSensoryMappings(monkey2);
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
%% Forces based on the square root or not
forcesInput = [58.2, 38.7, 135.6, 135.6, 116.1, 406.5, 44.8, 174.3, 129.0, 129.0, 129.0, 154.8, 116.1,290.4,135.0, 135.6,116.1,135.6];
if ~root
    forces = round(forcesInput);  
else
    forces = round(sqrt(forcesInput));  
end

close all
% Indices of distal muscles
distalM = [1,2,6,7,12,13, 14,15,16,17,18,19,20,21,22, 27, 30, 31, 33, 35, 36];
% Indices of CN mapped neurons
mapped1 = [12,10,12,16,17,18];

% 
osNames = td1(1).opensim_names; % get Opensim names
os = cat(3,td1.opensim); % get opensim out of Td
len1 = cat(1,td1.opensim);
meanLen = mean(len1(:,15:53));
meanLen(distalM) = [];
unmapVec = 1:39;
unmapVec(distalM) = [];
mVel = os(:,54:end,:); % get only muscle velocities
mVel(:,distalM,:) =[]; % get rid of distal muslces
hVel = cat(3, td1.vel); % get hand velocities
mNames = osNames(54:end); % get only velocities
mNames(distalM) =[]; % get rid of distal labels
if geometricCount
    forces = sqrt(forcesInput.*meanLen);
    forces = round(1000 * forces/sum(forces));
end
%% If looking at mapped only, index with sensory mappings
if onlyMapped
    mNamesM = mNames(mapped1);
    mVelM = mVel(:, mapped1,:);
    forcesM = forces(mapped1);
end
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

%% Now do the muscle spindle PDs in a better way

powerLaw = true;
geometricCount = true;
poissonNoise= true;


mapForce = [mapped1', forcesM'];
[uniqueMus, iC] = unique(mapped1);
numUniqueMus = length(uniqueMus);
mapForceUnique = mapForce(iC,:);
for i = 1:length(mapForce(:,1))
 perms = randi(length(td1), length(td1), mapForce(i,2)); 
 for j = 1:mapForce(i,2)
     hVel1 = cat(1, td1(perms(:,j)).vel);
     os1 = cat(1, td1(perms(:,j)).opensim);
     os1 = os1(:, 54:end);
     os1(:,distalM) = [];
     os1 = os1(:,mapForce(i,1));

     if powerLaw
         os1 = getPowerLaw(os1);
     end
     if poissonNoise
        os1 = addPoissonSpiking(os1); 
     end
     lm1 = fitlm(hVel1, os1);
     pd{i}(j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
 end
end
close all
tmp = [pd{:}];
figure
polarhistogram(tmp, 12, 'FaceColor', 'b', 'FaceAlpha', 1)
title('Muscle PDs for mapped crackle muscles')
%% Now do the muscle spindle PDs for all muscles, not just mapped ones

unmapForce = [unmapVec', forces'];
[uniqueMus, iC] = unique(unmapVec);
numUniqueMus = length(uniqueMus);
mapForceUnique = unmapForce(iC,:);
for i = 1:length(unmapForce(:,1))
 perms = randi(length(td1), length(td1), unmapForce(i,2)); 
 for j = 1:unmapForce(i,2)
     hVel1 = cat(1, td1(perms(:,j)).vel);
     os1 = cat(1, td1(perms(:,j)).opensim);
     os1 = os1(:, 54:end);
     os1(:,distalM) = [];
     os1 = os1(:,i);
     if powerLaw
         os1 = getPowerLaw(os1);
     end
     if poissonNoise
        os1 = addPoissonSpiking(os1); 
     end
     if doGLM
        b = glmfit(hVel1, os1, 'Poisson');
        pd{i}(j) = atan2(b(3), b(2));
     else
     lm1 = fitlm(hVel1, os1);
     pd{i}(j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
     end
 end
end
tmp = [pd{:}];
figure
polarhistogram(tmp, 12, 'FaceColor', 'b', 'FaceAlpha', 1)
title('Muscle PDs for all crackle muscles')