% clear all
monkey = 'Butter';
array = 'cuneate';
date = '20190110';
task= 'RW';
number = 2;

for number = 1:3

    td = getTD(monkey, date, task, number);
    td = removeBadNeurons(td);
    td = removeGracileTD(td);
    td1 = removeBadTrials(td);

    td_act = trimTD(td1, 'idx_movement_on', 'idx_endTime');
    td_pas = trimTD(td1, 'idx_startTime', 'idx_movement_on');
    unitGuide = td_act.cuneate_unit_guide;

    [trialProcessed, neuronNew] = compiledRWAnalysis(td_act);
    param.array = 'cuneate';
    param.sinTuned= neuronNew.isTuned;
    param.in_signals      = 'vel';

    neuronsRW = [neuronNew];
    %%
    fh1 = figure;
    [~,~,~,tunedPDs] = plotTuningDist(neuronsRW.PD,fh1, 'k', pi/2);
    actPDtable = neuronsRW.PD;
    %%


    %%
    [curvesAct] = getTuningCurves(td_act,struct('out_signals',{'cuneate_spikes'},'out_signal_names',{td_act(1).cuneate_unit_guide},'num_bins',8));
    %%
    isTuned_params = struct('move_corr','vel','CIthresh',pi/3, 'out_signals', 'cuneate_spikes');
    isTunedAct = neuronsRW.PD.velTuned;
    actPDTableTuned = actPDtable;

    curvesActTuned = curvesAct;

    colorsAct = linspecer(sum(isTunedAct));
    %%
%     maxDist = max(max(curvesActTuned.velCurveCIhigh));
%     for i = 1:sum(isTunedAct)
%         plotTuning(actPDTableTuned(i,:), curvesActTuned(i,:),maxDist,colorsAct(i,:),'-')
%     end
    neuronsRW.actCurve = curvesAct;
    saveNeurons(neuronsRW, num2str(number));
    title(['Active PDs Condition ', num2str(i)])
    %%
end
%% File 1  has .75 N force bias to the left
%% File 2 has a 1.5 N force bias to the right
%% File 3 is normal
% clear all
load('Butter_01-10-2019_RW_cuneate_idx_movement_on_idx_movement_on_NeuronStruct_1.mat')
neurons1 = neurons;
load('Butter_01-10-2019_RW_cuneate_idx_movement_on_idx_movement_on_NeuronStruct_2.mat')
neurons2 = neurons;
load('Butter_01-10-2019_RW_cuneate_idx_movement_on_idx_movement_on_NeuronStruct_3.mat')
neurons3 = neurons;
colorsAct = linspecer(3);
tuned = [neurons1.isTuned & neurons2.isTuned & neurons3.isTuned];
neurons1 = neurons1(tuned,:);
neurons2 = neurons2(tuned,:);
neurons3 = neurons3(tuned,:);

for i = 1:height(neurons1)
    close all
    figure2()
    sameNeuron = [neurons1(i,:);neurons2(i,:); neurons3(i,:)];
    maxDist = max(max(sameNeuron.actCurve.velCurveCIhigh));
    actPDTable1 = neurons1.PD(i,:);
    actCurve1 = neurons1.actCurve(i,:);
    actPDTable2 = neurons2.PD(i,:);
    actCurve2 = neurons2.actCurve(i,:);
    actPDTable3 = neurons3.PD(i,:);
    actCurve3 = neurons3.actCurve(i,:);
    plotTuning(actPDTable1, actCurve1,maxDist,colorsAct(1,:),'-')
    hold on
    plotTuning(actPDTable2, actCurve2, maxDist, colorsAct(2,:), '-')
    plotTuning(actPDTable3, actCurve3, maxDist, colorsAct(3,:), '-')
    legend('.75 N Bias Left', '1.5 N Bias Right', 'No bias')
    title(['Bias force Tuning U', num2str(unitGuide(i,1)),' E',num2str(unitGuide(i,2))])
    saveas(gca, ['BiasForce_U', num2str(unitGuide(i,1)),'E',num2str(unitGuide(i,2)), '.png'])
    saveas(gca, ['BiasForce_U', num2str(unitGuide(i,1)),'E',num2str(unitGuide(i,2)), '.pdf'])
end
%% Testing to see if the general tgPD distribution changes
cutoff = pi/4;
    
figure2()
histogram(neurons1.PD.velPD,15)
hold on
histogram(neurons2.PD.velPD,15)
histogram(neurons3.PD.velPD,15)
legend('LeftBias', 'RightBias', 'NoBias')
title('PD Distribution')
xlabel('Angle(rads)')
ylabel('# of neurons')

%% Testing to see if the PDs shift at all
leftBias = angleDiff(neurons3.PD.velPD, neurons1.PD.velPD, true, true);
rightBias = angleDiff(neurons3.PD.velPD, neurons2.PD.velPD, true, true);

figure2()
histogram(leftBias,15);
hold on
histogram(rightBias, 15);
title('PD shifts caused by force bias')
legend('LeftBias', 'RightBias')
xlabel('Change in PD direction (rads)')
ylabel('# of neurons')
%% Testing to see if modulation depths are different with different force conditions
modDepthNoForce = neurons3.PD.velModdepth;
modDepthLeftForce = neurons1.PD.velModdepth;
modDepthRightForce = neurons2.PD.velModdepth;
figure2()
histogram(modDepthNoForce, 15)
hold on
histogram(modDepthLeftForce,15)
histogram(modDepthRightForce,15)
title('Modulation depths of neurons')
legend('No force bias', 'LeftBias', 'RightBias')
xlabel('Modulation Depth (Hz)/100')
ylabel('# of neurons')
%%
figure2()
histogram(modDepthNoForce- modDepthLeftForce,15)
hold on
histogram(modDepthNoForce- modDepthRightForce,15)
title('Effect of force bias on modulation depths of neurons')
legend('Left Force bias', 'Right force bias')
xlabel('Change in Modulation depth (Hz)/100')
ylabel('# of neurons')