clearvars -except td
close all
monkey = 'Duncan';
date = '20190710';
num1 = 1;
array = 'leftS1';
smoothWidth = 0.03;
decodeWindow = 20;
plotBestMatch = false;
if ~exist('td')
    td = getTD(monkey,date,'CObumpmove', num1);
    td = tdToBinSize(td,10);
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td);
    td = getMoveBumps(td);
    td(isnan([td.idx_movement_on])) = [];
    td = smoothSignals(td, struct('signals', [array,'_spikes'], 'calc_rate',true, 'width', smoothWidth));    

end
dirsM = unique([td.target_direction]);
dirsM(isnan(dirsM)) =[];

dirsB = unique([td.bumpDir]);
dirsB(isnan(dirsB)) =[];


tdNoMBump = td(~[td.movementBump]);
tdMBump = td([td.movementBump]);
tdMBump = trimTD(tdMBump, 'idx_movement_on', 'idx_endTime');
tdMBump([tdMBump.idx_bumpTime]+20 > [tdMBump.idx_endTime])= [];
errPos = zeros(decodeWindow+1,2, length(tdMBump));
truePos= zeros(decodeWindow+1,2, length(tdMBump));

errVel = zeros(decodeWindow+1,2, length(tdMBump));
trueVel = zeros(decodeWindow+1,2, length(tdMBump));


errForce = zeros(decodeWindow+1,2, length(tdMBump));
trueForce = zeros(decodeWindow+1,2, length(tdMBump));

guide = td(1).leftS1_unit_guide;
firingPost = zeros(decodeWindow + 1, length(guide(:,1)), length(tdMBump));  
for i = 1:length(tdMBump)
    trial = tdMBump(i);
    dir = trial.target_direction;
    bumpTime = trial.idx_bumpTime;
    bTimes(i) = bumpTime;
    tdTemp = tdNoMBump([tdNoMBump.target_direction] == dir);
    tdTemp = trimTD(tdTemp, 'idx_movement_on', {'idx_movement_on', bumpTime+decodeWindow});
    
    bumpPos = trial.pos;
    bumpVel = trial.vel;
    bumpForce = trial.force;
    
    firing = trial.leftS1_spikes;
    
    preBumpPos = bumpPos(1:bumpTime,:);
    preBumpVel = bumpVel(1:bumpTime,:);
    preBumpForce = bumpForce(1:bumpTime,:);
    
    postBumpPos = bumpPos(bumpTime:bumpTime + decodeWindow,:);
    postBumpVel = bumpVel(bumpTime:bumpTime + decodeWindow,:);
    postBumpForce = bumpForce(bumpTime:bumpTime + decodeWindow,:);

    firingPost(:,:,i) = firing(bumpTime:bumpTime + decodeWindow,:);
    
    noBumpPos = cat(3, tdTemp.pos);
    noBumpVel = cat(3, tdTemp.vel);
    noBumpForce = cat(3, tdTemp.force);
    
    noBumpPrePos = noBumpPos(1:end-decodeWindow-1,:,:);
    noBumpPreVel = noBumpVel(1:end-decodeWindow-1,:,:);
    noBumpPreForce = noBumpForce(1:end-decodeWindow-1,:,:);
    
    noBumpPostPos = noBumpPos(end-decodeWindow:end, :,:);
    noBumpPostVel = noBumpVel(end-decodeWindow:end, :,:);
    noBumpPostForce = noBumpForce(end-decodeWindow:end,:,:);
    
    posDif = zeros(length(noBumpPostPos(1,1,:)),1);   
    for j = 1:length(noBumpPostPos(1,1,:))
        difVec = noBumpPrePos(:,:,j) - preBumpPos;
        posDif(j) = norm(difVec(:));
    end
    [~, bestMatch] = min(posDif);
    grey = [.5,.5,.5];
    blue = [.678,.847, .902];
    if plotBestMatch
        figure
        scatter(preBumpPos(:,1), preBumpPos(:,2),36, grey.*.5, 'filled')
        hold on
        scatter(noBumpPrePos(:,1,bestMatch), noBumpPrePos(:,2, bestMatch), 36, blue*.5,'filled')
        
        scatter(postBumpPos(:,1), postBumpPos(:,2),36, grey, 'filled')
        scatter(noBumpPostPos(:,1,bestMatch), noBumpPostPos(:,2, bestMatch),36, blue, 'filled')
        xlim([-20, 20])
        ylim([-45, -15])
        str1 = getBumpDirStr(trial);
        title(['bump direction ',str1])
    end
    errPos(:,:,i) = noBumpPostPos(:, :, bestMatch) - postBumpPos;
    errVel(:,:,i) = noBumpPostVel(:, :, bestMatch) - postBumpVel;
    errForce(:,:,i) = noBumpPostForce(:,:,bestMatch)- postBumpForce;
    
    truePos(:,:,i) = postBumpPos;
    trueVel(:,:,i) = postBumpVel;
    trueForce(:,:,i) = postBumpForce;
    
