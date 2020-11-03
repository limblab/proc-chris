function mappingFile = findDistalArm(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).distal = contains(desc, {'wrist', 'hand','forearm', 'finger','thumb', 'FCU', 'FCR', 'ECR', 'ECU', 'brad', 'brachioradialis'}, 'IgnoreCase', true);
    end
end