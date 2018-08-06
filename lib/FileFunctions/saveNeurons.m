function saveNeurons(neurons,params)
    path = getNeuronsPath(neurons);
    fileName = getNeuronsFilename(neurons.monkey{1}, neurons.date{1}, neurons.task{1});
    mkdir(path);
    save([path, fileName], 'neurons');
    
end