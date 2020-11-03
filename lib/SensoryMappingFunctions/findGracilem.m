function mappingFile = findGracile(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).distal = contains(desc, {'leg', 'foot', 'ankle', 'toe', 'tail', 'thigh', 'knee', 'hip', 'heel'}, 'IgnoreCase', true);
    end
end