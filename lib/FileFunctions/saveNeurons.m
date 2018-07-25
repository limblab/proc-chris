function saveNeurons(neurons,params)
    path = getNeuronsPath(neurons,params);
    fileName = getNeuronsFilename(neurons.monkey{1}, neurons.date{1}, neurons.task{1});
    save([path, fileName], 'neurons');
    
end