clear all
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')
td = getMoveOnsetAndPeak(td);
td = smoothSignals(td, struct('signals', 'cuneate_spikes'));

tdBump = td(~isnan([td.idx_bumpTime]));
tdMove = td(isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
tdMove = trimTD(tdMove, {'idx_movement_on', 0}, {'idx_movement_on', 13});
%%
params = struct('model_name' ,'test', 'in_signals', 'cuneate_spikes', 'out_signals', 'vel');
[cv1, cv2,~,~,errorMoveMove, errorMoveBump] = fitCVAndTestLinModel(tdMove, tdBump, params);
[cv3, cv4,~,~,errorBumpBump, errorBumpMove] = fitCVAndTestLinModel(tdBump, tdMove, params);

%%
params.model_type    =  'linmodel';
params.model_name    =  'movementGLM';
params.in_signals    =  {'cuneate_spikes'};% {'name',idx; 'name',idx};
params.out_signals   =  {'vel'};% {'name',idx};
params.train_idx     =  1:length(tdBump);
% GLM-specific parameters


params.glm_distribution     =  'normal';
params.model_name    =  'passiveModelVelPred';
[trial_glm_bump, model_info_bump] = getModel(tdBump, params);
params.model_name    =  'activeModelVelPred';
params.train_idx    = 1:length(tdMove);
[trial_glm_move, model_info_move] = getModel(tdMove, params);


%%
params.eval_metric      =  'r2';
params.model_name    =  'passiveModelVelPred';
r2_glm_bump = evalModel(trial_glm_bump, params);
params.model_name    =  'activeModelVelPred';
r2_glm_move = evalModel(trial_glm_move, params);

params.model_name = 'lm_passiveModelVelPred';
[tdMove, prediction_moveWBump] = predictFromTD(tdMove, model_info_bump, params);
params.model_name = 'lm_activeModelVelPred';
[tdMove, prediction_moveWBump] = predictFromTD(tdMove, model_info_move, params);


params.model_name = 'lm_activeModelVelPred';
[tdBump, prediction_bumpWMove] = predictFromTD(tdBump, model_info_move, params);
params.model_name = 'lm_passiveModelVelPred';
[tdBump, prediction_bumpWBump] = predictFromTD(tdBump, model_info_bump, params);

moveVel = cat(1, tdMove.vel);
movePredwActive = cat(1, tdMove.lm_activeModelVelPred);
movePredwPassive = cat(1, tdMove.lm_passiveModelVelPred);

bumpVel = cat(1, tdBump.vel);
bumpPredwActive = cat(1, tdBump.lm_activeModelVelPred);
bumpPredwPassive= cat(1, tdBump.lm_passiveModelVelPred);

%%
cvMove = getCVModelParams(tdMove, params);

%%
close all
for ax1 = 1:2

f1 = figure;

plot(.01:.01:.01*length(movePredwPassive(:,ax1)), moveVel(:,ax1))
hold on
plot(.01:.01:.01*length(movePredwPassive(:,ax1)), movePredwPassive(:,ax1))
plot(.01:.01:.01*length(movePredwPassive(:,ax1)), movePredwActive(:,ax1))
legend('Movement', 'Passive model', 'Active model')
title('Velocity during active movement, and predictions over time')
set(gca,'TickDir','out', 'box', 'off')
% xlim([50,60])
% pause

f2 = figure;
scatter(moveVel(:,ax1), movePredwActive(:,ax1),'r', 'filled')
hold on
fitlm(moveVel(:,ax1), movePredwActive(:,ax1))
scatter(moveVel(:,ax1), movePredwPassive(:,ax1),'b', 'filled')
plot([-100, 100], [-100, 100], 'k--')
legend('Active Model', 'Passive Model')
xlim([-100, 100])
ylim([-100, 100])
xlabel('X axis velocity(real, cm/s)')
ylabel('X axis velocity(predicted, cm/s)')
title('Predicted velocity during active movements')
set(gca,'TickDir','out', 'box', 'off')
% pause

f3 = figure;
axis1=subplot(2,1,1);
plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpVel(:,ax1))
hold on
plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwPassive(:,ax1))
plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwActive(:,ax1))
legend('Real Movement', 'Passive model', 'Active model')
title('Velocity during passive movement, and predictions over time')
set(gca,'TickDir','out', 'box', 'off')
xlim([50,60])
axis2= subplot(2,1,2);
plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpVel(:,2))
hold on
plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwPassive(:,2))
plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwActive(:,2))
legend('Real Movement', 'Passive model', 'Active model')
title('Velocity during passive movement, and predictions over time')
set(gca,'TickDir','out', 'box', 'off')
% xlim([50,60])
linkaxes([axis1, axis2]);
% pause

f4 = figure;
scatter(bumpVel(:,ax1), bumpPredwActive(:,ax1),'r', 'filled')
hold on
scatter(bumpVel(:,ax1), bumpPredwPassive(:,ax1),'b', 'filled')
plot([-100, 100], [-100, 100], 'k--')
legend('Active Model', 'Passive Model')
xlim([-100, 100])
ylim([-100, 100])
xlabel('X axis velocity(real, cm/s)')
ylabel('X axis velocity(predicted, cm/s)')
title('Predicted velocity during passive movements')
set(gca,'TickDir','out', 'box', 'off')
% pause

saveas(f1, ['ActVsPasDecoder20180607ActivePredictionPlotAxis',num2str(ax1),'.pdf'])
saveas(f2, ['ActVsPasDecoder20180607ActivePredictionScatterAxis',num2str(ax1),'.pdf'])
saveas(f3, ['ActVsPasDecoder20180607PassivePredictionPlotAxis', num2str(ax1), '.pdf'])
saveas(f4, ['ActVsPasDecoder20180607PassivePredictionScatterAxis', num2str(ax1), '.pdf'])
end

% close all
activeToBumpGainFitX = fitlm(bumpPredwActive(:,1), bumpVel(:,1))
activeToBumpGainFitY = fitlm(bumpPredwActive(:,2), bumpVel(:,2))

passiveToMoveGainFitX = fitlm(movePredwPassive(:,1), moveVel(:,1))
passiveToMoveGainFitY = fitlm(movePredwPassive(:,2), moveVel(:,2))


figure
scatter(bumpVel(:,1), bumpPredwActive(:,1).*activeToBumpGainFitX.Coefficients.Estimate(2),'r', 'filled')
hold on
scatter(bumpVel(:,1), bumpPredwPassive(:,1),'b', 'filled')
plot([-100, 100], [-100, 100], 'k--')

figure
scatter(bumpVel(:,2), bumpPredwActive(:,2).*activeToBumpGainFitY.Coefficients.Estimate(2),'r', 'filled')
hold on
scatter(bumpVel(:,2), bumpPredwPassive(:,2),'b', 'filled')
plot([-100, 100], [-100, 100], 'k--')

%%
% figure
% plot(.05:.05:.05*length(prediction_bumpWBump{22}), prediction_bumpWBump)
% hold on


%% This shows that active movement have larger gain than passive movements eg. passive movements are represented more strongly for the same movement