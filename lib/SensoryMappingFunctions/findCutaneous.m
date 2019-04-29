function mappingFile = findCutaneous(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).cutaneous = contains(desc, {'skin', 'brush'}, 'IgnoreCase', true);
        mappingFile(i).proprio = contains(desc, {'flexion', 'extension', 'rotation', 'abduction', 'adduction','deviation','elevation'}) | mappingFile(i).spindle | strcmp(mappingFile(i).pc, 'p');
    end
end