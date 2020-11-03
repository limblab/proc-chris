function td = getMoveBumps(td)
    moveBump = ~isnan([td.idx_bumpTime]) & [td.idx_bumpTime] > [td.idx_movement_on];
    temp = num2cell(moveBump);
    [td.movementBump] = deal(temp{:});
end