function mappingFile = findHandCutaneousUnits(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).handUnit = strcmp(mappingFile(i).pc, 'c') & contains(desc, {'whorl','d1', 'd2', 'd3', 'd4', 'd5', 'glabrous','palmar','thumb', 'finger','hand'}, 'IgnoreCase', true);
    end
end