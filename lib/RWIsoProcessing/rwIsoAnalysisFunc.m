function rwIsoAnalysisFunc(monkey, date)
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'RWIso');

params.go_cue_name ='idx_goCueTime';
params.end_name = 'idx_endTime';
params.do_onset = false;

td1 = getRWMovements(td, params);
td1 = removeBadTrials(td1);

params.useForce = true;
params.which_field = 'force';
params.min_ds        =  .01;
params.s_thresh      =  1;
td1 = getMoveOnsetAndPeak(td1, params);
td1 = removeBadTrials(td1);
param.windowAct = {'idx_movement_on', 0; 'idx_endTime', 0};

td_act = trimTD(td1, {'idx_movement_on', 0}, {'idx_endTime', 0});
param.in_signals      = 'force';
%%
param.doTrim = false;
[trialProcessed, neuronNew] = compiledRWAnalysis(td_act,param);
param.array = 'RightCuneate';
param.sinTuned= neuronNew.isTuned;
%%
neuronsRW = [neuronNew];
neuronsRW = insertMappingsIntoNeuronStruct(neuronsRW,mappingLog);

saveNeurons(neuronsRW)

end