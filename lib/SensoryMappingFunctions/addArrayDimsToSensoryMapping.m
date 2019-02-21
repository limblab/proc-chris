function mappingFile = addArrayDimsToSensoryMapping(mappingLog, naming, monkey)
    mappingFile = [];
    for i = 1:length(mappingLog)
        mapRow = mappingLog(i);
        mapChan = mappingLog(i).chan;
        pinChan = naming(naming(:,1)==mapChan,2);
        mapShape= getMapShape(monkey);
        [row, col] = find(mapShape == mapChan);
        mapRow.row = row;
        mapRow.col = col;
        mapRow.elec = pinChan;
        mappingFile = [mappingFile;mapRow]; 
    end
end