function saveNeurons(neurons,suffix)
    if nargin ==1;suffix='';end
    path = getNeuronsPath(neurons);
    fileName = getNeuronsFilename(neurons, suffix);
    mkdir(path);
    save([path, fileName]);
    
end