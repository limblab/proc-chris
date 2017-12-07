td1 = binTD(td, 5);
% td_act = trimTD(td1, 'idx_movement_on', 'idx_endTime');
bumpTrials = td1(~isnan([td.bumpDir]));
td_act = td1(isnan([td.bumpDir]));
td_pas = trimTD(bumpTrials, {'idx_bumpTime', -2} ,{'idx_bumpTime', 2});
firing_act = cat(1, td_act.cuneate_spikes);
firing_pas = cat(1, td_pas.cuneate_spikes);

emg_act = cat(1, td_act.emg);
pos_act = cat(1, td_act.pos);
vel_act = cat(1, td_act.vel);
acc_act = cat(1,td_act.acc);
force_act = cat(1,td_act.force);
opensim_act = cat(1,td_act.opensim);
jointVel_act= opensim_act(:,1:14);

emg_pas = cat(1,td_pas.emg);
pos_pas = cat(1, td_pas.pos);
vel_pas = cat(1, td_pas.vel);
acc_pas = cat(1,td_pas.acc);
force_pas = cat(1,td_pas.force);
opensim_pas = cat(1,td_pas.opensim);
jointVel_pas= opensim_pas(:,1:14);

speed_act = rownorm(vel_act);
speed_pas = rownorm(vel_pas);

covar = [speed_act', pos_act, vel_act, acc_act, force_act, jointVel_act, emg_act];
covar_pas = [speed_pas', pos_pas, vel_pas, acc_pas, force_pas, jointVel_pas, emg_pas];
covar_names = [{'Speed', 'Pos x', 'Pos y', 'Vel x', 'Vel y', 'Acc x', 'Acc y', 'Force x', 'Force y'}, {td_act(1).opensim_names{1:14}}, td_act(1).emg_names];
close all
for i = 1:length(firing_act(1,:))

    [b_act{i}, glm_act{i}] = lassoglm(covar, firing_act(:,i), 'poisson', 'CV', 4)
    
    [b_pas{i}, glm_pas{i} ]= lassoglm(covar_pas, firing_pas(:,i), 'poisson', 'CV', 10)
end

%%
close all
for i=1:length(firing_act(1,:))
    bestDeviance_act(i) =glm_act{i}.Deviance(glm_act{i}.IndexMinDeviance);
    nullDeviance_act(i) =glm_act{i}.Deviance(end);
    pR2_act(i) = 1- bestDeviance_act(i)/nullDeviance_act(i);
    bestDeviance_pas(i) =glm_pas{i}.Deviance(glm_pas{i}.IndexMinDeviance);
    nullDeviance_pas(i) =glm_pas{i}.Deviance(end);
    pR2_pas(i) = 1- bestDeviance_pas(i)/nullDeviance_pas(i);
    lassoPlot(b_act{i}, glm_act{i}, 'PlotType', 'CV')
    lassoPlot(b_pas{i}, glm_pas{i}, 'PlotType', 'CV')
end
%%
for i = 1:length(firing_act(1,:))
    [b_act_best{i}, glm_act_best{i} ] = lassoglm(covar, firing_act(:,i), 'poisson', 'Lambda', glm_act{i}.LambdaMinDeviance, 'PredictorNames', covar_names);
    act_Factors{i} = glm_act_best{i}.PredictorNames(b_act_best{i}~=0);
    
    [b_pas_best{i}, glm_pas_best{i} ] = lassoglm(covar_pas, firing_pas(:,i), 'poisson', 'Lambda', glm_pas{i}.LambdaMinDeviance, 'PredictorNames', covar_names);
    pas_Factors{i} = glm_pas_best{i}.PredictorNames(b_pas_best{i}~=0);
    
    [b_act_Minimal{i}, glm_act_Minimal{i}] = lassoglm(covar, firing_act(:,i), 'poisson', 'Lambda', glm_act{i}.Lambda1SE, 'PredictorNames', covar_names);
    act_Factors_Minimal{i} = glm_act_Minimal{i}.PredictorNames(b_act_Minimal{i}~=0);
    
    [b_pas_Minimal{i}, glm_pas_Minimal{i} ] = lassoglm(covar_pas, firing_pas(:,i), 'poisson', 'Lambda', glm_pas{i}.Lambda1SE, 'PredictorNames', covar_names);
    pas_Factors_Minimal{i} = glm_pas_Minimal{i}.PredictorNames(b_pas_Minimal{i}~=0);
end
%%
close all
for i = 1:length(firing_act(1,:))
    fit1{i} = glmval(b_act_best{i}, covar, 'log', 'constant', 'off');
    figure

    yyaxis right
    plot(smooth(firing_act(:,i)))
    yyaxis left
    plot(fit1{i})
end

%%
% save('Lando_LassoGLM_20170917_001_SpeedPosVelAccForceJointVelEMG_WindowV2', 'b_act', 'glm_act', 'b_pas', 'glm_pas', 'covar_names')
