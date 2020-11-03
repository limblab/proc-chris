clear all
close all

%%
snapDate = '20190829';
monkey = 'Snap';
recomputeSpindles = false;
mapping = getSensoryMappings(monkey);
%% Load file if needed
tdCN = getPaperFiles(2, 10);
tdCN = removeBadNeurons(tdCN, struct('remove_unsorted', false));
tdCN = removeUnsorted(tdCN);
tdCN = removeGracileTD(tdCN);
tdCN = removeNeuronsBySensoryMap(tdCN, struct('rfFilter', {{'handUnit', true; 'distal', true}})); 
tdCN = removeNeuronsByNeuronStruct(tdCN, struct('flags', {{'~handPSTHMan'}}));
tdCN = smoothSignals(tdCN, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', .03));
%% Data cleaning
tdCN = removeBadOpensim(tdCN);
tdCN = tdToBinSize(tdCN, 10);
windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

osNames = tdCN(1).opensim_names; % get Opensim names

mNames = osNames(54:end); % get only velocities
if ~isfield(tdCN, 'idx_movement_on')
    tdCN = getSpeed(tdCN);
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    tdCN = getMoveOnsetAndPeak(tdCN, params);
end

start_time_pas = {'idx_bumpTime', 0};
end_time_pas = {'idx_bumpTime', 13};
tdCNPas = tdCN(~isnan([tdCN.idx_bumpTime]));
tdCNPas = trimTD(tdCNPas, start_time_pas, end_time_pas);

dirBM = 'target_direction';
start_time_act = {'idx_movement_on', 0};
end_time_act = {'idx_movement_on', 40};
tdCNAct = tdCN(isnan([tdCN.idx_bumpTime]));
tdCNAct = trimTD(tdCNAct, start_time_act, end_time_act);

[hVelCNAct, actCNSpinSim] = simulateSpindlesByMuscle(tdCNAct);
[hVelCNPas, pasCNSpinSim] = simulateSpindlesByMuscle(tdCNPas);
%%
[muscVelByDir, dirs] = getMuscVelByDir(tdCNPas, true);

velNames = table( mNames',permute(muscVelByDir, [2, 1,3]));
velNames.Var1
ecu = velNames.Var2;
ecu = squeeze(ecu(14,:,:));
colors= linspecer(length(ecu(1,:)));
figure
for i =1:length(ecu(1,:))
    plot(0:10:130, ecu(:,i), 32, colors(i,:), 'LineWidth', 4)
    hold on
end
xlim([0,140])
ylim([-.015,.015])
dirStr = arrayfun(@num2str, dirs, 'UniformOutput', 0);
legend(dirStr)
title('ECU Velocity during Bump')
xlabel('Time (ms)')
ylabel('Length change (normalized)')
%%
[muscVelByDir, dirs] = getMuscVelByDir(tdCNAct, false);

velNames = table( mNames',permute(muscVelByDir, [2, 1,3]));
velNames.Var1
ecu = velNames.Var2;
ecu = squeeze(ecu(14,:,:));
colors= linspecer(length(ecu(1,:)));
figure
for i =1:length(ecu(1,:))
    plot(10:10:10*length(ecu(:,1)), ecu(:,i), 32, colors(i,:), 'LineWidth', 4)
    hold on
end
xlim([0,140])
ylim([-.015,.015])
dirStr = arrayfun(@num2str, dirs, 'UniformOutput', 0);
legend(dirStr)
title('ECU Velocity during Move')
xlabel('Time (ms)')
ylabel('Length change (normalized)')
%%
if ~recomputeSpindles
for i = 1:100
    for j = 1:length(actCNSpinSim(1,:,1))
        lm{i,j} = fitglm(hVelCNAct, squeeze(actCNSpinSim(:,j,i)));
        pdAct(i,j) = atan2(lm{i,j}.Coefficients.Estimate(3), lm{i,j}.Coefficients.Estimate(2));
        lm{i,j} = fitglm(hVelCNPas, squeeze(pasCNSpinSim(:,j,i)));
        pdPas(i,j) = atan2(lm{i,j}.Coefficients.Estimate(3), lm{i,j}.Coefficients.Estimate(2));
    end
    save('D:\MonkeyData\CO\Snap\20190829\neuronStruct\Snap08292020SpindleModel.mat', 'pdAct', 'pdPas');
end

end
%%
meanPDAct = mean(pdAct);
meanPDPas = mean(pdPas);
figure

scatter(meanPDAct, meanPDPas)
pdNames = table(mNames', meanPDPas');
%%
close all
useAct = false;
figure
neuronsS = getPaperNeurons(2, windowAct, windowPas);
neuronsB = getPaperNeurons(1,windowAct, windowPas);
neuronsC = getPaperNeurons(3,windowAct, windowPas);

close all
if useAct
    params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
        'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
        'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
        'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
        'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
        'tuningCondition', {{'isSorted','isCuneate','sinTunedAct','isSpindle'}});
    params.date = 'all';
    params.useMins = false;
    neuronsSFiltered = neuronStructPlot(neuronsS, params);
    neuronsBFiltered = neuronStructPlot(neuronsB,params);
    neuronsCFiltered = neuronStructPlot(neuronsC, params);
    [neuronsSpindleS, angDifS, spinPDS, pdS] = addSnapSpindlePDs(neuronsSFiltered, pdAct, mNames, useAct);
    [neuronsSpindleC, angDifC, spinPDC, pdC] = addCrackleSpindlePDs(neuronsCFiltered, pdAct, mNames,useAct);
    [neuronsSpindleB, angDifB, spinPDB, pdB] = addButterSpindlePDs(neuronsBFiltered, pdAct, mNames,useAct);
else
    params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
        'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
        'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
        'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
        'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', false, 'plotByModality', false,...
        'tuningCondition', {{'isSorted','isCuneate','sinTunedPas','isSpindle'}});
    params.date = 'all';
    params.useMins = false;
    neuronsSFiltered = neuronStructPlot(neuronsS, params);
    neuronsBFiltered = neuronStructPlot(neuronsB,params);
    neuronsCFiltered = neuronStructPlot(neuronsC, params);
    [neuronsSpindleS, angDifS, spinPDS, pdS] = addSnapSpindlePDs(neuronsSFiltered, pdPas, mNames, useAct);
    [neuronsSpindleC, angDifC, spinPDC, pdC] = addCrackleSpindlePDs(neuronsCFiltered, pdPas, mNames,useAct);
    [neuronsSpindleB, angDifB, spinPDB, pdB] = addButterSpindlePDs(neuronsBFiltered, pdPas, mNames,useAct);
end
angDifAll = [angDifS;angDifC;angDifB];

figure
histogram(angDifS,0:pi/8:pi)
figure
histogram(angDifC,0:pi/8:pi)
figure
histogram(angDifB,0:pi/8:pi)

figure
histogram(rad2deg(angDifAll), rad2deg(0:pi/8:pi))
set(gca,'TickDir','out', 'box', 'off')
xlabel('Angle between Spindle and Actual PD')
ylabel('# of neurons')
%%
figure
scatter(rad2deg(spinPDS), rad2deg(pdS), 32, 'filled')
hold on
scatter(rad2deg(spinPDC), rad2deg(pdC), 32, 'filled')
scatter(rad2deg(spinPDB), rad2deg(pdB), 32, 'filled')
plot([-180, 180],[-180,180], 'k--')
title('Spindle vs. Active PD')
xticks([-180, -90, 0, 90, 180])
yticks([-180, -90, 0, 90, 180])
xlabel('Spindle PD (rad)')
ylabel('Active PD')
set(gca,'TickDir','out', 'box', 'off')
legend('Sn', 'Cr', 'Bu')
%%
figure
scatter(neuronsS.spindlePD, neuronsS.pasPD.velPD)


%% Now do the muscle spindle PDs for all muscles, not just mapped ones

unmapForce = [unmapVec', forces'];
[uniqueMus, iC] = unique(unmapVec);
numUniqueMus = length(uniqueMus);
mapForceUnique = unmapForce(iC,:);
randMuscleVec = [];
for i = 1:length(unmapForce(:,1))
    randMuscleVec = [randMuscleVec; unmapForce(i,1)*ones(unmapForce(i,2),1)];
end
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
        pdAct{i}(j) = atan2(b(3), b(2));
     else
         lm1 = fitlm(hVel1, os1);
         pdAct{i}(j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
     end
 end
end
tmp = [pdAct{:}];
figure
polarhistogram(tmp, 12, 'FaceColor', 'b', 'FaceAlpha', 1)
title('Muscle PDs for all muscles')