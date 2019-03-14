function fh = plotSomatotopy(mappingFile, monkey)
    mapShape = getMapShape(monkey);
    proxMap = zeros(size(mapShape));
    midMap = zeros(size(mapShape));
    distMap = zeros(size(mapShape));
    handMap = zeros(size(mapShape));
    mappingFile= mappingFile([mappingFile.id] >0);
    
    for i = 1:length(mappingFile)
        if mappingFile(i).handUnit
            handMap(mappingFile(i).row, mappingFile(i).col) = 1;
        end
        if mappingFile(i).proximal
            proxMap(mappingFile(i).row, mappingFile(i).col) = 1;
        end
        if mappingFile(i).midArm
            midMap(mappingFile(i).row, mappingFile(i).col) = 1;
        end
        if mappingFile(i).distal
            distMap(mappingFile(i).row, mappingFile(i).col) = 1;
        end
    end
    
    fh{1}= figure2();
    imagesc(handMap)
    
    title('Hand cutaneous units')
    
    fh{2}= figure2();
    imagesc(proxMap)
    title('Proximal Arm proprioceptive units')
    
    fh{3}= figure2();
    imagesc(midMap)
    title('Mid arm proprioceptive units')
    
    fh{4}= figure2();
    imagesc(distMap)
    title('Distal arm proprioceptive units')
    
end