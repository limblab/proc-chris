function neuron_struct = getNeuronsByTask(td, params)
    names = fieldnames(td);
    arrayNames= cellfun(@(x) x(1:end-7), names(~cellfun(@isempty, strfind(names, '_spikes'))), 'UniformOutput', false);
    task = td(1).task;
    date = td(1).date;
    monkey = td(1).monkey;
    binSize = td(1).binSize;
    
    params.task = task;
    params.date = date;
    params.monkey = monkey;
    
    if (strcmp(task(1:2), 'CO'))
        neuron_struct= getCONeurons(td, params);
    elseif (strcmp(tas(1:2), 'RW'))
        neuron_struct= getRWNeurons(td, params);
    for i = 1:length(arrayNames)
        array= arrayNames{i};
        
    end
end