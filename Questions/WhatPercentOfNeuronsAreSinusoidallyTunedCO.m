load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')
[trial, neurons1] = compiledCOActPasAnalysis(td);
%%

sortedNeurons = neurons1(logical([neurons1.isSorted]),:);
cuneateNeurons = sortedNeurons(logical([sortedNeurons.isCuneate]),:);
[tuningAct, tuningPas] = checkIsTuned(cuneateNeurons, pi/4);
tunedNeurons = cuneateNeurons(logical(tuningPas), :);

disp('# of sorted neurons actively tuned @ pi/4 confidence')
disp(sum(tuningAct));

disp('# of sorted neurons passively tuned @ pi/4 confidence')
disp(sum(tuningPas));

disp('# of sorted neurons actively & passively tuned @ pi/4 confidence')
disp(sum(tuningPas & tuningAct));


neuronStructPlot(tunedNeurons);