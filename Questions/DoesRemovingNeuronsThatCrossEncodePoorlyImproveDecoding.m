DoEncodingModelsGeneralizeAcrossActPas;

%% Do decoding models, when trained with only the 'generalized' neurons decode well?
temp = -600*ones(length(sortedFlag),2);
temp(cunFlag,1) = velMove2BumpPR2;
temp(cunFlag,2) = velBump2MovePR2;

[sortedRelPR2, sortTemp] = sort(temp(:,2));

names = [tdButter(1).cuneate_unit_guide(sortTemp,:), sortedRelPR2];
for i = 1:length(sortTemp)
    unitsToUse = sortTemp(i:end);
    params.model_type    =  'linmodel';
    params.model_name    =  'movementGLM';
    params.in_signals    =  {'cuneate_spikes', unitsToUse};% {'name',idx; 'name',idx};
    params.out_signals   =  {'vel'};% {'name',idx};
    params.train_idx     =  1:length(tdBump);
    % GLM-specific parameters

    params.glm_distribution     =  'normal';
    
    
    params.model_name    =  'passiveModelVelPred';
    [trial_glm_bump, model_info_bump] = getModel(tdBump, params);
    [trial_glm_moveWBump] = getModel(tdMove, model_info_bump);
    params.model_name    =  'activeModelVelPred';
    params.train_idx    = 1:length(tdMove);
    [trial_glm_move, model_info_move] = getModel(tdMove, params);
    [trial_glm_bumpWMove] = getModel(tdBump, model_info_move);

    params.eval_metric      =  'r2';
    params.model_name    =  'passiveModelVelPred';
    r2_glm_bump(i,:) = evalModel(trial_glm_bump, params);
    r2_glm_moveWBump(i,:) = evalModel(trial_glm_moveWBump, params);
    params.model_name    =  'activeModelVelPred';
    r2_glm_move(i,:) = evalModel(trial_glm_move, params);
    r2_glm_bumpWMove(i,:) = evalModel(trial_glm_bumpWMove, params);

%     params.model_name = 'lm_passiveModelVelPred';
%     [tdMove, prediction_moveWBump] = predictFromTD(tdMove, model_info_bump, params);
%     params.model_name = 'lm_activeModelVelPred';
%     [tdMove, prediction_moveWBump] = predictFromTD(tdMove, model_info_move, params);


    bumpPredwActive = cat(1, trial_glm_bumpWMove.linmodel_activeModelVelPred);
    movePredwPassive = cat(1, trial_glm_moveWBump.linmodel_passiveModelVelPred);
    
    bumpPredwPassive = cat(1, trial_glm_bump.linmodel_passiveModelVelPred);
    movePredwActive = cat(1, trial_glm_move.linmodel_activeModelVelPred);
    
    moveVel = cat(1, tdMove.vel);
    bumpVel = cat(1, tdBump.vel);
     
    close all
    for ax1 = 1:2

%     f1 = figure;
% 
%     plot(.01:.01:.01*length(movePredwPassive(:,ax1)), moveVel(:,ax1))
%     hold on
%     plot(.01:.01:.01*length(movePredwPassive(:,ax1)), movePredwPassive(:,ax1))
%     plot(.01:.01:.01*length(movePredwPassive(:,ax1)), movePredwActive(:,ax1))
%     legend('Movement', 'Passive model', 'Active model')
%     title('Velocity during active movement, and predictions over time')
%     set(gca,'TickDir','out', 'box', 'off')
%     % xlim([50,60])
    % pause

    f2 = figure;
    scatter(moveVel(:,ax1), movePredwActive(:,ax1),'r', 'filled')
    hold on
    fitlm(moveVel(:,ax1), movePredwActive(:,ax1));
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

%     f3 = figure;
%     axis1=subplot(2,1,1);
%     plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpVel(:,ax1))
%     hold on
%     plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwPassive(:,ax1))
%     plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwActive(:,ax1))
%     legend('Real Movement', 'Passive model', 'Active model')
%     title('Velocity during passive movement, and predictions over time')
%     set(gca,'TickDir','out', 'box', 'off')
%     xlim([50,60])
%     axis2= subplot(2,1,2);
%     plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpVel(:,2))
%     hold on
%     plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwPassive(:,2))
%     plot(.01:.01:.01*length(bumpPredwPassive(:,ax1)), bumpPredwActive(:,2))
%     legend('Real Movement', 'Passive model', 'Active model')
%     title('Velocity during passive movement, and predictions over time')
%     set(gca,'TickDir','out', 'box', 'off')
%     % xlim([50,60])
%     linkaxes([axis1, axis2]);
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
    
    % saveas(f1, ['ActVsPasDecoder20180607ActivePredictionPlotAxis',num2str(ax1),'.pdf'])
    % saveas(f2, ['ActVsPasDecoder20180607ActivePredictionScatterAxis',num2str(ax1),'.pdf'])
    % saveas(f3, ['ActVsPasDecoder20180607PassivePredictionPlotAxis', num2str(ax1), '.pdf'])
    % saveas(f4, ['ActVsPasDecoder20180607PassivePredictionScatterAxis', num2str(ax1), '.pdf'])
    end
%     pause
end
%%
figure
plot(r2_glm_bump(:,1))
hold on
plot(r2_glm_bumpWMove(:,1))
plot(r2_glm_move(:,1))
plot(r2_glm_moveWBump(:,1))
legend('Bump to Bump', 'Move to Bump', 'Move to Move', ' Bump to Move')
title('Effect of dropping low generalizing units from Decoding')
xlabel('# of neurons dropped')
ylabel('R2 of velocity prediction')
set(gca,'TickDir','out', 'box', 'off')
