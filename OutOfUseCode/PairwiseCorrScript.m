
    % split td and trim to only post movement/bump epoch
    td_act = td(isnan([td.idx_bumpTime]));    
    td_act = trimTD(td_act,{'idx_movement_on',0},{'idx_movement_on',15});
    td_pas = td(~isnan([td.idx_bumpTime]));
    td_pas = trimTD(td_pas,{'idx_bumpTime',0},{'idx_bumpTime',15});

    [rho_act,sort_idx] = pairwiseCorr(td_act,struct('signals',{{'cuneate_spikes'}},'cluster_order',true));
    [rho_pas] = pairwiseCorr(td_pas,struct('signals',{{'cuneate_spikes'}}));

    figure
    subplot(2,1,1)
    imagesc(rho_act(sort_idx,sort_idx))
    clim = get(gca,'clim');
    colorbar
    axis square
    title 'cuneate neural correlation - Active'
    subplot(2,1,2)
    imagesc(rho_pas(sort_idx,sort_idx),clim)
    colorbar
    axis square
    title 'cuneate neural correlation - Passive'