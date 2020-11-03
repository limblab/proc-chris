function mappingFile = findTrigem(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).trigem = contains(desc, {'head', 'face', 'lip', 'brow'}, 'IgnoreCase', true);
        if strcmp(desc, 'ear')
            mappingFile(i).trigem = true;
        end
    end
end