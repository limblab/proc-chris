load('/mediacompchris/HDD/Data/MonkeyData/Tasks/COActPas/COActPasNeurons.mat')

close all

params.array = 'cuneate';
params.date = 'all';
params.plotModDepth = false;
params.plotActVsPasPD = false;
params.plotAvgFiring = false;
params.plotAngleDif = false;
params.plotPDDists= false;
params.savePlots = false;
params.tuningCondition = {'sinTunedAct', 'bumpTuned'};

cuneate = neuronStructPlot(coActPasNeurons, params);

params.array = 'area2';
params.date = 'all';
params.plotModDepth = false;
params.plotActVsPasPD = false;
params.plotAvgFiring = false;
params.plotAngleDif = false;
params.plotPDDists= false;
params.savePlots = false;
params.tuningCondition = {'sinTunedAct', 'bumpTuned'};

area2 = neuronStructPlot(coActPasNeurons, params);
%%

bins = linspace(-pi,pi,5);
bins = bins(2:end);

s1Neurons = coActPasNeurons(strcmp('LeftS1',[coActPasNeurons.array]) | strcmp('area2',[coActPasNeurons.array]),:);
cuneateNeurons = coActPasNeurons(~strcmp('LeftS1',[coActPasNeurons.array]) & ~strcmp('area2',[coActPasNeurons.array]),:);

cuneateFlag = ~strcmp('LeftS1',[coActPasNeurons.array]) & ~strcmp('area2',[coActPasNeurons.array]);
whichUnits = find(coActPasNeurons.bumpTuned & coActPasNeurons.moveTuned);
coActPasTunedNeurons = coActPasNeurons(whichUnits,:);
compareTuning({coActPasNeurons.actTuningCurve, coActPasNeurons.pasTuningCurve},...
    {coActPasNeurons.actPD, coActPasNeurons.pasPD},bins, ...
    whichUnits);
[fh1, output1] = rotate_tuning_curves(coActPasNeurons(whichUnits,:).actTuningCurve, coActPasNeurons(whichUnits,:).pasTuningCurve, bins);
output1.complexScale = output1.complexScale';
output1.scale_factor= output1.scale_factor';
output1.rot_factor = output1.rot_factor';
coActPasTunedNeurons = [coActPasTunedNeurons,struct2table(output1)];
%%
figure
histogram(tunedS1Neurons.rot_factor,10)
hold on
histogram(tunedCuneateNeurons.rot_factor,10)
%%
close all
bins = linspace(-pi,pi,5);
bins = bins(2:end);
% tunedCuneateNeurons = coActPasTunedNeurons(~strcmp('LeftS1',[coActPasTunedNeurons.array]) & ~strcmp('area2',[coActPasTunedNeurons.array]),:);
% tunedS1Neurons = coActPasTunedNeurons(strcmp('LeftS1',[coActPasTunedNeurons.array]) | strcmp('area2',[coActPasTunedNeurons.array]),:);
tunedCuneateNeurons = cuneate;
tunedS1Neurons = area2;

scaleCun = zeros(1,height(tunedCuneateNeurons));
scaleS1 = zeros(1, height(tunedS1Neurons));

shiftCun = zeros(1, height(tunedCuneateNeurons));
shiftS1 = zeros(1, height(tunedS1Neurons));

overlapCun = zeros(1,height(tunedCuneateNeurons));
overlapS1 = zeros(1, height(tunedS1Neurons));

for i =1 :height(tunedCuneateNeurons)
    [overlapCun(i), scaleCun(i), shiftCun(i)]= getBestTuningRot(tunedCuneateNeurons(i,:).actTuningCurve.binnedResponse, tunedCuneateNeurons(i,:).pasTuningCurve.binnedResponse, bins, false, 'interp');
end
for i =1:height(tunedS1Neurons)
    [overlapS1(i), scaleS1(i), shiftS1(i)] = getBestTuningRot(tunedS1Neurons(i,:).actTuningCurve.binnedResponse, tunedS1Neurons(i,:).pasTuningCurve.binnedResponse, bins, false, 'interp');
end

curve1 = tunedCuneateNeurons.actTuningCurve.binnedResponse;
curve2 = tunedCuneateNeurons.pasTuningCurve.binnedResponse;
[overlapRandCun, scaleRandCun, shiftRandCun] = getBaselineRotationDist(curve1, curve2);

curve1 = tunedS1Neurons.actTuningCurve.binnedResponse;
curve2 = tunedS1Neurons.pasTuningCurve.binnedResponse;
[overlapRandS1,  scaleRandS1,  shiftRandS1] = getBaselineRotationDist(curve1, curve2);




disp('Done!')
%%
close all
figure
histogram(scaleCun)
hold on
histogram(scaleS1)
histogram(scaleRandCun)
histogram(scaleRandS1)
title('Scaling factor from Active to Passive')
legend({'Cuneate', 'S1', 'Random Cuneate', 'Random S1'})

