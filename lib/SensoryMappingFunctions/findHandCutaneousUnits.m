function mappingFile = findHandCutaneousUnits(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).handUnit = contains(desc, {'whorl','d1', 'd2', 'd3', 'd4', 'd5', 'glabrous','palmar','thumb', 'finger','hand', 'thenar'}, 'IgnoreCase', true);
    end
end