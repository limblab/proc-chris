function neurons = doBootstrapSensitivityWindows(neurons, td, params)

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
    windows = {'idx_movement_on',1,'idx_movement_on', 13;...
              'idx_movement_on',13,'idx_movement_on', 23;...
              'idx_movement_on',23,'idx_movement_on', 33;...
              'idx_movement_on',33,'idx_movement_on', 43};
    for win = 1:length(windows(:,1))
    tdAct1 = trimTD(td,  {windows{win,1:2}}, {windows{win,3:4}});
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
  
        if windowInds
            [keepIndsAct, keepIndsPas] = getKeepInds(velAct, velPas);

            velAct = velAct(keepIndsAct,:);
            actFR  = actFR(keepIndsAct,:);
    
            velPas = velPas(keepIndsPas,:);
            pasFR =  pasFR(keepIndsPas,:);
        end
        for i = 1:length(guide(:,1))  
            unitNum = find([guide(i,1) == neurons.chan] & [guide(i,2) == neurons.unitNum]);
            lmAct = fitlm(velAct, actFR(:,i));
            sAct(i, boot) = norm(lmAct.Coefficients.Estimate(2:3));
            lmPas = fitlm(velPas, pasFR(:,i));
            sPas(i, boot) = norm(lmPas.Coefficients.Estimate(2:3));
            neurons.sActBootWin(unitNum, boot,win) = sAct(i,boot);
            neurons.sPasBootWin(unitNum, boot,win) = sPas(i,boot);
            neurons.sDifBootWin(unitNum, boot,win) =sAct(i,boot) - sPas(i,boot);
        end
    end
    end
end