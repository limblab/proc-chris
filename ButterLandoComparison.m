close all

params.plotModDepth = false;
params.plotActVsPasPD = true;
params.plotAvgFiring = false;
params.plotAngleDif = false;
params.plotPDDists= false;
params.savePlots = false;
params.tuningCondition = {'isGracile'};

cuneate = neuronStructPlot(neuronsCOButter, params);

