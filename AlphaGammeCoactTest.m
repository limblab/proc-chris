td1 = binTD(td, 5);
bumpTrials = td1(~isnan([td.bumpDir]));
td_act = td1(isnan([td.bumpDir]));
td_pas = trimTD(bumpTrials, {'idx_bumpTime', -2} ,{'idx_bumpTime', 2});
firing_act = cat(1, td_act.cuneate_spikes);
firing_pas = cat(1, td_pas.cuneate_spikes);
channelUnit = td_act.cuneate_unit_guide;
elec = channelUnit(:,1);
unitN = channelUnit(:,2);

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

covar = [jointVel_act, emg_act];
covar_pas = [jointVel_pas, emg_pas];
covar_names = [{td_act(1).opensim_names{1:14}}, td_act(1).emg_names];


%%
params.monkey = 'Lando';
params.date = '09172017';
params.task = 'CObump';

params.plotLambda = false;
params.plotPredicted = false;
params.covar_names = covar_names;
params.window_start = 'trial_start';
params.window_end = 'trial_end';
params.comments = 'Testing Effect of removing all handle kinematics on significant params, This is the active case';
params.numCV = 10;
modelFit = fitLassoModel(covar, firing_act, params);

modelFit.regularizer = 'L1';
modelFit.fit_metric = 'PseudoR2';

tempFit(1) = modelFit;

%%
params.monkey = 'Lando';
params.date = '09172017';
params.task = 'CObump';
params.plotLambda = false;
params.plotPredicted = false;
params.covar_names = covar_names;
params.window_start = 'bumpTime-100';
params.window_end = 'bumpTime+100';
params.comments = 'Testing Effect of removing all handle data. Only EMGs and joints. Passive case with window -100 to +100 around bump';
params.numCV = 10;
modelFit = fitLassoModel(covar_pas, firing_pas, params);
tempFit(2) = modelFit;

%%
