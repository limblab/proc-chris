monkey = 'Butter';
date = '20180703';
array = 'cuneate';
task = 'RWIso';
params.doCuneate = true;

mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, task);
tdButter = smoothSignals(tdButter, struct('signals', 'cuneate_spikes'));
tdButter = removeBadNeurons(tdButter);
%%
params.array = 'cuneate';
params.varToUse = 'force';
params.numBounds = 5;
params.xLimits = [-8,8];
params.yLimits = [-8, 8];
params.velocityCutoffHigh =  Inf;
params.velocityCutoffLow = -Inf;
params.savePlots=true;

for i =1: length(tdButter(1).cuneate_spikes(1,:))
    close all
    params.unitsToPlot = i;
    neuralHeatmap(tdButter, params);
    pause
end