figure
histogram(shiftCun)
hold on
histogram(shiftS1)
histogram(shiftRandCun)
histogram(shiftRandS1)
title('Rotation from Active to Passive (Degrees)')
legend({'Cuneate', 'S1', 'Random Cuneate', 'Random S1'})

bootOverlapCun = bootstrp(1000, @mean, overlapCun);
bootOverlapS1 = bootstrp(1000, @mean, overlapS1);

bootShiftCun = bootstrp(1000, @mean, shiftCun);
bootScaleCun = bootstrp(1000, @mean, scaleCun);

bootShiftS1  = bootstrp(1000, @mean, shiftS1);
bootScaleS1  = bootstrp(1000, @mean, scaleS1);

bootAbsShiftCun = bootstrp(1000, @mean, abs(shiftCun));
bootAbsShiftS1  = bootstrp(1000, @mean, abs(shiftS1));

bootOverlapRandCun = bootstrp(1000, @mean, overlapRandCun);
bootOverlapRandS1 = bootstrp(1000, @mean, overlapRandS1);

bootScaleRandCun = bootstrp(1000, @mean,scaleRandCun);
bootScaleRandS1 = bootstrp(1000, @mean, scaleRandS1);

bootShiftRandCun = bootstrp(1000, @mean, shiftRandCun);
bootShiftRandS1 = bootstrp(1000, @mean, shiftRandS1);

bootAbsShiftRandCun = bootstrp(1000,@mean, abs(shiftRandCun));
bootAbsShiftRandS1 = bootstrp(1000, @mean, abs(shiftRandS1));


figure
histogram(bootOverlapCun)
hold on
histogram(bootOverlapS1)
histogram(bootOverlapRandCun)
histogram(bootOverlapRandS1)
title('Excesss in tuning Overlap Bootstrapped Dists (lower means better fit')
legend({'Cuneate', 'S1', 'Random Cuneate', 'Random S1'})

figure
histogram(bootShiftCun)
hold on
histogram(bootShiftS1)
histogram(bootShiftRandCun)
histogram(bootShiftRandS1)
title('Bootstrapped Shift')
legend({'Cuneate', 'S1', 'Random Cuneate', 'Random S1'})

figure
histogram(bootScaleCun)
hold on
histogram(bootScaleS1)
histogram(bootScaleRandCun)
histogram(bootScaleRandS1)
title('Bootstrapped Scale')
legend({'Cuneate', 'S1', 'Random Cuneate', 'Random S1'})

figure
histogram(bootAbsShiftCun)
hold on
histogram(bootAbsShiftS1)
histogram(bootAbsShiftRandCun)
histogram(bootAbsShiftRandS1)
title('Bootstrapped Abs Shift')
legend({'Cuneate', 'S1', 'Random Cuneate', 'Random S1'})

sortBootAbsShiftCun = sort(bootAbsShiftCun);
sortBootAbsShiftS1  = sort(bootAbsShiftS1);

sortBootScaleCun = sort(bootScaleCun);
sortBootScaleS1 = sort(bootScaleS1);

sortBootShiftCun = sort(bootShiftCun);
softBootShiftS1 = sort(bootShiftS1);

sortBootOverlapCun = sort(bootOverlapCun);
sortBootOverlapS1 = sort(bootOverlapS1);
%%
curves = tunedCuneateNeurons.actTuningCurve.binnedResponse;
[overlapDist, scaleDist, shiftDist] = getBaselineRotationDist(curves);
histogram(overlapDist)


%%
if sortBootOverlapCun(500) > sortBootOverlapS1(975)
    disp('Cuneate tuning is differently shaped compared to S1')
else
    disp('Cuneate and S1 have similar overlap')
end

if sortBootAbsShiftCun(975) > sortBootAbsShiftS1(500)
    disp('Shift is greater in Cuneate than S1')
else
    disp('Shift is unclear')
end
if sortBootScaleCun(975) < sortBootScaleS1(500)
    disp('Cunate passive tuning is smaller than S1')
else
    disp('Cuneate passive scaling is indistinguishable from S1')

end

if sortBootScaleCun(975) <1
    disp('Cuneate passive scaling is significant')
else
    disp('Cuneate is scaled similarly in active and passive')
end

if sortBootScaleS1(975) <1
    disp('S1 passive scale is significant')
else
    disp('S1 is scaled similarly in active and passive')

end


%%

close all
neuron75 = cuneateNeurons(69,:);
neuronStructPlot(neuron75)
%%
close all
param1.date = 'all';
param1.array ='area2';
param1.tuningCondition = {'sinTunedAct', 'bumpTuned'};
neuronStructPlot(coActPasNeurons, param1);

param1.date = 'all';
param1.array ='cuneate';
param1.tuningCondition = {'sinTunedAct', 'bumpTuned'};
neuronStructPlot(coActPasNeurons, param1);