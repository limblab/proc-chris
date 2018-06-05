close all
clear all
% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Butter\20180329\TD\Butter_CO_20180329_TD.mat')
% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Lando\20170917\TD\Lando_COactpas_20170917_TD_001.mat')
% load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CO\Lando\20170320\TD\Lando_COactpas_20170320_1_TD_sorted_ConservativeSort.mat')
% load('Lando_CO_20170903_TD.mat')

array = 'cuneate';

td = getMoveOnsetAndPeak(td);
bumpTrials = trimTD(td(~isnan([td.idx_bumpTime])), {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
moveTrials = trimTD(td(strcmp({td.result}, 'R')), {'idx_movement_on', 10}, {'idx_movement_on', 20});

speed = rownorm([squeeze(mean(cat(3,moveTrials.vel),1)).*100]');
fr = squeeze(mean(cat(3, moveTrials.([array, '_spikes'])), 1))*100;

leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
rightBump = bumpTrials([bumpTrials.bumpDir] == 0);
upBump = bumpTrials([bumpTrials.bumpDir] == 90);
downBump = bumpTrials([bumpTrials.bumpDir] == 270);

leftMove = moveTrials([moveTrials.target_direction] == pi);
rightMove = moveTrials([moveTrials.target_direction] == 0);
downMove = moveTrials([moveTrials.target_direction] == 3*pi/2);
upMove = moveTrials([moveTrials.target_direction] == pi/2);

leftBumpFR = squeeze(mean(cat(3,leftBump.([array, '_spikes'])), 1)).*100;
rightBumpFR =squeeze(mean(cat(3,rightBump.([array, '_spikes'])), 1)).*100;
downBumpFR = squeeze(mean(cat(3,downBump.([array, '_spikes'])), 1)).*100;
upBumpFR = squeeze(mean(cat(3,upBump.([array, '_spikes'])), 1)).*100;


leftMoveFR = squeeze(mean(cat(3,leftMove.([array, '_spikes'])), 1)).*100;
rightMoveFR =squeeze(mean(cat(3,rightMove.([array, '_spikes'])), 1)).*100;
downMoveFR = squeeze(mean(cat(3,downMove.([array, '_spikes'])), 1)).*100;
upMoveFR = squeeze(mean(cat(3,upMove.([array, '_spikes'])), 1)).*100;

leftMoveSpeed = squeeze(mean(cat(3,leftMove.vel), 1)).*100;
rightMoveSpeed =squeeze(mean(cat(3,rightMove.vel), 1)).*100;
downMoveSpeed = squeeze(mean(cat(3,downMove.vel), 1)).*100;
upMoveSpeed = squeeze(mean(cat(3,upMove.vel), 1)).*100;
cosFitVec1 = cos([0*ones(length(rightMoveFR(1,:)),1);(pi/2)*ones(length(upMoveFR(1,:)),1);pi*ones(length(leftMoveFR(1,:)),1);(3*pi/2)*ones(length(downMoveFR(1,:)),1)]);
cosFitVec2 = sin([0*ones(length(rightMoveFR(1,:)),1);(pi/2)*ones(length(upMoveFR(1,:)),1);pi*ones(length(leftMoveFR(1,:)),1);(3*pi/2)*ones(length(downMoveFR(1,:)),1)]);
cosFitMat = [cosFitVec1,cosFitVec2, [rightMoveFR(1,:)'; upMoveFR(1,:)'; leftMoveFR(1,:)'; downMoveFR(1,:)']];
mdlSpeed = fitlm(cosFitMat(:,1:2), rownorm([rightMoveSpeed'; upMoveSpeed'; leftMoveSpeed'; downMoveSpeed']));
pdMoveSpeed= rad2deg(atan2(mdlSpeed.Coefficients.Estimate(3), mdlSpeed.Coefficients.Estimate(2)));
figure
scatter(0*ones(length(rightMoveFR(1,:)),1) + .1*randn(length(rightMoveSpeed(1,:)),1), rownorm(rightMoveFR'), 'ro')
hold on
scatter((90)*ones(length(upMoveFR(1,:)),1)+ .1*randn(length(upMoveFR(1,:)),1), rownorm(upMoveFR'), 'ro')
scatter(180*ones(length(leftMoveFR(1,:)),1)+ .1*randn(length(leftMoveFR(1,:)),1), rownorm(leftMoveFR'), 'ro')
scatter((-90)*ones(length(downMoveFR(1,:)),1)+ .1*randn(length(downMoveFR(1,:)),1),rownorm(downMoveFR'), 'ro')
scatter(pdMoveSpeed, 50)

for i = 1:length(downBumpFR(:,1))
    clear cosFitMat
    cosFitMat = [cosFitVec1,cosFitVec2, [rightMoveFR(i,:)'; upMoveFR(i,:)'; leftMoveFR(i,:)'; downMoveFR(i,:)']];

    mdl = fitlm(cosFitMat(:,1:2), cosFitMat(:,3));
    mdlSpeed = fitlm(speed, fr(i,:));
    p(i) = coefTest(mdl);
    r2(i) = mdl.Rsquared.Adjusted;
    pSpeed(i) = coefTest(mdlSpeed);
    r2Speed(i) = mdlSpeed.Rsquared.Adjusted;
    
    
%     plot(mdl)
    pdMove(i) = rad2deg(atan2(mdl.Coefficients.Estimate(3), mdl.Coefficients.Estimate(2)));
    title(pdMove(i));
    
%     figure
%     scatter(0*ones(length(rightMoveFR(1,:)),1) + .1*randn(length(rightMoveFR(1,:)),1), rightMoveFR(i,:), 'ro')
%     hold on
%     scatter((pi/2)*ones(length(upMoveFR(1,:)),1)+ .1*randn(length(upMoveFR(1,:)),1), upMoveFR(i,:), 'ro')
%     scatter(pi*ones(length(leftMoveFR(1,:)),1)+ .1*randn(length(leftMoveFR(1,:)),1), leftMoveFR(i,:), 'ro')
%     scatter((3*pi/2)*ones(length(downMoveFR(1,:)),1)+ .1*randn(length(downMoveFR(1,:)),1), downMoveFR(i,:), 'ro')
%     scatter(deg2rad(pd)+2*pi, max([rightMoveFR(i,:)'; upMoveFR(i,:)'; leftMoveFR(i,:)'; downMoveFR(i,:)']))
%     figure
%     anova1([rightMoveFR(i,:)'; upMoveFR(i,:)'; leftMoveFR(i,:)'; downMoveFR(i,:)'],[1*ones(length(rightMoveFR(1,:)),1);2*ones(length(upMoveFR(1,:)),1);3*ones(length(leftMoveFR(1,:)),1);4*ones(length(downMoveFR(1,:)),1)])
%     pause
end
for i = 1:length(downBumpFR(:,1))
    clear cosFitMat
    cosFitVec1 = cos([0*ones(length(rightBumpFR(1,:)),1);(pi/2)*ones(length(upBumpFR(1,:)),1);pi*ones(length(leftBumpFR(1,:)),1);(3*pi/2)*ones(length(downBumpFR(1,:)),1)]);
    cosFitVec2 = sin([0*ones(length(rightBumpFR(1,:)),1);(pi/2)*ones(length(upBumpFR(1,:)),1);pi*ones(length(leftBumpFR(1,:)),1);(3*pi/2)*ones(length(downBumpFR(1,:)),1)]);
    cosFitMat = [cosFitVec1,cosFitVec2, [rightBumpFR(i,:)'; upBumpFR(i,:)'; leftBumpFR(i,:)'; downBumpFR(i,:)']];
    
    mdl = fitlm(cosFitMat(:,1:2), cosFitMat(:,3));
    pBump(i) = coefTest(mdl);
    
%     plot(mdl)
    pd = rad2deg(atan2(mdl.Coefficients.Estimate(3), mdl.Coefficients.Estimate(2)));
%     title(pd);
    
%     figure
%     scatter(0*ones(length(rightBumpFR(1,:)),1) + .1*randn(length(rightBumpFR(1,:)),1), rightBumpFR(i,:), 'ro')
%     hold on
%     scatter((pi/2)*ones(length(upBumpFR(1,:)),1)+ .1*randn(length(upBumpFR(1,:)),1), upBumpFR(i,:), 'ro')
%     scatter(pi*ones(length(leftBumpFR(1,:)),1)+ .1*randn(length(leftBumpFR(1,:)),1), leftBumpFR(i,:), 'ro')
%     scatter((3*pi/2)*ones(length(downBumpFR(1,:)),1)+ .1*randn(length(downBumpFR(1,:)),1), downBumpFR(i,:), 'ro')
%     scatter(deg2rad(pd)+2*pi, max([rightBumpFR(i,:)'; upBumpFR(i,:)'; leftBumpFR(i,:)'; downBumpFR(i,:)']))
%     figure
%     anova1([rightBumpFR(i,:)'; upBumpFR(i,:)'; leftBumpFR(i,:)'; downBumpFR(i,:)'],[1*ones(length(rightBumpFR(1,:)),1);2*ones(length(upBumpFR(1,:)),1);3*ones(length(leftBumpFR(1,:)),1);4*ones(length(downBumpFR(1,:)),1)])
%     pause
end

figure
histogram(pdMove(p<.05),7)
title(pdMoveSpeed)
sum(pBump<.05)/ length(p)
sum(p<.05)/length(p)

figure
histogram(r2(p<.05))
hold on
histogram(r2Speed(p<.05))

speedProportion = r2Speed(p<.05)./r2(p<.05);
figure
histogram(speedProportion,10)
title('Proportion of VAF by speed compared to velocity')
xlabel('R2 full model / R2 speed only model')
ylabel('# of tuned neurons')
