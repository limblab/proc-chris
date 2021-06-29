function neurons = getNeurons(monkey, date1, task, array, windows, suffix)
    if nargin < 6 ; suffix='MappedNeurons';end
    if ~isempty(windows)
        window = string(windows');
        window = window(:);
        path1 = [getBasicPath(monkey, date1, getGenericTask(task)), 'neuronStruct', filesep, monkey,'_',date1, '_', task, '_', array, '_', strjoin(window, '_'), '_NeuronStruct_',suffix, '.mat'];
        if (exist(strjoin(path1, '')))
            load(strjoin(path1,''))
            neurons = funcForDifTargets(neurons);
            disp(strjoin(path1,''))
        else 
            disp(strjoin(path1,''))
            neurons = [];
        end
    else
        path1 = [getBasicPath(monkey, dateToLabDate(date1), getGenericTask(task)), 'neuronStruct', filesep,strjoin({monkey, date1, task, array}, '_'), '_NeuronStruct_', suffix, '.mat'];
        if (exist(path1))
            load(path1)
            disp(path1)
        else 
            disp(strjoin(path1,''))
            neurons = [];
        end
end