end
%%
splitA = num2cell(errPos, [1 2]); %split A keeping dimension 1 and 2 intact
errPosCat = vertcat(splitA{:});

splitA = num2cell(errVel, [1 2]); %split A keeping dimension 1 and 2 intact
errVelCat = vertcat(splitA{:});

splitA = num2cell(firingPost, [1 2]); %split A keeping dimension 1 and 2 intact
firingCat = vertcat(splitA{:});

splitA = num2cell(truePos, [1 2]); %split A keeping dimension 1 and 2 intact
truePosCat = vertcat(splitA{:});

splitA = num2cell(trueVel, [1 2]); %split A keeping dimension 1 and 2 intact
trueVelCat = vertcat(splitA{:});

splitA = num2cell(trueForce, [1 2]); %split A keeping dimension 1 and 2 intact
trueForceCat = vertcat(splitA{:});

splitA = num2cell(errForce, [1 2]); %split A keeping dimension 1 and 2 intact
errForceCat = vertcat(splitA{:});
nBoots = 100;
bootMatError = randi(length(errPosCat(:,1)),nBoots,length(errPosCat(:,1)));
bootMatTrue = randi(length(errPosCat(:,1)), nBoots, length(errPosCat(:,1)));
bootMatAll = randi(length(errPosCat(:,1)), nBoots, length(errPosCat(:,1)));

for boot = 1:100
    disp(['Beginning boot ', num2str(boot)])
    errPosBoot = errPosCat(bootMatError(boot,:),:);
    errVelBoot = errVelCat(bootMatError(boot,:),:);
    errForceBoot = errForceCat(bootMatError(boot,:),:);
    truePosBoot = truePosCat(bootMatTrue(boot,:),:);
    trueVelBoot = trueVelCat(bootMatTrue(boot,:),:);
    trueForceBoot = trueForceCat(bootMatTrue(boot,:),:);
    
    firingBootErr = firingCat(bootMatError(boot,:),:);
    firingBootTrue = firingCat(bootMatTrue(boot,:),:);
    
    
    errPosBootAll = errPosCat(bootMatAll(boot,:),:);
    errVelBootAll = errVelCat(bootMatAll(boot,:),:);
    errForceBootAll = errForceCat(bootMatAll(boot,:),:);
    truePosBootAll = truePosCat(bootMatAll(boot,:),:);
    trueVelBootAll = trueVelCat(bootMatAll(boot,:),:);
    trueForceBootAll = trueForceCat(bootMatAll(boot,:),:);
    
    firingBootAll = firingCat(bootMatAll(boot,:),:);
    for i = 1:length(guide(:,1))
        lmError{i} = fitlm([errPosBoot, errVelBoot, errForceBoot], firingBootErr(:,i));
        lmTrue{i} = fitlm([truePosBoot, trueVelBoot, trueForceBoot], firingBootTrue(:,i));
        lmAll{i} = fitlm([errPosBootAll, errVelBootAll, errForceBootAll,truePosBootAll, trueVelBootAll, trueForceBootAll], firingBootAll(:,i));

        r2Err(i, boot) = lmError{i}.Rsquared.Ordinary;
        r2True(i, boot) = lmTrue{i}.Rsquared.Ordinary;
        r2All(i, boot) = lmAll{i}.Rsquared.Ordinary;
        r2Dif(i,boot) = r2All(i,boot) - r2True(i,boot);
    end
end
%%
tab = table(r2Err, r2True, r2All, 'VariableNames', {'R2Error', 'R2True', 'R2All'});

difSig = quantile(r2Dif',[0.025, 0.975])';
flag = difSig(:,1)>0;
sum(flag)
figure
scatter(mean(r2True'), mean(r2All'))
hold on 
plot([0, 1], [0,1])

