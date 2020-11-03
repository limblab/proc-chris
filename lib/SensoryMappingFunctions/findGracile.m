function mappingFile = findGracile(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).gracile = contains(desc, {'leg', 'foot', 'ankle', 'toe', 'tail', 'thigh', 'knee', 'hip', 'heel'}, 'IgnoreCase', true);
    end
end