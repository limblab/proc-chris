load('/media/chris/HDD/Data/MonkeyData/Tasks/COActPas/COActPasNeurons.mat')

close all

params.array = 'cuneate';
params.date = 'all';
params.plotModDepth = false;
params.plotActVsPasPD = true;
params.plotAvgFiring = false;
params.plotAngleDif = false;
params.plotPDDists= false;
params.savePlots = true;
params.tuningCondition = {'sinTunedAct', 'bumpTuned'};

neuronStructPlot(coActPasNeurons, params);

params.array = 'area2';
params.date = 'all';
params.plotModDepth = false;
params.plotActVsPasPD = true;
params.plotAvgFiring = false;
params.plotAngleDif = false;
params.plotPDDists= false;
params.savePlots = true;
params.tuningCondition = {'sinTunedAct', 'bumpTuned'};

neuronStructPlot(coActPasNeurons, params);
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
for i =1 :height(tunedCuneateNeurons)
    [overlapCun(i), scaleCun(i), shiftCun(i)]= getBestTuningRot(tunedCuneateNeurons(i,:).actTuningCurve.binnedResponse, tunedCuneateNeurons(i,:).pasTuningCurve.binnedResponse, bins);
end
for i =1:height(tunedS1Neurons)
    [overlapS1(i), scaleS1(i), shiftS1(i)] = getBestTuningRot(tunedS1Neurons(i,:).actTuningCurve.binnedResponse, tunedS1Neurons(i,:).pasTuningCurve.binnedResponse, bins);
end
%%
figure
histogram(scaleCun)
hold on
histogram(scaleS1)

figure
histogram(shiftCun)
hold on
histogram(shiftS1)

%%

close all
neuron75 = cuneateNeurons(69,:);
neuronStructPlot(neuron75)
%%
close all
param1.date = '03202017';
param1.array ='area2';
param1.tuningCondition = {'sinTunedAct', 'sinTunedPas'};
neuronStructPlot(coActPasNeurons, param1);

param1.date = 'all';
param1.array ='cuneate';
param1.tuningCondition = {'sinTunedPA', 'bumpTuned'};
neuronStructPlot(coActPasNeurons, param1);