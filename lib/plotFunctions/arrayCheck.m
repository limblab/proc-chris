function fh = arrayCheck(cds)
    units = cds.units;
    sorted = units([units.ID] >0 & [units.ID] <255 & [units.chan] <97);
    rows = [sorted.rowNum];
    cols = [sorted.colNum];
    maps = zeros(12, 8);
    for i =1:length(sorted)
        maps(rows(i), cols(i)) = maps(rows(i), cols(i)) +1;
    end
    fh =figure2();
    imagesc(maps)
    title('Number of units on a channel')
    xlabel('Medial ---------------- Lateral')
    ylabel('Caudal ---------------- Rostral')
    
    set(gca,'YDir','normal')
    axis equal
end
