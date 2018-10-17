td = parseFileByTrial(cds);
rewardTrials = td(strcmp({td.result}, 'R'));
moveOnsetTD = getMoveOnsetAndPeak(rewardTrials);
trimmedTD = trimTD(moveOnsetTD, 'idx_movement_on', {'idx_movement_on', 30});
tensorAll=  cat(3, trimmedTD.LeftS1_spikes);
tensorCor = permute(tensorAll, [3,2,1]);
