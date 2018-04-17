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
end