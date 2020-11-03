clearvars -except tdCN tdS1 nCN nS1
close all
tenMs = 10;

windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

if ~exist('tdCN')
    monkey = 'Crackle';
    date = '20190418';
    num1 =1;
    tdCN = getTD(monkey, date, 'CO', num1, tenMs);

    monkey = 'Han';
    date = '20171122';
    array = 'LeftS1Area2';
    num1 = 1;
    tdS1 = getTD(monkey, date, 'CO', num1, tenMs);

    tdS1 = getSpeed(tdS1);
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    tdS1 = getMoveOnsetAndPeak(tdS1, params);

    tdCN = getSpeed(tdCN);
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    tdCN = getMoveOnsetAndPeak(tdCN, params);
    
    
    nCN = getPaperNeurons(3, windowAct, windowPas);
    nS1 = getPaperNeurons(5, windowAct, windowPas);
    tdCN = removeUnsorted(tdCN);
    tdS1 = removeUnsorted(tdS1);
end

nCN = nCN(logical(nCN.isSorted),:);
nS1 = nS1(logical(nS1.isSorted),:);

spindleFlag = nCN.isSpindle;
propFlag = nCN.proprio;
cutFlag = nCN.cutaneous;
proxFlag = nCN.proximal;
midFlag = nCN.midArm;
distFlag = nCN.distal;
handFlag = nCN.handUnit;

flagPropCN = propFlag & (proxFlag | midFlag);
flagCutCN = cutFlag & (proxFlag |midFlag);

dirsMCN = unique([tdCN.target_direction]);
dirsMS1 = unique([tdS1.target_direction]);
dirsMCN(isnan(dirsMCN)) = [];
dirsMS1(isnan(dirsMS1)) = [];


dirsBCN = unique([tdCN.bumpDir]);
dirsBS1 = unique([tdS1.bumpDir]);

guideCN = tdCN.cuneate_unit_guide;
guideS1 = tdS1.LeftS1Area2_unit_guide;

firingCN = zeros(length(dirsMCN), length(guideCN(:,1)));
firingS1 = zeros(length(dirsMS1), length(guideS1(:,1)));

tdCNPre = trimTD(tdCN,  {'idx_movement_on', -10}, {'idx_movement_on', -5});
tdS1Pre = trimTD(tdS1,  {'idx_movement_on', -10}, {'idx_movement_on', -5});

preCN = mean(cat(1,tdCNPre.cuneate_spikes));
preS1 = mean(cat(1,tdS1Pre.LeftS1Area2_spikes));



for i = 1:length(dirsMCN)
    tdDirCN{i} = tdCN([tdCN.target_direction]==dirsMCN(i));
    tdDirS1{i} = tdS1([tdS1.target_direction]==dirsMS1(i));
    tdCNMove = trimTD(tdDirCN{i}, 'idx_movement_on', {'idx_movement_on', 30});
    tdS1Move = trimTD(tdDirS1{i}, 'idx_movement_on', {'idx_movement_on', 30});
    
    firingCN(i,:) = mean(cat(1,tdCNMove.cuneate_spikes));
    firingS1(i,:) = mean(cat(1,tdS1Move.LeftS1Area2_spikes));
    
    
    
end
%%
plotting = true;
for i = 1:length(firingCN(1,:))
    if plotting
        figure
        plot(firingCN(:,i))
        hold on
        plot([0,9],[preCN(i), preCN(i)], 'r')
        title(['Cuneate Elec ', num2str(guideCN(i,1)), ' Unit ' , num2str(guideCN(i,2)),' ', nCN(i,:).desc])
    end
    firDifCN(i,:) = firingCN(:,i) - repmat(preCN(i), length(firingCN(:,i)),1);
end

%%
for i = 1:length(firingS1(1,:))
    if plotting
    figure
    plot(firingS1(:,i))
    hold on
    plot([0,9], [preS1(i), preS1(i)], 'r')
    title(['Area 2 Elec ', num2str(guideCN(i,1)), ' Unit ' , num2str(guideCN(i,2))])
    end
    firDifS1(i,:) = firingS1(:,i) - repmat(preS1(i), length(firingS1(:,i)),1);
    
    
end
%%


pctNegCN = sum(all(firDifCN'>0))/ length(firDifCN(:,1));
pctNegS1 = sum(all(firDifS1'>0))/ length(firDifS1(:,1));


firDifPropCN = firDifCN(flagPropCN,:);
firDifCutCN = firDifCN(flagCutCN,:);

pctNegPropCN = sum(all(firDifPropCN'>0))/ length(firDifPropCN(:,1));
pctNegCutCN = sum(all(firDifCutCN'>0))/ length(firDifCutCN(:,1));


figure
bar([pctNegCN, pctNegS1])
title('% of neurons in CN and S1 that increase FR in all directions')
xticklabels({'Cuneate','Area 2'})

figure
bar([pctNegPropCN, pctNegCutCN])
xticklabels({'Proprioceptive','Cutaneous'})

title('% of CN neurons the increase FR in all directions by modality')

%%
preUnit1 = preCN(21)/mean(firingCN(:,21));
unit1= firingCN(:,21)/mean(firingCN(:,21));
preUnit2 = preCN(19)/mean(firingCN(:,19));
unit2 = firingCN(:,19)/mean(firingCN(:,19));

preComb = preUnit1-preUnit2;
unitComb = unit1-unit2;

figure
plot(unitComb)

xlabel('Hand direction')
ylabel('Normalized FR')
title('Combined Cutaneous units with inhibition')
