%% Compute the PDs of neurons
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Lando\20170917\TD\Lando_COactpas_20170917_TD.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\MapData\Lando\LandoCompiledSensoryMappings.mat')

%% Compute the PDs of neurons
td20180607 =td;

param.arrays = {'cuneate'};
param.in_signals = {'vel'};
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td20180607, param);
%% Load the sensory mapping files, upload into the neuron structure
param.array = 'cuneate';
param.sinTuned= neuronsNew.sinTunedAct | neuronsNew.sinTunedPas;
getCOActPasStats(td20180607, param);
neuronsCO = [neuronsNew];
neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
%% Compute the trial averaged speed of each direction
params.tuningCondition = {'isSpindle','isSorted','sinTunedAct'};
neuronStructPlot(neuronsCO, params);
windowAct= {'idx_movement_on', 0; 'idx_movement_on',5}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',2};
tdBin = binTD(td20180607,5);
tdPas = tdBin(~isnan([tdBin.idx_bumpTime]));
tdAct = trimTD(tdBin, windowAct(1,:), windowAct(2,:));
tdPas = trimTD(tdPas, windowPas(1,:), windowPas(2,:));

velActTrial = cat(3, tdAct.vel);
velAct = squeeze(mean(velActTrial,1))';
meanVelAct = mean(velAct);

velPasTrial = cat(3, tdPas.vel);
velPas = squeeze(mean(velPasTrial,1))';

meanVelPas = mean(velPas);
scatter(velAct(:,1), velAct(:,2),'k')
hold on
xlim([-60,60])
ylim([-60,60])
axis equal
scatter(velPas(:,1), velPas(:,2), 'r')
scatter(meanVelAct(1), meanVelAct(2),100,'g', 'filled')
scatter(meanVelPas(1), meanVelPas(2),100,'g', 'filled')
ang1 = rad2deg(atan2(meanVelAct(2), meanVelAct(1)));
%% Plot the tuning of the neurons and compare it to the highest velocity
actPDTable = neuronsCO(find(neuronsCO.isSorted & neuronsCO.isCuneate & neuronsCO.sinTunedAct) ,:).actPD;
fh1 = figure;
[~,~,~,tunedPDs] = plotTuningDist(actPDTable,fh1, 'k', pi/8);
meanDir = rad2deg(circ_mean(tunedPDs));
%% Fit decoding models to velocity and position to determine which neurons
%  best reflect the kinematics of the handle
disp('all units')
params.z_score_x = false;
params.flag = 1:length(tdAct(1).cuneate_spikes(1,:));
[tdVel, modelEval.All, modelFits.All] = linearVelocityDecoder(tdAct, params);

% Only sorted units
disp('Sorted units')
params.flag = find(neuronsCO.isSorted);
[tdVel, modelEval.Sorted, modelFits.Sorted] = linearVelocityDecoder(tdAct, params);
% Only sorted cuneate units
disp('Sorted Cuneate')
params.flag = find(neuronsCO.isCuneate& neuronsCO.isSorted);
[tdVel, modelEval.SortedCuneate, modelFits.SortedCuneate] = linearVelocityDecoder(tdAct, params);
% Only gracile channels
disp('Gracile')
params.flag = find(neuronsCO.isGracile);
[tdVel, modelEval.Gracile, modelFits.Gracile] = linearVelocityDecoder(tdAct, params);
% Only sorted Gracile units
disp('Gracile sorted')
params.flag = find(neuronsCO.isGracile & neuronsCO.isSorted);
[tdVel, modelEval.SortedGracile, modelFits.SortedGracile] = linearVelocityDecoder(tdAct, params);
% Only spindles
disp('spindles')
params.flag = find(neuronsCO.isSpindle & neuronsCO.sameDayMap & neuronsCO.isSorted);
[tdVel, modelEval.Spindles, modelFits.Spindles] = linearVelocityDecoder(tdAct, params);
td20170917 =td;
param.arrays = {'cuneate'};
param.in_signals = {'vel'};
[processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td20170917, param);
%% Load the sensory mapping files, upload into the neuron structure
param.array = 'cuneate';
param.sinTuned= neuronsNew.tuned;
getCOActPasStats(td20170917, param);
neuronsCO = [neuronsNew];
neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingFile);
%% Compute the trial averaged speed of each direction
params.tuningCondition = {'isSpindle','isSorted','sinTunedAct'};
neuronStructPlot(neuronsCO, params);
windowAct= {'idx_movement_on', 0; 'idx_movement_on',5}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',2};
tdBin = binTD(td20170917,5);
tdPas = tdBin(~isnan([tdBin.idx_bumpTime]));
tdAct = trimTD(tdBin, windowAct(1,:), windowAct(2,:));
tdPas = trimTD(tdPas, windowPas(1,:), windowPas(2,:));

velActTrial = cat(3, tdAct.vel);
velAct = squeeze(mean(velActTrial,1))';
meanVelAct = mean(velAct);

velPasTrial = cat(3, tdPas.vel);
velPas = squeeze(mean(velPasTrial,1))';

meanVelPas = mean(velPas);
scatter(velAct(:,1), velAct(:,2),'k')
hold on
xlim([-60,60])
ylim([-60,60])
axis equal
scatter(velPas(:,1), velPas(:,2), 'r')
scatter(meanVelAct(1), meanVelAct(2),100,'g', 'filled')
scatter(meanVelPas(1), meanVelPas(2),100,'g', 'filled')
ang1 = rad2deg(atan2(meanVelAct(2), meanVelAct(1)));
%% Plot the tuning of the neurons and compare it to the highest velocity
actPDTable = neuronsCO(find(neuronsCO.isSorted & neuronsCO.isCuneate & neuronsCO.sinTunedAct) ,:).actPD;
fh1 = figure;
[~,~,~,tunedPDs] = plotTuningDist(actPDTable,fh1, 'k', pi/2);
meanDir = rad2deg(circ_mean(tunedPDs));
%% Fit decoding models to velocity and position to determine which neurons
%  best reflect the kinematics of the handle
disp('all units')
params.flag = 1:length(tdAct(1).cuneate_spikes(1,:));
tdVel = linearVelocityDecoder(tdAct, params);
tdNNVel = nnVelocityDecoder(tdAct, params);

%% Only sorted units
disp('Sorted units')
params.flag = find(neuronsCO.isSorted);
params.z_score_x = true;
tdVel = linearVelocityDecoder(tdAct, params);
tdNNVel = nnVelocityDecoder(tdAct, params);
%% Only sorted cuneate units
disp('Sorted Cuneate')
params.flag = find(neuronsCO.isCuneate& neuronsCO.isSorted);
tdVel = linearVelocityDecoder(tdAct, params);
tdNNVel = nnVelocityDecoder(tdAct, params);
%% Only gracile channels
disp('Gracile')
params.flag = find(neuronsCO.isGracile);
tdVel = linearVelocityDecoder(tdAct, params);
tdNNVel = nnVelocityDecoder(tdAct, params);
%% Only sorted Gracile units
disp('Gracile sorted')
params.flag = find(neuronsCO.isGracile & neuronsCO.isSorted);
tdVel = linearVelocityDecoder(tdAct, params);
tdNNVel = nnVelocityDecoder(tdAct, params);
%% Only spindles
disp('spindles')
params.flag = find(neuronsCO.isSpindle & neuronsCO.sameDayMap & neuronsCO.isSorted);
tdVel = linearVelocityDecoder(tdAct, params);
tdNNVel = nnVelocityDecoder(tdAct, params);