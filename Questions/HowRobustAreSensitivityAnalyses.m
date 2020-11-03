close all
clear all
windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
visualizeSensitivity = true;
numBootstraps = 100;
tit1 = 'Act vs Passive Tuned Spindle';
path1 = 'D:\Figures\SensitivityChecks1\';
%%
for i = 1:5
    disp(['File number: ', num2str(i)])
    param1.windowAct =windowAct;
    param1.windowPas =windowPas;
    param1.numBoots = numBootstraps;
    
    pSwitch.cutoff = pi/2;
    pSwitch.condition = 'act';
    neurons = getPaperNeurons(i, windowAct, windowPas);
%     td = getPaperFiles(i, 10);
    monkeys{i} = neurons(1,:).monkey{1};
    disp(num2str(sum(neurons.sinTunedAct)))
    disp(num2str(sum(neuronStructIsTuned(neurons, pSwitch))))
    neurons.sinTunedAct = [neuronStructIsTuned(neurons, pSwitch)]';
    disp(num2str(sum(neurons.sinTunedAct)))
    
    
    pSwitch.condition = 'pas';
    disp(num2str(sum(neurons.sinTunedPas)))
    disp(num2str(sum(neuronStructIsTuned(neurons, pSwitch))))
    neurons.sinTunedPas = [neuronStructIsTuned(neurons, pSwitch)]';
    disp(num2str(sum(neurons.sinTunedPas)))
    
    saveNeurons(neurons,'MappedNeurons');
    monkey = neurons(1,:).monkey;
    if visualizeSensitivity
        if ~strcmp(monkey, 'Han') & ~strcmp(monkey, 'Duncan') & ~strcmp(monkey, 'Chips')
        params = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','isSpindle', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
        
        else
        paramsS1 = struct('plotUnitNum', false,'plotModDepth', false, 'plotActVsPasPD', false, ...
        'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
        'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
        'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
        'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
        'tuningCondition', {{'isSorted', 'sinTunedAct|sinTunedPas', 'tuned'}});
    end
   paramsS1.date = 'all';

%        neurons = visualizeBasicSensitivity(neurons, td, param1);
       
       [nNeg(i), nPos(i), nNoDif(i)] = plotSensitivity(neurons, paramsS1);
       [nNegAll(i), nPosAll(i), nNoDifAll(i)] = plotSensitivityAll(neurons, paramsS1);
       [nNegVelAcc(i), nPosVelAcc(i), nNoDifVelAcc(i)] = plotSensitivityVelAcc(neurons, paramsS1);

%        [nNegWin(i,:), nPosWin(i,:), nNoDifWin(i,:)] = plotSensitivityWindows(neurons, params);
    end
    if visualizeSensitivity
%        neurons = visualizeBasicSensitivity(neurons, td, param1);
    end
end
%%
neuronsC = [getPaperNeurons(1, windowAct, windowPas);getPaperNeurons(2, windowAct, windowPas);getPaperNeurons(3, windowAct, windowPas)];
neuronsS1 = [getPaperNeurons(4, windowAct, windowPas);getPaperNeurons(5, windowAct, windowPas)];

[nNegC, nPosC, nNoDifC] = plotSensitivity(neuronsC, params);
[nNegAllC, nPosAllC, nNoDifAllC] = plotSensitivityAll(neuronsC, params);
[nNegVelAccC, nPosVelAccC, nNoDifVelAccC] = plotSensitivityVelAcc(neuronsC, params);

[nNegS, nPosS, nNoDifS] = plotSensitivity(neuronsS1, paramsS1);
[nNegAllS, nPosAllS, nNoDifAllS] = plotSensitivityAll(neuronsS1, paramsS1);
[nNegVelAccS, nPosVelAccS, nNoDifVelAccS] = plotSensitivityVelAcc(neuronsS1, paramsS1);

%%

