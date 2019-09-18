function [results,td,neurons] = compiledCOEncoding(td, params, neurons)
array= 'cuneate';
doCuneate= true;
if nargin > 1, assignParams(who,params); end % overwrite parameters
td = getNorm(td,struct('signals','vel','norm_name','speed'));
td = smoothSignals(td, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .03));

% tdButter= removeBadTrials(tdButter);
td = td(~isnan([td.idx_movement_on]));

td = trimTD(td, 'idx_movement_on', 'idx_endTime');
td= tdToBinSize(td,50);
% tdButter= removeBadTrials(tdButter);
% td(isnan([td.idx_endTime])) =[];
td([td.idx_endTime] ==1) = [];
Naming = td.([array, '_unit_guide']);
sortedFlag = Naming(:,2) ~= 0;
params.doCuneate = doCuneate;
% [td, cunFlag] = getTDCuneate(td);
cunFlag = ones(length(Naming(:,1)), 1);
% td = rectifyTDSignal(td, struct('signals_to_rectify', {{'acc'}}));
%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 100;
params.eval_metric = 'pr2';
% params.glm_distribution
disp('Full')
params.in_signals= {'pos';'vel';'speed';'acc';'force'};
params.model_name = 'Full';
params.out_signals = {spikes};
[td, modelFull]= getModel(td, params);
fullPR2 = squeeze(evalModel(td, params));
disp('Full-pos')
params.in_signals= {'vel';'speed';'acc';'force'};
params.model_name = 'FullMinusPos';
params.out_signals = {spikes};
[td, modelFullMinusPos]= getModel(td, params);
fullPR2minusPos = squeeze(evalModel(td, params));

disp('Full-Vel')
params.in_signals= {'pos';'speed';'acc';'force'};
params.model_name = 'FullMinusVel';
params.out_signals = {spikes};
[td, modelFullMinusVel]= getModel(td, params);
fullPR2minusVel = squeeze(evalModel(td, params));
disp('Full - force')
params.in_signals= {'pos';'vel';'speed';'acc'};
params.model_name = 'FullMinusForce';
params.out_signals = {spikes};
[td, modelFullMinusForce]= getModel(td, params);
fullPR2minusForce = squeeze(evalModel(td, params));

disp('Full-speed')
params.in_signals= {'pos';'vel';'acc';'force'};
params.model_name = 'FullMinusSpeed';
params.out_signals = {spikes};
[td, modelFullMinusSpeed]= getModel(td, params);
fullPR2minusSpeed = squeeze(evalModel(td, params));

disp('Pos')
params.in_signals= {'pos'};
params.model_name = 'Pos';
[td, modelPos]= getModel(td, params);
posPR2 = squeeze(evalModel(td, params));

disp('Vel')
params.in_signals= {'vel'};
params.model_name = 'Vel';
[td, modelVel]= getModel(td, params);
velPR2 = squeeze(evalModel(td, params));

disp('Force')
params.in_signals= {'force'};
params.model_name = 'Force';
[td, modelForce]= getModel(td, params);
forcePR2 = squeeze(evalModel(td, params));

disp('Speed')
params.in_signals= {'speed'};
params.model_name = 'Speed';
[td, modelSpeed]= getModel(td, params);
speedPR2 = squeeze(evalModel(td, params));

disp('SpeedVel')
params.in_signals= {'speed', 'vel'};
params.model_name = 'VelSpeed';
[td, modelVelSpeed]= getModel(td, params);
velSpeedPR2 = squeeze(evalModel(td, params));

disp('Acc')
params.in_signals ={'acc'};
params.model_name = 'Acc';
[td, modelAcc]= getModel(td,params);
accPR2 = squeeze(evalModel(td, params));

%%
Full = squeeze(fullPR2);
FullMinusPos = fullPR2minusPos;
FullMinusVel = fullPR2minusVel;
FullMinusForce = fullPR2minusForce;
FullMinusSpeed = fullPR2minusSpeed;
Vel = velPR2;
Pos = posPR2;
% Force = forcePR2(sortedFlag& cunFlag);
Speed = speedPR2;
VelSpeed = velSpeedPR2;
Acc = accPR2;

results.FullEnc = Full;
results.FullNoPosEnc = FullMinusPos;
results.FullNoVelEnc = FullMinusVel;
results.FullNoForceEnc = FullMinusForce;
results.FullNoSpeedEnc = FullMinusSpeed;
results.VelEnc = Vel;
results.PosEnc = Pos;
results.SpeedEnc = Speed;
results.VelSpeedEnc = VelSpeed;
results.AccEnc = Acc;

tab = struct2table(results);
results.modelFull = modelFull;
results.modelFullMinusPos =modelFullMinusPos;
results.modelFullMinusVel = modelFullMinusVel;
results.modelFullMinusForce =modelFullMinusForce;
results.modelFullMinusSpeed =modelFullMinusSpeed;
results.modelPos =modelPos;
results.modelVel =modelVel;
results.modelForce=modelForce;
results.modelVelSpeed =modelVelSpeed;
results.modelAcc =modelAcc;

if nargin >2 
    neurons.encoding = tab;
end
end