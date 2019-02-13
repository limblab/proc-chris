% clear all
close all
clear al
% 
% date = '20190129';
% monkey = 'Butter';
% unitNames = 'cuneate';

date = '20190209';
monkey = 'Crackle';
unitNames= 'cuneate';

% td1 =getTD(monkey, date, 'RW',1);
td2 =getTD(monkey, date, 'RW', 1);
td = [td2];
td = trimTD(td, {'idx_endTime',-500}, {'idx_endTime' ,500});
td = binTD(td, 10);
[processedTrial, neurons] = compiledRWAnalysis(td);

%%
neuronsRW = neurons;
actPDTable = neuronsRW(find(neuronsRW.isSorted & neuronsRW.isTuned),:).PD;
gracilePDTable = neuronsRW(find(neuronsRW.isSorted & neuronsRW.isTuned),:).PD;

sorted = neuronsRW(find(neuronsRW.isSorted & neuronsRW.isTuned),:);
% for i = 1:length(actPasPDTable)

tunedVec = checkIsTuned(sorted, pi/4);
figure();
pds = [actPDTable.velPD];
pdsSinTuned = pds(logical(tunedVec));
histogram(pdsSinTuned, 15);
title('PD Distribution for Crackle')
xlabel('Active PD angle (rads)')
ylabel('Sorted units')
set(gca,'TickDir','out', 'box', 'off')