tab = table(nNeg', nPos', nNoDif', nNegAll', nPosAll', nNoDifAll', nNegVelAcc', nPosVelAcc', nNoDifVelAcc', 'VariableNames',{'ActTunedVel', 'PasTunedVel', 'NoDifVel', 'ActTunedAll', 'PasTunedAll', 'NoDifAll', 'ActTunedVelAcc', 'PasTunedVelAcc', 'NoDifVelAcc'}, 'RowNames', [monkeys(:)]);

f1 = figure;
bar([sum(tab.ActTunedVel(1:3)), sum(tab.PasTunedVel(1:3)), sum(tab.NoDifVel(1:3)); sum(tab.ActTunedVel(4:5)), sum(tab.PasTunedVel(4:5)), sum(tab.NoDifVel(4:5))]);
legend('Active Tuned', 'Passive Tuned', 'No Difference')
xticklabels( {'Cuneate', 'Area 2'})
set(gca,'TickDir','out', 'box', 'off')
ylabel('Number of Units')
title([tit1, ' Vel'])
fname = ['NeuronsVelModel', strrep(tit1, ' ', '_'),'.png'];

saveas(f1, [path1,fname]);

f2 = figure;
bar([sum(tab.ActTunedAll(1:3)), sum(tab.PasTunedAll(1:3)), sum(tab.NoDifAll(1:3)); sum(tab.ActTunedAll(4:5)), sum(tab.PasTunedAll(4:5)), sum(tab.NoDifAll(4:5))]);
legend('Active Tuned', 'Passive Tuned', 'No Difference')
xticklabels( {'Cuneate', 'Area 2'})
set(gca,'TickDir','out', 'box', 'off')
ylabel('Number of Units')
title([tit1, ' All'])
fname = ['NeuronsAllModel', strrep(tit1, ' ', '_'),'.png'];
saveas(f2, [path1,fname]);


f3 = figure;
bar([sum(tab.ActTunedVelAcc(1:3)), sum(tab.PasTunedVelAcc(1:3)), sum(tab.NoDifVelAcc(1:3)); sum(tab.ActTunedVelAcc(4:5)), sum(tab.PasTunedVelAcc(4:5)), sum(tab.NoDifVelAcc(4:5))]);
legend('Active Tuned', 'Passive Tuned', 'No Difference')
xticklabels( {'Cuneate', 'Area 2'})
set(gca,'TickDir','out', 'box', 'off')
ylabel('Number of Units')
title([tit1, ' VelAcc'])
fname = ['NeuronsVelAccModel', strrep(tit1, ' ', '_'),'.png'];
saveas(f3, [path1,fname]);

%%

params = struct('plotUnitNum', true,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','sameDayMap','isSpindle', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
params.date = 'all';

[nNegAllSpin, nPosAllSpin, nNoDifAllSpin] = plotSensitivityAll(neuronsC, params);


params = struct('plotUnitNum', true,'plotModDepth', false, 'plotActVsPasPD', false, ...
    'plotAvgFiring', false, 'plotAngleDif', false, 'plotPDDists', false, ...
    'savePlots', false, 'useModDepths', false, 'rosePlot', false, 'plotFitLine', false,...
    'plotModDepthClassic', false, 'plotSinusoidalFit', false,'plotEncodingFits',false,...
    'useLogLog', false, 'useNewSensMetric', false, 'plotSenEllipse', false, 'plotSensitivity', true, 'plotByModality', true,...
    'tuningCondition', {{'isSorted','isCuneate','tuned','cutaneous','sameDayMap', 'sinTunedAct|sinTunedPas', 'handPSTHMan','~handUnit','~distal'}});
params.date = 'all';

[nNegAllCut, nPosAllCut, nNoDifAllCut] = plotSensitivityAll(neuronsC, params);
%%
figure
bar([nNegAllSpin, nPosAllSpin, nNoDifAllSpin; nNegAllCut, nPosAllCut, nNoDifAllCut])
xticklabels( {'Spindles', 'Cutaneous'})
legend('Active Tuned', 'Passive Tuned', 'No Difference')



