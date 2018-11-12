load('C:\Users\wrest\Documents\MATLAB\MonkeyData\RW\Butter\20180405\TD\Butter_RW_20180405_TD.mat')
[trial, neurons1] = compiledRWAnalysis(td);

sortedNeurons = neurons1(logical([neurons1.isSorted]),:);
tunedNeurons = neurons1(logical(checkIsTuned(sortedNeurons, pi/4)), :);

disp('% of sorted neurons tuned @ pi/4 confidence')
disp(height(tunedNeurons)/height(sortedNeurons));

plotRWNeuronsModDepth(tunedNeurons);
plotRWNeuronsPD(tunedNeurons);
plotRWNeuronsTuningCurve(tunedNeurons,'r');
