elecNames1 = {'75', '81', '91'};
bicepsStim = load('Lando_20170511_SpindleStim_Unit65Biceps_003.mat');
ecrStim = load('Lando_20170511_SpindleStim_Unit81ECR_004.mat');
brachialisStim = load('Lando_20170511_SpindleStim_LeftS1_Unit91Brachialis_006.mat');
muscleStimd = {'Biceps', 'ECR', 'Brachialis'};
elecNames = strcat('elec', elecNames1);
td = parseFileByTrial(cds);
tdUnitGuide = td(1).RightCuneate_unit_guide;
for i = 1:length(elecNames)
    indNums(i) = find(strcmp({cds.units.label}, elecNames{i}) & strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID] <255);
    chanNums(i,1) = cds.units(indNums(i)).chan;
    chanNums(i,2) = cds.units(indNums(i)).ID;
    tdUnitNum(i) = find(tdUnitGuide(:, 1) == chanNums(i,1) & tdUnitGuide(:,2) == chanNums(i,2));
end
bicepsStim = load('Lando_20170511_SpindleStim_Unit65Biceps_003.mat');
ecrStim = load('Lando_20170511_SpindleStim_Unit81ECR_004.mat');
brachialisStim = load('Lando_20170511_SpindleStim_LeftS1_Unit91Brachialis_006.mat');

%% Analysis on Spindle Stimmed
close all
[hBiceps, pBiceps, ciBiceps, statsBiceps]= spindleFunction(cds,185, [10, 60])
[hECR, pECR, ciECR, statsECR]= spindleFunction(ecrStim.cds, 202, [0, 60])
[hBrachialis, pBrachialis, ciBrachialis, statsBrachialis] = spindleFunction(brachialisStim.cds, 202, [10, 45])
%% Analysis on units when stimming other muscles;
[htest, ptest, citest, statstest] = spindleFunction(bicepsStim.cds, 214, [0, 47.5])
[htest1, ptest1, citest1, statstest1] = spindleFunction(ecrStim.cds, 217, [10, 55])
[htest2, ptest2, citest2, statstest2] = spindleFunction(brachialisStim.cds, 222, [10, 47.5])