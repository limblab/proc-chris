function neurons = mapFromChan(neurons)
    map = getMapForMonkey(neurons.monkey(1,:));
    for i = 1:height(neurons)
        neurons.mapName(i) = map(find(neurons.chan(i) == map(:,1)), 2);
    end
end