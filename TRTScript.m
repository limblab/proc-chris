movements = td(~any(isnan(cat(1,td.idx_goCueTime))'));
movements = trimTD(movements, 'idx_goCueTime', 'idx_endTime');

bumpTrials = td(~isnan([td.bumpDir]));
bumpTrials = bumpTrials(~isnan([bumpTrials.idx_bumpTime]));
bumpTrials = removeBadTrials(bumpTrials);
bumpMovement = trimTD(bumpTrials, 'idx_bumpTime', {'idx_bumpTime', 13});

params.out_signals = 'cuneate_spikes';
params.out_signal_names = bumpMovement.cuneate_unit_guide;
params.in_signals = 'vel';

pasPDTable = getTDPDs(bumpMovement, params);
actPDTable = getTDPDs(movements, params);
