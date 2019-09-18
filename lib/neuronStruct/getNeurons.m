function neurons = getNeurons(monkey, date, task, array)
    path = [getBasicPath(monkey, date, getGenericTask(task)),filesep, 'neuronStruct', filesep, monkey,'_',date, '_', task, '_', array, '_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat'];
    load(path)
end