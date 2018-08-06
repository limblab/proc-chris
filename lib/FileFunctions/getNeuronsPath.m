function path = getNeuronsPath(neurons)
    basePath = getBasePath();
    path = [basePath, getGenericTask(neurons.task{1}),filesep, 'Neurons',filesep];
end