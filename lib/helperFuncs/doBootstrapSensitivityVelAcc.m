function neurons = doBootstrapSensitivityVelAcc(neurons, td, params)

    windowAct = [];
    windowPas = [];
    numBoots = 100;

    if nargin > 2, assignParams(who,params); end % overwrite parameters
    smoothWidth = 0.02;

    windowInds = true;
    filds = fieldnames(td);
    array = filds(contains(filds, '_spikes'),:);
    array = array{1}(1:end-7);
    
    td = smoothSignals(td, struct('signals', [array,'_spikes'], 'calc_rate',true, 'width', smoothWidth));    
        
    guide = td(1).([array, '_unit_guide']);
    td([td.idx_peak_speed]< [td.idx_movement_on])=[];
    tdAct1 = trimTD(td,  windowAct(1,:), windowAct(2,:));
    tdPas1 = td(~isnan([td.idx_bumpTime]));
    
    tdPas1 = trimTD(tdPas1,  windowPas(1,:), windowPas(2,:));
    tmpVec = 1:length(tdAct1);
    tmpVec2 = 1:length(tdPas1);
    bootMat = tmpVec(randi(length(tdAct1), numBoots, length(tdAct1)));
    bootMatP = tmpVec2(randi(length(tdPas1), numBoots, length(tdPas1)));
    
    sAct = zeros(length(guide),numBoots);
    sPas = zeros(length(guide),numBoots); 
    
    %%
    for boot = 1:numBoots
        disp(['Bootstrap number: ', num2str(boot)])
        tdAct = tdAct1(bootMat(boot,:));
        tdPas = tdPas1(bootMatP(boot,:));

        actFR = cat(1, tdAct.([array, '_spikes']));
        pasFR = cat(1, tdPas.([array, '_spikes']));

        velAct = cat(1,tdAct.vel);
        velPas = cat(1, tdPas.vel);
        accAct = cat(1,tdAct.acc);
        accPas = cat(1,tdPas.acc);
        
  
        if windowInds
            [keepIndsAct, keepIndsPas] = getKeepInds(velAct, velPas);
            
            velAct = velAct(keepIndsAct,:);
            accAct = accAct(keepIndsAct,:);
            actFR  = actFR(keepIndsAct,:);
            
            
            velPas = velPas(keepIndsPas,:);
            accPas = accPas(keepIndsPas,:);
            
            pasFR =  pasFR(keepIndsPas,:);
        end
        for i = 1:length(guide(:,1))  
            unitNum = find([guide(i,1) == neurons.chan] & [guide(i,2) == neurons.unitNum]);
            inputsAct = zscore([velAct, accAct]);
            inputsPas = zscore([velPas, accPas]);
            
            lmAct = fitlm(inputsAct, actFR(:,i));
            sAct(i, boot) = norm(lmAct.Coefficients.Estimate(2:end));
            lmPas = fitlm(inputsPas, pasFR(:,i));
            sPas(i, boot) = norm(lmPas.Coefficients.Estimate(2:end));
            neurons.sActVelAccBoot(unitNum, boot) = sAct(i,boot);
            neurons.sPasVelAccBoot(unitNum, boot) = sPas(i,boot);
            neurons.sDifVelAccBoot(unitNum, boot) =sAct(i,boot) - sPas(i,boot);
        end
    end
end