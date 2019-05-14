function fn =  getNeuronsFilename(neurons, suffix)
    monkey = neurons.monkey{1};
    array = neurons.array{1};
    date = neurons.date{1};
    task = neurons.task{1};
    actWindow = neurons.actWindow{1}';
    actWindow = actWindow(:);
    pasWindow = neurons.pasWindow{1}';
    pasWindow = pasWindow(:);
    pasWindow = cellfun(@num2str, pasWindow, 'un', 0);
    actWindow = cellfun(@num2str, actWindow, 'un', 0);
    pasWindow = strjoin(pasWindow, '_');
    actWindow = strjoin(actWindow, '_');
    
    if strcmp(task(1:2), 'CO')
        window = {neurons.actWindow{1}{:,1},neurons.pasWindow{1}{:,1}}; 
        fn = [strjoin({monkey, date, task, array, actWindow, pasWindow}, '_'), '_NeuronStruct_', suffix, '.mat'];
    else
        fn = [strjoin({monkey, date, task, array}, '_'), '_NeuronStruct_', suffix,'.mat'];
    end
end