close all
clear all
for i = 1:3
    switch i
        case 1
            monkey = 'Butter';
            date = '20190129';
            mappingFile = getSensoryMappings(monkey);
            prevDateFlag = datetime({mappingFile.date}, 'InputFormat', 'yyyyMMdd') <= datetime(date, 'InputFormat', 'yyyyMMdd');
            mappingFile = mappingFile(prevDateFlag);
        case 2
            monkey = 'Snap';
            date = '20190829';
            mappingFile = getSensoryMappings(monkey);
            prevDateFlag = datetime({mappingFile.date}, 'InputFormat', 'yyyyMMdd') <= datetime(date, 'InputFormat', 'yyyyMMdd');
            mappingFile = mappingFile(prevDateFlag);
        case 3
            monkey = 'Crackle';
            date = '20190418';
            mappingFile = getSensoryMappings(monkey);
            prevDateFlag = datetime({mappingFile.date}, 'InputFormat', 'yyyyMMdd') <= datetime(date, 'InputFormat', 'yyyyMMdd');
            mappingFile = mappingFile(prevDateFlag);
    end
    
    
    mappingFile = findDelete(mappingFile);
    mappingFile = findDistalArm(mappingFile);
    mappingFile = findHandCutaneousUnits(mappingFile);
    mappingFile = findProximalArm(mappingFile);
    mappingFile = findMiddleArm(mappingFile);
    mappingFile = findCutaneous(mappingFile);
    mappingFile = findGracile(mappingFile);
    mappingFile = findTrigem(mappingFile);
    mappingFile = findTorso(mappingFile);
    mappingFile = addObexDims(mappingFile, monkey);
    
%     mappingFile = mappingFile(strcmp([mappingFile.date], date))
    plotMappingFileOnObex(mappingFile, monkey);
end