function neurons = doBasicSensitivity(neurons, td, params)
% clear all
windowAct = [];
windowPas = [];
if nargin > 2, assignParams(who,params); end % overwrite parameters
close all
    smoothWidth = 0.02;
    windowInds = true;
    
    filds = fieldnames(td);
    array = filds(contains(filds, '_spikes'),:);
    array = array{1}(1:end-7);
    td = smoothSignals(td, struct('signals', [array,'_spikes'], 'calc_rate',true, 'width', smoothWidth));

    monkey = neurons.monkey(1);

    if windowInds
        suffix = ['WindowedMatch', monkey];
    else
        suffix = ['FullData', monkey];
    end
    
    td = getSpeed(td);
    guide = td(1).([array, '_unit_guide']);
    td([td.idx_peak_speed]< [td.idx_movement_on])=[];
    tdAct = trimTD(td, windowAct(1,:), windowAct(2,:));
    
    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, windowPas(1,:), windowPas(2,:));
           
    actFR = cat(1, tdAct.([array, '_spikes']));
    pasFR = cat(1, tdPas.([array, '_spikes']));

    velAct = cat(1,tdAct.vel);
    velPas = cat(1, tdPas.vel);
    
    if windowInds
        [keepIndsAct, keepIndsPas] = getKeepInds(velAct, velPas);

        velAct = velAct(keepIndsAct,:);
        actFR  = actFR(keepIndsAct,:);

        velPas = velPas(keepIndsPas,:);
        pasFR =  pasFR(keepIndsPas,:);
    end
   

    sAct = zeros(length(guide),1);
    sPas = zeros(length(guide),1);   
    for i = 1:length(guide(:,1))
        unitNum = find([guide(i,1) == neurons.chan] & [guide(i,2) == neurons.unitNum]);
       
        lmAct = fitlm(velAct, actFR(:,i));
        sAct(i) = norm(lmAct.Coefficients.Estimate(2:3));
        lmPas = fitlm(velPas, pasFR(:,i));
        sPas(i) = norm(lmPas.Coefficients.Estimate(2:3));
        neurons.sAct(unitNum) = sAct(i);
        neurons.sPas(unitNum) = sPas(i);
    end
end
%%
