function path = getNeuronsPath(neurons, params)
    basePath = getBasePath();
    path = [basePath, getGenericTask(neurons.task{1}),'\Neurons\'];
end