function path1 = getNeuronsPath(neurons, resort)
    if nargin<2;resort= false;end
    basePath = getBasePath();
    path1 = strjoin([getBasicPath(neurons(1,:).monkey, dateToLabDate(neurons(1,:).date{1}), getGenericTask(neurons(1,:).task{1}), resort), 'neuronStruct', filesep],'');
end