function fh = plotMappingOnArray(mapping, mapArrangement)
    map = -1*ones(10,10);
    [~,index] = sortrows({mapping.date}.'); mapping = mapping(index); clear index
    for i = 1:length(mapping)
        [x,y] = find(mapArrangement == mapping(i).chan);
        if contains(mapping(i).desc, {'leg', 'foot', 'heel', 'hip', 'butt', 'tail'}, 'IgnoreCase', true)
            map(x,y) = 0;
        elseif strcmp(mapping(i).pc, 'c')
            map(x,y) = 1;
        elseif strcmp(mapping(i).pc, 'p') & ~mapping(i).spindle
            map(x,y) = 2;
        elseif mapping(i).spindle
            map(x,y)=3;
        end
        
    end
    fh = imagesc(map)
    proximal = {'upper', 'shoulder', 'elbow', 'bicep', 'tricep', 'delt', 'torso', 'armpit', 'chest', 'rib', 'lat','latisimus','spine', 'brachialis','brachioradialis'};
    distal = {'wrist', 'hand','d1','d2','d3','d4','d5', 'palm', 'finger', 'forearm', 'ecr','ecu','fcr', 'fcu', 'fds'}
    proxmap = -1*ones(10,10);
    for i = 1:length(mapping)
        [x,y] = find(mapArrangement == mapping(i).chan);
        if contains(mapping(i).desc, {'leg', 'foot', 'heel', 'hip', 'butt', 'tail'}, 'IgnoreCase', true)
            proxmap(x,y) = 0;
        elseif contains(mapping(i).desc, proximal, 'IgnoreCase', true)
            proxmap(x,y) = 1;
        elseif contains(mapping(i).desc, distal, 'IgnoreCase', true)
            proxmap(x,y) = 2;
        end
        
    end
    fh2 = imagesc(proxmap)
end