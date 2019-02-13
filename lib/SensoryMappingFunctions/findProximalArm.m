function mappingFile = findProximalArm(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).proximal = strcmp(mappingFile(i).pc, 'p') & contains(desc, {'pec', 'delt', 'trap', 'shoulder', 'lat', 'terus'}, 'IgnoreCase', true);
    end
end