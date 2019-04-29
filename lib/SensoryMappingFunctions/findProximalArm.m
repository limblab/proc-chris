function mappingFile = findProximalArm(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).proximal = contains(desc, {'pec', 'delt', 'trap', 'shoulder', 'lat', 'terus', 'scapula'}, 'IgnoreCase', true);
    end
end