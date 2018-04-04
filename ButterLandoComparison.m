close all
params.monkey = 'Lando';
params.array = 'cuneate';
params.date = 'all';
params.plotModDepth = false;
params.plotActVsPasPD = true;
params.plotAvgFiring = false;
params.plotAngleDif = false;
params.plotPDDists= false;
params.savePlots = false;
params.tuningCondition = {'isSpindle', 'sameDayMap'};

cuneate = neuronStructPlot(neuronsCOButter, params);

saveas(gca, ['C:\Users\csv057\Pictures\ButterVsLando\',params.monkey, strjoin(params.tuningCondition, '_'), '.pdf']);