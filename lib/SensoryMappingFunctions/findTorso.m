function mappingFile = findTorso(mappingFile)
    for  i =1:length(mappingFile)
        desc = mappingFile(i).desc;
        mappingFile(i).torso = contains(desc, {'blade', 'hip', 'back', 'intercostal', 'erector','nipple', 'rib'}, 'IgnoreCase', true);
    end
end