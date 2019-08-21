function f1 = plotUnitsOnGrid(cds)
    gridX = max([cds.units.colNum]);
    gridY = max([cds.units.rowNum]);
    numUnits = zeros(gridX, gridY);
    units = cds.units;
    units([units.ID] ==0) = [];
    units([units.ID] >10) = [];
    for i = 1:gridX
        for j= 1:gridY
           numUnits(i,j) = sum([units.rowNum] ==j & [units.colNum]==i & [units.ID] >0  & [units.ID] <255);
        end
    end
    figure2();
    numUnitsFlip = flip(numUnits');
    imagesc(numUnitsFlip)
    colorbar
    title('Units on Array Snap PostOp')
end