function mappingFile = findMiddleArm(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).midArm = strcmp(mappingFile(i).pc, 'p') & contains(desc, {'elbow', 'bicep', 'tricep', 'brachialis'}, 'IgnoreCase', true);
    end
end