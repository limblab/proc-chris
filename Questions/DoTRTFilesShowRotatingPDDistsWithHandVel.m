clear all
close all
butterArray = 'cuneate';

monkeyButter = 'Butter';

dateButter = '20180524';
mappingLog = getSensoryMappings(monkeyButter);

td=getTD(monkeyButter, dateButter, 'TRT');
distribution = 'poisson';

tdBump = td(~isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, 'idx_bumpTime', {'idx_bumpTime', 13});
tdBump = binTD(tdBump,5);

tdMove = td(isnan([td.idx_bumpTime]));
goFlag = ~any(isnan(cat(1, tdMove.idx_goCueTime)),2);
tdMove = tdMove(goFlag);
tdMove = trimTD(tdMove, 'idx_goCueTime', 'idx_endTime');
tdMove = binTD(tdMove, 5);

tdMoveSpace1=  tdMove([tdMove.spaceNum] ==1);
tdMoveSpace2 = tdMove([tdMove.spaceNum] ==2);

params.monkey = td(1).monkey;
params.array= 'cuneate';
params.date = td(1).date;
params.out_signals = [params.array, '_spikes'];
params.distribution = distribution;
params.out_signal_names =td(1).([params.array, '_unit_guide']); 
%% To train new GLM

tablePDsActSpace1 = getTDPDs(tdMoveSpace1, params);
tablePDsActSpace2 = getTDPDs(tdMoveSpace2, params);
tablePDsActSpace1.sinTuned = tablePDsActSpace1.velTuned;
tablePDsActSpace2.sinTuned = tablePDsActSpace2.velTuned;

tablePDsBothSpaces = getTDPDs(tdMove, params);
tablePDsBothSpaces.sinTuned = tablePDsBothSpaces.velTuned;

tablePDsPas = getTDPDs(tdBump, params);
tablePDsPas.sinTuned = tablePDsPas.velTuned;

tablePDsBothSpacesSorted = tablePDsBothSpaces(tablePDsBothSpaces.signalID(:,2) >0, :);
%%
tablePDsActSpace1Sorted = tablePDsActSpace1(tablePDsActSpace1.signalID(:,2) >0, :);
tablePDsActSpace2Sorted = tablePDsActSpace2(tablePDsActSpace2.signalID(:,2) >0, :);

tablePDsPasSorted = tablePDsPas(tablePDsPas.signalID(:,2) >0, :);

pdsSpace1Tuned = tablePDsActSpace1Sorted(tablePDsActSpace1Sorted.sinTuned,:);
pdsSpace2Tuned = tablePDsActSpace2Sorted(tablePDsActSpace2Sorted.sinTuned,:);

pdsActTunedinPas = tablePDsBothSpacesSorted(tablePDsPasSorted.sinTuned,:);
pdsPasTunedinPas = tablePDsPasSorted(tablePDsPasSorted.sinTuned,:);
%%
figure
histogram(pdsSpace1Tuned.velPD,20, 'Normalization','probability')
hold on
histogram(pdsSpace2Tuned.velPD,20, 'Normalization','probability')
histogram(pdsPasTuned.velPD,20, 'Normalization','probability')
legend({'Space1','Space2', 'Passive'})
%%
tunedBothSpace1 = tablePDsActSpace1Sorted(tablePDsActSpace1Sorted.sinTuned & tablePDsActSpace2Sorted.sinTuned,:);
tunedBothSpace2 = tablePDsActSpace2Sorted(tablePDsActSpace1Sorted.sinTuned & tablePDsActSpace2Sorted.sinTuned,:);

% space1 = tunedBothSpace1;
% space2 = tunedBothSpace2;

space1 = pdsActTunedinPas;
space2 = pdsPasTunedinPas;

actPDs = rad2deg(space1.velPD);
actPDsHigh = rad2deg(space1.velPDCI(:,2));
actPDsLow = rad2deg(space1.velPDCI(:,1));

pasPDs = rad2deg(space2.velPD);
pasPDsHigh = rad2deg(space2.velPDCI(:,2));
pasPDsLow = rad2deg(space2.velPDCI(:,1));

yneg = pasPDs-pasPDsLow;
ypos = pasPDsHigh -pasPDs;

xneg = actPDs - actPDsLow;
xpos = actPDsHigh - actPDs;

fh2 = figure;
scatter(actPDs, pasPDs, 36,'k', 'filled')
hold on
errorbar(actPDs, pasPDs, yneg, ypos, xneg, xpos,'k.')
%         for i = 1:length(actPDs)
%             dx = -0.3; dy = 0.1; % displacement so the text does not overlay the data points
%             text(actPDs(i)+ dx, pasPDs(i) +dy, num2str(neurons.mapName(i)));
%         end
plot([-180, 180], [-180, 180], 'r--')
title(['Space 1 vs. Space 2 PDs'])
xlabel('Space 1')
ylabel('Space 2')
xlim([-180, 180])
ylim([-180, 180])
set(gca,'TickDir','out', 'box', 'off')
xticks([-180 -90 0 90 180])
yticks([-180 -90 0 90 180])

rot = angleDiff(rad2deg([tunedBothSpace1.velPD]), rad2deg([tunedBothSpace2.velPD]));
%%
fh1 = plotHandSpeed(tdMoveSpace1);
plotHandSpeed(tdMoveSpace2);
plotHandSpeed(tdBump);