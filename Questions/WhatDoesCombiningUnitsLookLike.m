%% Setting up parameters
close all
clearvars -except td
snapDate = '20190829';
monkey = 'Snap';
numSpindles = 1000;
doGLM = false;
root = true;
useBumps = false;
onlyMapped = false;
geometricCount = true;
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
mapped1 = [4 2 6 13 17 4 4 4 17];

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

mNamesM = mNames(mapped1);
mVelM = mVel(:, mapped1,:);
forcesM = forces(mapped1);

forces = forces;

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
polarhistogram(dirsM(highFR), 12)
title('Highest Firing unscaled')
figure
polarhistogram(dirsM(highFRScaled), 12)
title('Highest Firing scaled')


%% Now do the muscle spindle PDs for all muscles, not just mapped ones
powerLaw = true;
unmapForce = [unmapVec', forces'];
[uniqueMus, iC] = unique(unmapVec);
numUniqueMus = length(uniqueMus);
mapForceUnique = unmapForce(iC,:);
randMuscleVec = [];
numBoots = 1;
for i = 1:length(unmapForce(:,1))
    randMuscleVec = [randMuscleVec; unmapForce(i,1)*ones(unmapForce(i,2),1)];
end
perms = randi(length(td1), length(td1), numBoots);
for boot = 1:numBoots
    disp(['Bootstrap ' , num2str(boot)])
    td2 = td1(perms(:,i));
    for i = 1:20
        for j = 1:1000
             randMuscle = randi(length(randMuscleVec),i,1);
             hVel1 = cat(1, td2.vel);
             os1 = cat(1, td2.opensim);
             os1 = os1(:, 54:end);
             os1 = os1(:,randMuscleVec(randMuscle,1));
             if powerLaw
                 os1 = getPowerLaw(os1);
             end
             if poissonNoise
                os1 = addPoissonSpiking(os1); 
             end
             os1 = os1*10*(rand(i,1)-0.5);
             if doGLM
                b = glmfit(hVel1, os1, 'Poisson');
                pd{boot,i}(j) = atan2(b(3), b(2));
             else
                 lm1 = fitlm(hVel1, os1);
                 pd{boot,i}(j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
             end

        end
    end

end
%%
close all
tmp = [pd{:}];
figure
polarhistogram(tmp, 12, 'FaceColor', 'b', 'FaceAlpha', 1)
title('Muscle PDs for unmapped muscles')
% save('D:\MonkeyData\CO\Compiled\BootstrappedSpindleCombPDs.mat','pd');
%%
load('D:\MonkeyData\CO\Compiled\BootstrappedSpindleCombPDs.mat')
figure
numBins = 18;
count = 0;
asdf= 1:20;
plotNums = [1,2,3,5,10];
ph1 = polarhistogram([1,1], numBins);
edges = ph1.BinEdges;
for i = asdf
    for j= 1:length(pd(:,1))
    tmp = [pd{j,i}];
    if any(i==plotNums) & j ==1
        count = count+1;
        subplot(1,length(plotNums),count)
        ph1 = polarhistogram(tmp, numBins, 'FaceColor', 'b', 'FaceAlpha', 1);
        edges = ph1.BinEdges;
        edgeCenters = (edges(2:end)+edges(1:end-1))/2;
        rho = ph1.BinCounts;
        
        maD(i,j) = norm((rho-mean(rho))/mean(rho),1);
        [xCart, yCart] = pol2cart(edgeCenters, rho);
        ell{i,j} = fit_ellipse(xCart, yCart);
        if ~isempty(ell{i,j}) & ~isempty(ell{i,j}.long_axis)
        major(i,j) = ell{i,j}.long_axis;
        minor(i,j) = ell{i,j}.short_axis;
        angles(i,j) = rad2deg(ell{i,j}.phi);
        else
            major(i,j) = nan;
            minor(i,j) = nan;
            angles(i,j) = nan;
        end
        title([ num2str(i)] )
        thetaticklabels([])
        rticklabels([])
    else
        ph1 = polarhistcounts(tmp, edges);

        edgeCenters = (edges(2:end)+edges(1:end-1))/2;
        rho = ph1;
        maD(i,j) = norm((rho-mean(rho))/mean(rho),1);
        [xCart, yCart] = pol2cart(edgeCenters, rho);
        ell{i,j} = fit_ellipse(xCart, yCart);
        if ~isempty(ell{i,j}) & ~isempty(ell{i,j}.long_axis)
            major(i,j) = ell{i,j}.long_axis;
            minor(i,j) = ell{i,j}.short_axis;
            angles(i,j) = rad2deg(ell{i,j}.phi);
        else
            major(i,j) = nan;
            minor(i,j) = nan;
            angles(i,j) = nan;
        end

    %     title(['Muscle PDs for all muscles: Combining ', num2str(i), ' muscles'] )
        thetaticklabels([])
        rticklabels([])
    end
    end
%     rlim([0,20])
end
suptitle('Number of Combined Muscles')
%%
close all
% keyboard
figure
shadedErrorBar(1:20,major',{@mean,@std})
hold on
plot(mean(minor'))
legend('Major ellipse axis','Minor')
max1 = max(max(mean(major'), mean(minor')));
ylim([0,max1])
xlabel('# of Muscles Combined')
ylabel('Length of Ellipse Axis')
set(gca,'TickDir','out', 'box', 'off')

figure
shadedErrorBar(1:20, maD', {@mean,@std})
max1= max(max(maD));
ylim([0,max1])

gangle = -1*angles' +90;
xlabel('# of Muscles Combined')
ylabel('Mean Absolute Deviation from Uniformity')
yyaxis right
shadedErrorBar(1:20, gangle, {@mean,@std})
ylabel('Major Axis Angle (deg)')
set(gca,'TickDir','out', 'box', 'off')
%%


windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

for i = 1:12
    switch i
        case 1
            neuronsB1 = getPaperNeurons(i, windowAct, windowPas);
        case 2
            neuronsS1 = getPaperNeurons(i, windowAct, windowPas);
        case 3
            neuronsC1 = getPaperNeurons(i, windowAct, windowPas);
        case 4
            neuronsD = getPaperNeurons(i, windowAct, windowPas);
        case 5
            neuronsH1 = getPaperNeurons(i, windowAct, windowPas);
        case 6
            neuronsB2 = getPaperNeurons(i, windowAct, windowPas);
        case 7 
            neuronsC2 = getPaperNeurons(i, windowAct, windowPas);
        case 8
            neuronsC3 = getPaperNeurons(i, windowAct, windowPas);
        case 9
            neuronsS2 = getPaperNeurons(i, windowAct, windowPas);
        case 10
            neuronsH2 = getPaperNeurons(i, windowAct, windowPas);
        case 11
            neuronsCh = getPaperNeurons(i, windowAct, windowPas);
        case 12
            neuronsR = getPaperNeurons(i, windowAct, windowPas);
    end
end



neuronsB1 = fixCellArray(neuronsB1);
neuronsB2 = fixCellArray(neuronsB2);
neuronsC1 = fixCellArray(neuronsC1);
neuronsC2 = fixCellArray(neuronsC2);
neuronsC3 = fixCellArray(neuronsC3);
neuronsS1 = fixCellArray(neuronsS1);
neuronsS2 = fixCellArray(neuronsS2);

neuronsB = joinNeuronTables({neuronsB1, neuronsB2});
neuronsS = joinNeuronTables({neuronsS1, neuronsS2});
neuronsC = joinNeuronTables({neuronsC1, neuronsC3});

neuronsS = fixCellArray(neuronsS);
neuronsC = fixCellArray(neuronsC);


neuronsCN = joinNeuronTables({neuronsB, neuronsS, neuronsC});

neuronsD = fixCellArray(neuronsD);
neuronsH1 = fixCellArray(neuronsH1);
neuronsH2 = fixCellArray(neuronsH2);
neuronsCh = fixCellArray(neuronsCh);
neuronsArea2 =  joinNeuronTables({neuronsD,neuronsH1, neuronsH2,neuronsCh});

%%

numBins = 18;
edges = linspace(-pi, pi, numBins);

paramsArea2 = struct('tuningCondition', {{'isSorted','sinTunedAct', 'sinTunedPas'}}, 'nBins', 18);
paramsArea2.date1 = 'all';
paramsArea2.array = 'leftS1';
paramsArea2.edges = edges;

[madActS1, madPasS1] = getPDDistNonUniformity(neuronsArea2, paramsArea2);

paramsCN = struct('tuningCondition', {{'isSorted','isCuneate','sinTunedAct', 'sinTunedPas','handPSTHMan','~distal'}}, 'nBins', 18);
paramsCN.date1 = 'all';
paramsCN.array = 'cuneate';
paramsCN.edges = edges;

[madActCN, madPasCN] = getPDDistNonUniformity(neuronsCN, paramsCN);

[madActSn, madPasSn] = getPDDistNonUniformity(neuronsS, paramsCN);
mean(madActCN)
mean(madActS1)

mMadPasCN= mean(madPasCN);
mMadPasS1= mean(madPasS1);
mMadPasSn = mean(madPasSn);

difNorm = madActCN - madActS1;
[h1, p] = ttest(difNorm);

close all
params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','isCuneate','sinTunedAct','sinTunedPas', 'handPSTHMan','~distal'}});

params.date = 'all';
neuronStructPlot(neuronsCN, params)


params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', true, ...
    'plotAvgFiring', false, 'plotAngleDif', true, 'plotPDDists', true, ...
    'savePlots', true, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted','sinTunedAct','sinTunedPas'}});

params.date = 'all';
neuronStructPlot(neuronsArea2, params)
neuronStructPlot(neuronsH1, params)