clear all
close all
crackleDate = '20190418';
windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
array = 'cuneate';
i = 3;

[td, date] = getPaperFiles(i, 10);
neurons = getNeurons('Crackle', crackleDate, 'CObump','cuneate',[windowAct; windowPas]);

params = struct('flags', {{'~isCuneate', 'distal'}});
td = removeNeuronsByNeuronStruct(td, params);
td = smoothSignals(td, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .03));
td = getSpeed(td);
td = getMoveOnsetAndPeak(td);

guide = td(1).cuneate_unit_guide;
tdMove = trimTD(td, 'idx_movement_on', {'idx_movement_on', 13});
tdBump = td(~isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, 'idx_bumpTime', {'idx_bumpTime',13});

moveVel = cat(1,tdMove.vel);
bumpVel = cat(1,tdBump.vel);

moveFiring = cat(1, tdMove.cuneate_spikes);
bumpFiring = cat(1, tdBump.cuneate_spikes);
%%
lmMoveX = fitlm(moveFiring, moveVel(:,1))
lmMoveY = fitlm(moveFiring, moveVel(:,2))

vecMoveX = lmMoveX.Coefficients.Estimate(2:end);
vecMoveY = lmMoveY.Coefficients.Estimate(2:end);

nMoveX = norm(vecMoveX);
nMoveY = norm(vecMoveY);

lmBumpX = fitlm(bumpFiring, bumpVel(:,1))
lmBumpY = fitlm(bumpFiring, bumpVel(:,2))

vecBumpX = lmBumpX.Coefficients.Estimate(2:end);
vecBumpY = lmBumpY.Coefficients.Estimate(2:end); 

nBumpX = norm(vecBumpX);
nBumpY = norm(vecBumpY);
%%
figure
plot(lmMoveX)
hold on
plot(lmBumpX)
xlabel('Firing of CN neurons')
ylabel('Hand Speed (x vel)')

figure
plot(lmMoveY)
hold on
plot(lmBumpY)
xlabel('Firing of CN neurons')
ylabel('Hand Speed (y vel)')

%%
predBumpFromMoveX = predict(lmMoveX, bumpFiring);
predBumpFromMoveY = predict(lmMoveY, bumpFiring);

predMoveFromBumpX = predict(lmBumpX, moveFiring);
predMoveFromBumpY = predict(lmBumpY, moveFiring);

max1 = max(abs([bumpVel(:,1); predBumpFromMoveX]));
figure
scatter(bumpVel(:,1), predBumpFromMoveX)
hold on
plot([-max1, max1],[-max1, max1])
xlabel('Actual x Velocity (bump)')
ylabel('Predicted X velocity using move model')
title('If potentiated during reaching, the predicted firing should be lower') 

max1 = max(abs([bumpVel(:,2); predBumpFromMoveY]));
figure
scatter(bumpVel(:,2), predBumpFromMoveY)
hold on
plot([-max1, max1],[-max1, max1])
xlabel('Actual x Velocity (bump)')
ylabel('Predicted X velocity using move model')
title('If potentiated during reaching, the predicted firing should be lower') 

bumpSpeed = rownorm(bumpVel);
speedBumpFromMove = rownorm([predBumpFromMoveX, predBumpFromMoveY]);

max1 = max([bumpSpeed; speedBumpFromMove]);
figure
scatter(bumpSpeed, speedBumpFromMove)
hold on
plot([0, max1],[0, max1])
xlabel('Actual x Velocity (bump)')
ylabel('Predicted X velocity using move model')
title('If potentiated during reaching, the predicted firing should be lower') 