function mappingFile = findDelete(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        if contains(desc, {'delete'}, 'IgnoreCase', true);
            removeFlag(i) = true;
        else
            removeFlag(i) = false;
        end
        if strcmp(desc, '?')
            removeFlag(i) = true;
        end
    end
    disp(['Removing ', num2str(sum(removeFlag))])
    mappingFile(removeFlag,:) = [];
end