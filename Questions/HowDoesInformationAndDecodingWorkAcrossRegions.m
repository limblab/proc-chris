close all
clear all
smoothWidth = 0.05;
cnFlag = [1:3];
s1Flag = [4:5, 11];
numBoots = 100;
minUnits = 10;
for i = [3]
    td = getPaperFiles(i,10);
    monkey = td(1).monkey;
    monkeys{i} = monkey;
    array = getArrayName(td);
    td = removeUnsorted(td);
    if strcmp(array, 'cuneate')
        td = removeGracileTD(td);
        td = removeNeuronsBySensoryMap(td, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
    end
    date1 = td(1).date;
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td);
    td = smoothSignals(td, struct('signals', [array,'_spikes'], 'calc_rate',true, 'width', smoothWidth));    

    tdAct = td;
    tdPas = td;
    tdPas(isnan([tdPas.bumpDir])) =[];
    if i ~=1
        tdAct = tdAct(isnan([tdAct.idx_bumpTime]));
    end
    tdAct = trimTD(tdAct, {'idx_movement_on', -10}, {'idx_movement_on',40});
    tdPas = trimTD(tdPas, {'idx_bumpTime',-10},  {'idx_bumpTime', 13});
    tdPas = tdToBinSize(tdPas, 10);
    tdAct = tdToBinSize(tdAct, 10);
    tdAct(mod([tdAct.target_direction], pi/2)~=0)=[];
    tdPas(mod([tdPas.bumpDir],90)~=0) =[];
    
    dirsM = uniquetol([tdAct.target_direction],0.0001);
    dirsM(isnan(dirsM)) = [];
    colors = linspecer(length(dirsM));
    
    dirsB = uniquetol([tdPas.bumpDir],0.0001);
    dirsB(isnan(dirsB)) = [];
    dirsB = mod(dirsB,360);
    dirsB = unique(dirsB);
    colorsB = linspecer(length(dirsB));
    
    fh1 = figure;
    for j = 1:length(dirsM)
        pos = cat(1, tdAct([tdAct.target_direction] == dirsM(j)).pos);
        
        scatter(pos(:,1), pos(:,2), 16, colors(j,:))
        hold on
    end
    title([monkey, ' ', date1])
    
    fh2 =figure;
    for j = 1:length(dirsB)
        pos = cat(1, tdPas(mod([tdPas.bumpDir], 360) == dirsB(j)).pos);
        
        scatter(pos(:,1), pos(:,2), 16, colors(j,:))
        hold on
    end
    title([monkey, ' Bump ', date1])
    saveas(fh1, ['C:\Users\wrest\Pictures\KinComparison\',monkey,num2str(i), '_reachKin.png']);
    saveas(fh2, ['C:\Users\wrest\Pictures\KinComparison\',monkey,num2str(i), '_bumpKin.png']);
    
    pos = cat(1,tdAct.pos);
    vel = cat(1,tdAct.vel);
    acc = cat(1,tdAct.acc);
    firing = cat(1,tdAct.([array, '_spikes']));
    firingBump = cat(1,tdPas.([array, '_spikes']));
    posBump = cat(1, tdPas.pos);
    velBump = cat(1, tdPas.vel);
    accBump = cat(1, tdPas.acc);
    
    numUnits(i) = length(firing(1,:));
    
    for j = 1:numBoots
        disp([monkey, ' bootstrap # ', num2str(j)])
        rand1 = randperm(numUnits(i), minUnits);
        velXLM = fitlm(firing(:,rand1), vel(:,1));
        velYLM = fitlm(firing(:,rand1), vel(:,2));
        velR2(i,1,j) = velXLM.Rsquared.Ordinary;
        velR2(i,2,j) = velYLM.Rsquared.Ordinary;

        posXLM = fitlm(firing(:,rand1), pos(:,1));
        posYLM = fitlm(firing(:,rand1), pos(:,2));
        posR2(i,1,j) = posXLM.Rsquared.Ordinary;
        posR2(i,2,j) = posYLM.Rsquared.Ordinary;

        accXLM = fitlm(firing(:,rand1), acc(:,1));
        accYLM = fitlm(firing(:,rand1), acc(:,2));
        accR2(i,1,j) = accXLM.Rsquared.Ordinary;
        accR2(i,2,j) = accYLM.Rsquared.Ordinary;
        
        velXLMBump = fitlm(firingBump(:,rand1), velBump(:,1));
        velYLMBump = fitlm(firingBump(:,rand1), velBump(:,2));
        velR2Bump(i,1,j) = velXLMBump.Rsquared.Ordinary;
        velR2Bump(i,2,j) = velYLMBump.Rsquared.Ordinary;

        posXLMBump = fitlm(firingBump(:,rand1), posBump(:,1));
        posYLMBump = fitlm(firingBump(:,rand1), posBump(:,2));
        posR2Bump(i,1,j) = posXLMBump.Rsquared.Ordinary;
        posR2Bump(i,2,j) = posYLMBump.Rsquared.Ordinary;

        accXLMBump = fitlm(firingBump(:,rand1), accBump(:,1));
        accYLMBump = fitlm(firingBump(:,rand1), accBump(:,2));
        accR2Bump(i,1,j) = accXLMBump.Rsquared.Ordinary;
        accR2Bump(i,2,j) = accYLMBump.Rsquared.Ordinary;
    end
    
    for j = 1:length(firing(1,:))
        encLM = fitlm(vel, firing(:,j));
        encActR2{i}(j) = encLM.Rsquared.Ordinary;
        encActNorm{i}(j) = norm(encLM.Coefficients.Estimate(2:3));

        encLM = fitlm(velBump, firingBump(:, j));
        encPasR2{i}(j) = encLM.Rsquared.Ordinary;
        encPasNorm{i}(j) = norm(encLM.Coefficients.Estimate(2:3));
    end
end
%% In general, area 2 and CN decoding is similar across conditions and across brain regions
%% However, variance seems wider in CN across neurons than in S1 (i.e. S1 distributes useful information more broadly)
close all
numBoots = 2;
s1Monks = monkeys(s1Flag);
velR2CN = velR2(cnFlag,:,:);
velR2S1 = velR2(s1Flag,:,:);
velR2CNMarg =[];
velR2S1Marg =[];
for i = 1:numBoots
    velR2CNMarg = [velR2CNMarg; velR2CN(:,:,i)];
    velR2S1Marg = [velR2S1Marg; velR2S1(:,:,i)];
end

velR2CNBump = velR2Bump(cnFlag,:,:);
velR2S1Bump = velR2Bump(s1Flag,:,:);

velR2CNMargBump =[];
velR2S1MargBump =[];
for i = 1:numBoots
    velR2CNMargBump = [velR2CNMargBump; velR2CNBump(:,:,i)];
    velR2S1MargBump = [velR2S1MargBump; velR2S1Bump(:,:,i)];
end

[cnActVar, cnPasVar, s1ActVar, s1PasVar] = crossCompareBumpMoveCNS1(velR2CN, velR2CNBump, velR2S1, velR2S1Bump, 'Vel')
ttest2(velR2CNMarg, velR2S1Marg)
ttest2(velR2CNMargBump, velR2S1MargBump)

mean(velR2CNMargBump)
mean(velR2S1MargBump)
mean(velR2CNMarg)
mean(velR2S1Marg)

%%
encActCN = [encActR2{cnFlag}];
encActS1 = [encActR2{s1Flag}];
encPasCN = [encPasR2{cnFlag}];
encPasS1 = [encPasR2{s1Flag}];

encActCNNorm = [encActNorm{cnFlag}];
encPasCNNorm = [encPasNorm{cnFlag}];
encActS1Norm = [encActNorm{s1Flag}];
encPasS1Norm = [encPasNorm{s1Flag}];

monkeyVec =[];
for i = 1:length(cnFlag)
    monkeyVec = [monkeyVec; i*ones(length(encActR2{cnFlag(i)}),1)];
end
% encActCN(encActCN<.05 & encPasCN<0.05)=[];
% encPasCN(encActCN<0.05 & encPasCN<0.05) =[];

figure
histogram(encActCN)
hold on
histogram(encActS1)
colors  = linspecer(length(cnFlag));
colors1 = colors(monkeyVec,:);
max1 = max([encActCN; encPasCN]);
max2 = max([encActS1; encPasS1]);

figure
scatter(encActCN, encPasCN, 16, colors1, 'filled')
hold on
plot([0, max1], [0, max1])

figure
scatter(encActS1, encPasS1)
hold on
plot([0, max2], [0, max2])

%%
max3 = max([encActCNNorm';encPasCNNorm'; encActS1Norm'; encPasS1Norm']);
figure
scatter(encActCNNorm, encPasCNNorm, 16, colors1, 'filled')
hold on
scatter(encActS1Norm, encPasS1Norm)
plot([0, max3], [0, max3])

fitlm(encActCNNorm, encPasCNNorm)
fitlm(encActS1Norm, encPasS1Norm)
%%
rockAct = encActNorm{12};
rockPas = encPasNorm{12};
max1 = max([rockAct;rockPas]);

figure
scatter(rockAct, rockPas)
hold on
plot([0, max1], [0, max1])