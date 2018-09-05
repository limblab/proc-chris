function fn =  getNeuronsFilename(neurons)
    monkey = neurons.monkey{1};
    array = neurons.array{1};
    date = neurons.date{1};
    task = neurons.task{1};
    if strcmp(task(1:2), 'CO')
        window = {neurons.actWindow{1}{:,1},neurons.pasWindow{1}{:,1}}; 
        fn = [strjoin({monkey, date, task, array,  strjoin(window, '_')}, '_'), '_NeuronStructConservative.mat'];
    else
        fn = [strjoin({monkey, date, task,array }, '_'), '_NeuronStruct.mat'];
    end
end