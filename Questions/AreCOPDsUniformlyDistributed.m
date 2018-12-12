%% data preparation
clear all
close all
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\neuronStruct\NeuronsCO_Butter_20180607.mat')
%% get only sorted and tuned neurons
neuronStructSorted = neuronStructPlot(neuronStruct20180607, struct('tuningCondition', {{'isSorted', 'sinTunedAct', 'sinTunedPas'}}));
%% Get the PDs in active and passive
actPDs = [neuronStructSorted.actPD.velPD];
pasPDs = [neuronStructSorted.pasPD.velPD];
numBoots = 100;
%% Bootstrap dispersion coefficients from Von Mises distribution
for i =  1:numBoots
    pdSample= datasample([actPDs, pasPDs],length(actPDs));
    [~,kappaAct(i)] = circ_vmpar(pdSample(:,1));
    [~,kappaPas(i)] = circ_vmpar(pdSample(:,2));
    kappa(i) = kappaAct(i)- kappaPas(i);
end
%% Plot the distribution of these dispersion parameters
figure
histogram(kappaAct)
hold on
histogram(kappaPas)
legend
title('Nonuniformity metric kappa on PDs, bootstrapped')
xlabel('Kappa')
ylabel('Bootstrap iterations')
set(gca,'TickDir','out', 'box', 'off')

figure
histogram(kappa)
title('Nonuniformity metric kappa; Difference between act and pas, bootstrapped')
xlabel('Kappa difference')
ylabel('Bootstrap iterations')
set(gca,'TickDir','out', 'box', 'off')

%% Both the active and the passive are ~equally nonuniform.