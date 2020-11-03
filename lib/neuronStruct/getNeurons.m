function neurons = getNeurons(monkey, date, task, array, windows)
    window = string(windows');
    window = window(:);
    path1 = [getBasicPath(monkey, date, getGenericTask(task)), 'neuronStruct', filesep, monkey,'_',date, '_', task, '_', array, '_', strjoin(window, '_'), '_NeuronStruct_MappedNeurons.mat'];
    if (exist(strjoin(path1, '')))
        load(strjoin(path1,''))
        neurons = funcForDifTargets(neurons);
        disp(strjoin(path1,''))
    else 
        neurons = [];
    end
end