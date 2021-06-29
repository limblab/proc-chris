function saveNeurons(neurons,suffix, resort)
    if nargin ==1;suffix='';end
    if nargin <3; resort = false;end
    path = getNeuronsPath(neurons, resort);
    fileName = getNeuronsFilename(neurons, suffix);
    mkdir(path);
    save([path, fileName]);
    disp([path, fileName]);
    
end