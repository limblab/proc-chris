function [musclePDs] = coMuscleTuning(td, params)
    includeSpeedTerm = false;
    cutoff = pi/2; %cutoff for significant of sinusoidal tuning
    windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
    windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
    distribution = 'normal'; %what distribution to use in the GLM models
    train_new_model = true; %whether to train new models (can pass in old models in params struct to save time, or don't and it'll run but pass a warning
    neuronProcessed1 = []; %
    monkey  = td(1).monkey;
    %% Assign params
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    tdAct = td(strcmp({td.result},'R'));
    tdAct = tdAct(~isnan([tdAct.idx_movement_on]));
    tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
    tdBump = td(~isnan([td.bumpDir]) & abs([td.bumpDir]) <361); 
    tdPas = trimTD(tdBump, windowPas(1,:), windowPas(2,:));
    
    params.monkey = td(1).monkey;
    params.date = td(1).date;
    params.windowAct = windowAct;
    params.windowPas = windowPas;
    params.out_signals = 'opensim';
    params.distribution = distribution;
    params.out_signal_names =td(1).opensim_names'; 
    params.window = windowAct;
    musclePDsAct = getTDPDsSpeedCorr(tdAct, params);
    musclePDsAct.sinTuned = musclePDsAct.velTuned;

    params.window=  windowPas;
    musclePDsPas = getTDPDsSpeedCorr(tdPas, params);
    musclePDsPas.sinTuned = musclePDsPas.velTuned;
    sinTunedAct = musclePDsAct.sinTuned;
    sinTunedPas = musclePDsPas.sinTuned;
    musclePDs.actPD = musclePDsAct;
    musclePDs.pasPD = musclePDsPas;
end