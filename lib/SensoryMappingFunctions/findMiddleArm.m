function mappingFile = findMiddleArm(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).midArm = contains(desc, {'elbow', 'bicep', 'tricep', 'brachialis'}, 'IgnoreCase', true);
    end
end