% clear all
close all
clear all
% 
% date = '20190129';
% monkey = 'Butter';
% unitNames = 'cuneate';

date = '20190213';
monkey = 'Crackle';
unitNames= 'cuneate';

% td1 =getTD(monkey, date, 'RW',1);
td2 =getTD(monkey, date, 'CO', 2);
td = [td2];
td = trimTD(td, {'idx_endTime',-500}, {'idx_endTime' ,500});
td = binTD(td, 10);
[processedTrial, neurons] = compiledRWAnalysis(td);
mappingFile = getSensoryMappings(monkey);
%%
neuronsRW = neurons;
neurons = insertMappingsIntoNeuronStruct(neurons, mappingFile);
%%
tunedNeurons = neurons(logical([neurons.PD.sinTuned]),:);
pds = tunedNeurons.PD.velPD;
proxNeurons = tunedNeurons(logical(tunedNeurons.proximal),:);
midNeurons = tunedNeurons(logical(tunedNeurons.midArm), :);
distNeurons = tunedNeurons(logical(tunedNeurons.distal),:);

proxPDs = proxNeurons.PD.velPD;
midPDs = midNeurons.PD.velPD;
distPDs = distNeurons.PD.velPD;

figure2();
subplot(2,2,1)
polarhistogram(pds, 15);
title('All tuned')

subplot(2,2,2)
polarhistogram(proxPDs, 15);
title('ProximalPDs')

subplot(2,2,3)
polarhistogram(midPDs, 15);
title('MiddlePDs')

subplot(2,2,4)
polarhistogram(distPDs, 15);
title('DistalPDs')

suptitle('PD Distribution for Crackle')
xlabel('Active PD angle (rads)')
ylabel('Sorted units')
set(gca,'TickDir','out', 'box', 'off')

%%
