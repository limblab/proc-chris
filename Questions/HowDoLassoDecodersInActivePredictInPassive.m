clear all
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')

in_signals = {'cuneate_spikes', find(td(1).cuneate_unit_guide(:,2)>0)};

td = getMoveOnsetAndPeak(td);
td = smoothSignals(td, struct('signals', 'cuneate_spikes'));

tdBump = td(~isnan([td.idx_bumpTime]));
tdMove = td(isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
tdMove = trimTD(tdMove, {'idx_movement_on', 0}, {'idx_movement_on', 13});
%%

bumpFiring =  get_vars(tdBump,in_signals);
moveFiring =  get_vars(tdMove,in_signals);

bumpVel = get_vars(tdBump, {'vel',1:2});
moveVel = get_vars(tdMove, {'vel',1:2});

[bBumpX, infoBumpX] = lasso(bumpFiring, bumpVel(:,1), 'CV', 10);
[bMoveX, infoMoveX] = lasso(moveFiring, moveVel(:,1), 'CV', 10);

[bBumpY, infoBumpY] = lasso(bumpFiring, bumpVel(:,2), 'CV', 10);
[bMoveY, infoMoveY] = lasso(moveFiring, moveVel(:,2), 'CV', 10);
%%
bump2MoveXpred = bBumpX(:, infoBumpX.IndexMinMSE)'*moveFiring';
bump2MoveYpred = bBumpY(:, infoBumpY.IndexMinMSE)'*moveFiring';
move2BumpXpred = bMoveX(:, infoMoveX.IndexMinMSE)'*bumpFiring';
move2BumpYpred = bMoveY(:, infoMoveY.IndexMinMSE)'*bumpFiring';