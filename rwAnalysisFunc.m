
function rwAnalysisFunc(monkey, date)

mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'RW_hold');

getSensoryMappings(monkey);

td1 = removeBadTrials(td);
param.windowAct = {'idx_movement_on'; 'idx_endTime'};
td_act = trimTD(td1, 'idx_movement_on', 'idx_endTime');
td_pas = trimTD(td1, 'idx_startTime', 'idx_movement_on');
param.in_signals      = 'vel';

[trialProcessed, neuronNew] = compiledRWAnalysis(td_act, param);
param.array = 'cuneate';
param.sinTuned= neuronNew.isTuned;
param.in_signals      = 'vel';

%%
neuronsRW = [neuronNew];
neuronsRW = insertMappingsIntoNeuronStruct(neuronsRW,mappingLog);

saveNeurons(neuronsRW)
end