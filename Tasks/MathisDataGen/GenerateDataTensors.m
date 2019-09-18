% ['CORB', 'DELT1', 'DELT2', 'DELT3', 'INFSP', 'LAT1', 'LAT2', 'LAT3',...
% 'PECM1', 'PECM2', 'PECM3', 'SUBSC', 'SUPSP', 'TMAJ', 'TMIN', 'ANC',...
% 'BIClong', 'BICshort', 'BRA', 'BRD', 'ECRL', 'PT', 'TRIlat', 'TRIlong', 'TRImed'],

clear all
close all
mapping = [21,22,23,24,37,38,39,40, 42,43, 43, 46,49,50,16,17,18,19,20,26,45,51,52,53];

load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\FilesForMathis\Butter_CO_20180326_TD_001.mat')

td = tdToBinSize(td,10);

td = getSpeed(td);
td = getMoveOnsetAndPeak(td);
%%
close all
params.ucThresh = .000001;
tdB = trimTD(td, 'idx_goCueTime', {'idx_goCueTime', 70});
[tdB, rem] = removeBadOpensim(tdB, params);
opensimB = cat(3,tdB.opensim);
dataB = opensimB(:, mapping,:);
% for i = 1:length(dataB(1,:,1))
%     figure
%     plot(squeeze(dataB(:,i,:)), 'k')
% end
hdf5write('ButterFile.h5', '/datasetB',dataB)
%%

load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\FilesForMathis\Han_COactpas_20171122_TD_001.mat')
td = tdToBinSize(td,10);
td = getSpeed(td);
td = getMoveOnsetAndPeak(td);
td = trimTD(td, 'idx_goCueTime', {'idx_goCueTime', 70});
td = removeBadOpensim(td, params);
opensimH = cat(3,td.opensim);
dataH = opensimH(:, mapping,:);
hdf5write('HanFile.h5', '/datasetH',dataH)
for i = 1:length(dataH(1,:,1))
    figure
    plot(squeeze(dataH(:,i,:)), 'k')
end
%%
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\FilesForMathis\Lando_CO_20170917_TD_001.mat')
td = tdToBinSize(td,10);
td = getSpeed(td);
td = getMoveOnsetAndPeak(td,params);
td = trimTD(td, 'idx_goCueTime', {'idx_goCueTime', 70});
td = removeBadOpensim(td);
opensimL = cat(3,td.opensim);
dataL = opensimL(:, mapping,:);
hdf5write('LandoFile.h5', '/datasetL',dataL)

for i = 1:length(dataL(1,:,1))
    figure
    plot(squeeze(dataL(:,i,:)), 'k')
end
