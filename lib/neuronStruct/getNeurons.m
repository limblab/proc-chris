function neurons = getNeurons(monkey, date, task)
    path = [getBasicPath(monkey, date, getGenericTask(task)),filesep, 'neuronStruct', filesep, monkey,'_',date, '_', task, '_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat'];
    load(path)
end