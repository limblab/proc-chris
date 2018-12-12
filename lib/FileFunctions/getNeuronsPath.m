function path = getNeuronsPath(neurons)
    basePath = getBasePath();
    path = strjoin([getBasicPath(neurons(1,:).monkey, dateToLabDate(neurons(1,:).date), getGenericTask(neurons(1,:).task{1})), 'neuronStruct/'],'');
end