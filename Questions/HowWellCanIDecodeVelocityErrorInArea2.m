clearvars -except td
close all
monkey = 'Duncan';
date = '20190710';
num1 = 1;
array = 'leftS1';
smoothWidth = 0.03;
decodeWindow = 20;
plotBestMatch = true;
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


lmPosErrX = fitlm(firingCat, errPosCat(:,1));
lmVelErrX = fitlm(firingCat, errVelCat(:,1));
lmForceErrX = fitlm(firingCat, errForceCat(:,1));

lmPosErrY = fitlm(firingCat, errPosCat(:,2));
lmVelErrY = fitlm(firingCat, errVelCat(:,2));
lmForceErrY = fitlm(firingCat, errForceCat(:,2));

lmPosTrueX = fitlm(firingCat, truePosCat(:,1));
lmVelTrueX = fitlm(firingCat, trueVelCat(:,1));
lmForceTrueX = fitlm(firingCat, trueForceCat(:,1));

lmPosTrueY = fitlm(firingCat, truePosCat(:,2));
lmVelTrueY = fitlm(firingCat, trueVelCat(:,2));
lmForceTrueY = fitlm(firingCat, trueForceCat(:,2));


lmPosTrueGivenErrX = fitlm(errPosCat, truePosCat(:,1));
lmPosTrueGivenErrY = fitlm(errPosCat, truePosCat(:,2));

lmVelTrueGivenErrX = fitlm(errVelCat, trueVelCat(:,1));
lmVelTrueGivenErrY = fitlm(errVelCat, trueVelCat(:,2));

lmPosErrGivenVelTrueX = fitlm(trueVelCat, errPosCat(:,1));
lmPosErrGivenVelTrueY = fitlm(trueVelCat, errPosCat(:,2));


tab = table(lmPosErrX.Rsquared.Ordinary,lmPosErrY.Rsquared.Ordinary,lmVelErrX.Rsquared.Ordinary,lmVelErrY.Rsquared.Ordinary,...
    lmForceErrX.Rsquared.Ordinary, lmForceErrY.Rsquared.Ordinary,...
    lmPosTrueX.Rsquared.Ordinary,lmPosTrueY.Rsquared.Ordinary,lmVelTrueX.Rsquared.Ordinary,lmVelTrueY.Rsquared.Ordinary,...
    lmForceTrueX.Rsquared.Ordinary, lmForceTrueY.Rsquared.Ordinary,...
    lmPosTrueGivenErrX.Rsquared.Ordinary, lmPosTrueGivenErrY.Rsquared.Ordinary,...
    lmVelTrueGivenErrX.Rsquared.Ordinary, lmVelTrueGivenErrY.Rsquared.Ordinary,...
    lmPosErrGivenVelTrueX.Rsquared.Ordinary, lmPosErrGivenVelTrueY.Rsquared.Ordinary,...
    'VariableNames',{'PosErrX', 'PosErrY', 'VelErrX', 'VelErrY','ForceErrX', 'ForceErrY', ...
    'PosTrueX', 'PosTrueY', 'VelTrueX', 'VelTrueY','ForceTrueX', 'ForceTrueY', ...
    'PosTrueGivenErrX', 'PosTrueGivenErrY', 'VelTrueGivenErrX', 'VelTrueGivenErrY'...
    'PosErrorGivenTrueVelX', 'PosErroGivenTrueVelY'});
