function neurons = getNeurons(monkey, date, task, array, windows)
    window = string(windows');
    window = window(:);
    path = [getBasicPath(monkey, date, getGenericTask(task)), 'neuronStruct', filesep, monkey,'_',date, '_', task, '_', array, '_', strjoin(window, '_'), '_NeuronStruct_MappedNeurons.mat'];
    load(strjoin(path,''))
    neurons = funcForDifTargets(neurons);
end