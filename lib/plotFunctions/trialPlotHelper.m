function fh = trialPlotHelper(td, params)
    for i =1 :10
        trial = td(i);
        params.bumpTime = -10000;
        params.moveTime = -10000;
        params.goTime = -10000;
        if (~isnan(trial.bumpDir))
            params.bumpTime = trial.idx_bumpTime: trial.idx_bumpTime +13;
            params.moveTime = trial.idx_movement_on;
            params.goTime = trial.idx_goCueTime;
        else
            params.moveTime = trial.idx_movement_on;
            params.goTime = trial.idx_goCueTime;
        end
        fh = trialRaster(trial, params);
%        pause() 
    end
end