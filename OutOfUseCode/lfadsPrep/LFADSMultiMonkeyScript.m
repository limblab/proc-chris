path='/media/chris/HDD/Data/MonkeyData/LFADSData/MultiMonkey Stitching S1 CoBump/';

tdHan = load([path, 'Han_20160415_td_peak.mat']);
tdHan = tdHan.td;

tdChips = load([path, 'Chips_20171116_td_peak.mat']);
tdChips = tdChips.td;

tdLando = load([path, 'Lando_20170320_td_peak.mat']);
tdLando = tdLando.td;

%%
velHan = cat(1, tdHan.vel);
velLando = cat(1,tdLando.vel);
velChips = cat(1, tdHan.vel);
velCombo = [cat(1,tdHan.vel); cat(1,tdChips.vel); cat(1,tdLando.vel)];

tdHanBin = binTD(tdHan,5);
% tdChipsBin = binTD(tdChips,5);
tdLandoBin = binTD(tdLando,5);

velHanBin = cat(1, tdHanBin.vel);
% velChipsBin = cat(1, tdChipsBin.vel);
velLandoBin = cat(1, tdLandoBin.vel);
velComboBin = [velHanBin;  velLandoBin];

spikesHanBin = cat(1, tdHanBin.area2_spikes);
% spikesChipsBin = cat(1, tdChipsBin.LeftS1_spikes);
spikesLandoBin = cat(1, tdLandoBin.LeftS1_spikes);

factorsHan = stretchFactors(rc.runs(1,1).posteriorMeans.factors);
% factorsChips = stretchFactors(rc.runs(2,1).posteriorMeans.factors);
factorsLando = stretchFactors(rc.runs(3,1).posteriorMeans.factors);
% factorsCombo = [stretchFactors(rc.runs(4,1).posteriorMeans(1).factors); stretchFactors(rc.runs(4,1).posteriorMeans(2).factors);...
%     stretchFactors(rc.runs(4,1).posteriorMeans(3).factors)];

modelXLando = fitlm(factorsLando, velLando(:,1))
modelYLando = fitlm(factorsLando, velLando(:,2))

% modelXChips = fitlm(factorsChips, velChips(:,1))
% modelYChips = fitlm(factorsChips, velChips(:,2))

modelXHan = fitlm(factorsHan, velHan(:,1))
modelYHan = fitlm(factorsHan, velHan(:,2))

% modelXCombo = fitlm(factorsCombo, velCombo(:,1))
% modelYCombo = fitlm(factorsCombo, velCombo(:,2))

modelXHanNeurons = fitlm(spikesHanBin, velHanBin(:,1))
modelYHanNeurons = fitlm(spikesHanBin, velHanBin(:,2))
% modelXChipsNeurons = fitlm(spikesChipsBin, velChipsBin(:,1))
% modelYChipsNeurons = fitlm(spikesChipsbin, velChipsBin(:,2))
modelXLandoNeurons = fitlm(spikesLandoBin, velLandoBin(:,1))
modelYLandoNeurons = fitlm(spikesLandoBin, velLandoBin(:,2))

close all

figure
plot(modelXLando)
title('modelXLando')

figure
plot(modelYLando)
title('modelYLando')


figure
plot(modelXHan)
title('modelXHan')

figure
plot(modelYHan)
title('modelYHan')

% 
% figure
% plot(modelXChips)
% title('modelXChips')
% 
% 
% figure
% plot(modelYChips)
% title('modelYChips')
% 
% 
% figure
% plot(modelXCombo)
% title('modelXCombo')
% 
% figure
% plot(modelYCombo)
% title('modelYCombo')

