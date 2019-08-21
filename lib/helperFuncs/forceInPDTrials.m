function tdOut = forceInPDTrials(td, pd)
    forces = [td.forceDir];
    targets = [td.target_direction];
    pdsWrap = [315 0 45 90 135 180 225 270 315 0];
    indWrap = [8 1 2 3 4 5 6 7 8 1];
    ind = pd+1;
    tdOut = td(rad2deg(targets)==pdsWrap(ind) & (forces ==pdsWrap(ind-1) | forces == pdsWrap(ind) |  forces == pdsWrap(ind+1))); 

end