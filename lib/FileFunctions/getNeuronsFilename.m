function fn =  getNeuronsFilename(neurons, suffix)
    monkey = neurons.monkey{1};
    array = neurons.array{1};
    date1 = neurons.date{1};
    task = neurons.task{1};
    fn1 = fieldnames(neurons);
    if any(contains(fn1, 'actWindow'))
        actWindow = neurons.actWindow{1}';
        actWindow = actWindow(:);
        if strcmp(task(1:2), 'CO')
            pasWindow = neurons.pasWindow{1}';
            pasWindow = pasWindow(:);
            pasWindow = cellfun(@num2str, pasWindow, 'un', 0);
            pasWindow = strjoin(pasWindow, '_');

        end

        actWindow = cellfun(@num2str, actWindow, 'un', 0);
        actWindow = strjoin(actWindow, '_');

        if strcmp(task(1:2), 'CO')
            window = {neurons.actWindow{1}{:,1},neurons.pasWindow{1}{:,1}}; 
            fn = [strjoin({monkey, date1, task, array, actWindow, pasWindow}, '_'), '_NeuronStruct_', suffix, '.mat'];
        else
            fn = [strjoin({monkey, date1, task, array}, '_'), '_NeuronStruct_', suffix,'.mat'];
        end
    else
        fn = [strjoin({monkey, dateToLabDate(date1), task, array}, '_'), '_NeuronStruct_', suffix, '.mat'];
    end
end