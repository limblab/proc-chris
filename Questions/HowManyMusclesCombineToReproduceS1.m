%% Setting up parameters
close all
clearvars -except td
snapDate = '20190829';
monkey = 'Snap';

root = false;
useBumps = false;
onlyMapped = false;
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


%% Iterate through muscles
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
%%
close all
clear lam1 firing fr r2X r2Y
vel = cat(1, td1.vel);
plotDists = false;
numReps = 20;
maxCombs = 5;
numSims = 1000;
numSimNeurons = 10;
pdComb = zeros(maxCombs, numSims);
% ell = cell();
major = zeros(maxCombs, numReps);
minor = zeros(maxCombs, numReps);
for j = 1:numReps
    disp(['Rep ', num2str(j)])
if plotDists
    figure
end
for i = 1:maxCombs
    disp(['Muscle Combs ', num2str(i)])

%     keyboard
    rnd = randi(length(tmp), numSims, i);
    samp1 = tmp(rnd);
    wMat = rand(1000, i)-.5;
    if i ~=1
        x1 = sum(wMat.*cos(samp1),2);
        y1 = sum(wMat.*sin(samp1),2);
        pdComb(i,:) = atan2(y1', x1');
    else
        pdComb(i,:)= samp1;
    end
    subplot(ceil(maxCombs/5),5,i)
    ph1 = polarhistogram(pdComb(i,:), 18);
    edges = ph1.BinEdges;
    edgeCenters = (edges(2:end)+edges(1:end-1))/2;
    rho = ph1.BinCounts;
    [xCart, yCart] = pol2cart(edgeCenters, rho);
    ell{i} = fit_ellipse(xCart, yCart);
    major(i,j) = ell{i}.long_axis;
    minor(i,j) = ell{i}.short_axis;
    thetaticks([])
    rticks([])
%     title([num2str(i)])
    set(gca,'TickDir','out', 'box', 'off')
    for k = 1:length(pdComb(i,:))
        b2 = tan(pdComb(i,k));
        b1 = 1;
        b0 = .1;
        lam1(:,k) = b0*ones(length(vel(:,1)),1) + (b1*vel(:,1) + b2*vel(:,2))/100;
        lam1(lam1(:,k)<0, k)=0;
        firing(:,k) = poissrnd(lam1(:,k));
        fr(:,k) = firing(:,k)*100;
    end
    lmX = fitlm(fr(:,1:20), vel(:,1));
    lmY = fitlm(fr(:,1:20), vel(:,2));
    
    r2X(i,j) = lmX.Rsquared.Ordinary;
    r2Y(i,j) = lmY.Rsquared.Ordinary;

end
% keyboard
suptitle('Number of combined muscles PD distribution')
end
%%
figure
plot(r2X, 'r')
hold on
plot(mean(r2X'), 'LineWidth', 5)

figure
plot(r2Y, 'r')
hold on
plot(mean(r2Y'), 'LineWidth', 5)


%%
close all
figure
majorCI= bootci(1000, @mean, major');
shadedErrorBar(1:maxCombs,mean(major,2),abs(majorCI'-mean(major,2)),'lineprops','g');
set(gca,'TickDir','out', 'box', 'off')
grid on
hold on
f = fit([1:maxCombs]', mean(major,2), 'exp2');
plot(f);
xlabel('# of muscles combined')
ylabel('Length of Major axis of fit ellipse')
%% asf

hanDate = '20171122';

% hanDate = '20190710';
array = 'cuneate';
windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
% neuronsH = getNeurons('Duncan', hanDate, 'CObump', 'leftS1', [windowAct;windowPas]);

neuronsH = getNeurons('Han', hanDate, 'COactpas', 'LeftS1Area2', [windowAct;windowPas]);

params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', true, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', true, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false,...
    'tuningCondition', {{'isSorted', 'sinTunedAct', 'sinTunedPas'}});
nH = neuronStructPlot(neuronsH, params);
