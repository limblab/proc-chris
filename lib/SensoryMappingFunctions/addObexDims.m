function mappingFile1 = addObexDims(mappingFile, monkey)
    rows = max([mappingFile.row]);
    cols = max([mappingFile.col]);
    dists = zeros(rows, cols,2);
    [rm, rl, cm, cl] = getObexDims(monkey);
    
    cm2rm = (rm-cm)/(rows-1);
    cm2cl = (cl-cm)/(cols-1);
    
    for i = 1:rows
        for j = 1:cols
            obexCoords(i,j,:) = cm + (i-1)*cm2rm + (j-1)*cm2cl;
        end
    end
    
    obexCoords = flipud(obexCoords);
    
%     elec1 = mappingFile([mappingFile.chan] ==1);
%     elec1 = elec1(1,:);
    
    obexCoords(:,:,1) = rot90(obexCoords(:,:,1),2);
    obexCoords(:,:,2) = rot90(obexCoords(:,:,2),2);
%     temp1 = obexCoords(:,:,1);
%     temp2 = obexCoords(:,:,2);
%     figure
%     scatter(temp1(:), temp2(:), 32, 'filled')
%     hold on
%     scatter(0, 0, 'filled')
%     tCord = obexCoords(elec1.row, elec1.col,:);
%     scatter(tCord(1), tCord(2), 32,  'r', 'filled')
    
    
    for i = 1:length(mappingFile)
        map = mappingFile(i,:);
        row1 = map.row;
        col1 = map.col;
        coord = squeeze(obexCoords(row1, col1, :));
        map.obexCoord = coord';
        mappingFile1(i,:) = map;
    end
end