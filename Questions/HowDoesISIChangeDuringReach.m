close all
clear all
windowAct= {'idx_movement_on', 10; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
plotPath = 'D:\Figures\ISIHist\';

td = getPaperFiles(3, 10);

td = getSpeed(td);
td = getMoveOnsetAndPeak(td);
td = removeUnsorted(td);
td = removeBadTrials(td);
td(strcmp([td.result], 'A')) =[]; 

tdAct = trimTD(td, windowAct(1,:), windowAct(2,:));
tdPre = trimTD(td, {'idx_movement_on', -30}, {'idx_movement_on', -10});
cnPre = tdPre.cuneate_ts;
tdPD = tdAct([tdAct.target_direction] == 3*pi/2);
tdAnti = tdAct([tdAct.target_direction] == pi/2);

preISI = getISITD(tdPre);
pdISI = getISITD(tdPD);
antiISI = getISITD(tdAnti);
%%
unit = [40,1];
ind = find([preISI.guide(:,1)] == unit(1) & [preISI.guide(:,2)] == unit(2));
edges = 0:.005:0.2;
f1 = figure;
subplot(3,1,1)
histogram(preISI.isi{ind},edges, 'Normalization', 'probability')
subplot(3,1,2)
histogram(pdISI.isi{ind},edges, 'Normalization', 'probability')
subplot(3,1,3)
histogram(antiISI.isi{ind},edges, 'Normalization', 'probability')