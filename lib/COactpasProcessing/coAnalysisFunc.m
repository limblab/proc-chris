function coAnalysisFunc(monkey, date)

    mappingLog = getSensoryMappings(monkey);
    td = getTD(monkey, date, 'COactpas');
    
    windowAct= {'idx_movement_on', 0; 'idx_endTime',0}; %Default trimming windows active
    windowPas ={'idx_bumpTime',0; 'idx_bumpTime',2}; % Default trimming windows passive
    param.arrays = {'RightCuneate'};
    param.in_signals = {'vel'};

    param.windowAct= windowAct;
    param.windowPas =windowPas;
    param.date = td(1).date;
    [processedTrialNew, neuronsNew] = compiledCOActPasAnalysis(td, param);
    neuronsCO = [neuronsNew];
    neuronsCO = insertMappingsIntoNeuronStruct(neuronsCO,mappingLog);

    saveNeurons(neuronsCO)
end