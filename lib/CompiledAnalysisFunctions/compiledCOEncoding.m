function results = compiledCOEncoding(td, params)
array= 'cuneate';
doCuneate= true;
if nargin > 1, assignParams(who,params); end % overwrite parameters
td = getNorm(td,struct('signals','vel','norm_name','speed'));
td = smoothSignals(td, struct('signals', [array, '_spikes']));

% tdButter= removeBadTrials(tdButter);
td = td(~isnan([td.idx_movement_on]));

td = trimTD(td, 'idx_movement_on', 'idx_endTime');
td= tdToBinSize(td,50);
% tdButter= removeBadTrials(tdButter);
td(isnan([td.idx_endTime])) =[];
td([td.idx_endTime] ==1) = [];
Naming = td.([array, '_unit_guide']);
sortedFlag = Naming(:,2) ~= 0;
params.doCuneate = doCuneate;
[td, cunFlag] = getTDCuneate(td);
% td = rectifyTDSignal(td, struct('signals_to_rectify', {{'acc'}}));
%% Compute the full models, and the pieces of the models
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 100;
params.eval_metric = 'pr2';
% params.glm_distribution

params.in_signals= {'pos';'vel';'speed';'acc';'force'};
params.model_name = 'Full';
params.out_signals = {spikes};
td= getModel(td, params);
fullPR2 = squeeze(evalModel(td, params));

params.in_signals= {'vel';'speed';'acc';'force'};
params.model_name = 'FullMinusPos';
params.out_signals = {spikes};
td= getModel(td, params);
fullPR2minusPos = squeeze(evalModel(td, params));

params.in_signals= {'pos';'speed';'acc';'force'};
params.model_name = 'FullMinusVel';
params.out_signals = {spikes};
td= getModel(td, params);
fullPR2minusVel = squeeze(evalModel(td, params));

params.in_signals= {'pos';'vel';'speed';'acc'};
params.model_name = 'FullMinusForce';
params.out_signals = {spikes};
td= getModel(td, params);
fullPR2minusForce = squeeze(evalModel(td, params));

params.in_signals= {'pos';'vel';'acc';'force'};
params.model_name = 'FullMinusSpeed';
params.out_signals = {spikes};
td= getModel(td, params);
fullPR2minusSpeed = squeeze(evalModel(td, params));

params.in_signals= {'pos'};
params.model_name = 'Pos';
td= getModel(td, params);
posPR2 = squeeze(evalModel(td, params));

params.in_signals= {'vel'};
params.model_name = 'Vel';
td= getModel(td, params);
velPR2 = squeeze(evalModel(td, params));

params.in_signals= {'force'};
params.model_name = 'Force';
td= getModel(td, params);
forcePR2 = squeeze(evalModel(td, params));

params.in_signals= {'speed'};
params.model_name = 'Speed';
td= getModel(td, params);
speedPR2 = squeeze(evalModel(td, params));

params.in_signals= {'speed', 'vel'};
params.model_name = 'VelSpeed';
td= getModel(td, params);
velSpeedPR2 = squeeze(evalModel(td, params));

params.in_signals ={'acc'};
params.model_name = 'Acc';
td= getModel(td,params);
accPR2 = squeeze(evalModel(td, params));

%%
Full = squeeze(fullPR2(sortedFlag & cunFlag))';
FullMinusPos = fullPR2minusPos(sortedFlag& cunFlag);
FullMinusVel = fullPR2minusVel(sortedFlag& cunFlag);
FullMinusForce = fullPR2minusForce(sortedFlag& cunFlag);
FullMinusSpeed = fullPR2minusSpeed(sortedFlag& cunFlag);
Vel = velPR2(sortedFlag& cunFlag)';
Pos = posPR2(sortedFlag& cunFlag)';
% Force = forcePR2(sortedFlag& cunFlag)';
Speed = speedPR2(sortedFlag& cunFlag)';
VelSpeed = velSpeedPR2(sortedFlag& cunFlag)';
Acc = accPR2(sortedFlag&cunFlag)';

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

end