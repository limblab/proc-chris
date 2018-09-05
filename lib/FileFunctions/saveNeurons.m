function saveNeurons(neurons,params)
    path = getNeuronsPath(neurons);
    fileName = getNeuronsFilename(neurons);
    mkdir(path);
    save([path, fileName]);
    
end