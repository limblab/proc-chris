function neurons = plotVelWindowing(neurons, td, params)

    windowAct = [];
    windowPas = [];
    numBoots = 10;
    windowInds = false;

    if nargin > 2, assignParams(who,params); end % overwrite parameters
    filepath = 'C:\Users\wrest\Dropbox\Chris Cuneate Function\Figures\CuneateEncodingPaper\SupFig2\FigParts\';
    smoothWidth = 0.02;
    numBoots = 3;

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
        velAct1 = cat(1,tdAct.vel);
        velPas = cat(1, tdPas.vel);
        velPas1 = cat(1, tdPas.vel);
        accAct = cat(1,tdAct.acc);
        accPas = cat(1,tdPas.acc);
        posAct = cat(1,tdAct.pos);
        posPas = cat(1, tdPas.pos);
        
        for i = 1:length(guide(:,1))  
            unitNum = find([guide(i,1) == neurons.chan] & [guide(i,2) == neurons.unitNum]);
            inputsAct = zscore([posAct, velAct, accAct]);
            inputsPas = zscore([posPas, velPas, accPas]);
            
            lmAct = fitlm(inputsAct, actFR(:,i));
            sAct1(i, boot) = norm(lmAct.Coefficients.Estimate(2:end));
            lmPas = fitlm(inputsPas, pasFR(:,i));
            sPas1(i, boot) = norm(lmPas.Coefficients.Estimate(2:end));

        end
        
        [keepIndsAct, keepIndsPas] = getKeepInds(velAct, velPas);
        posAct = posAct(keepIndsAct,:);
        velAct = velAct(keepIndsAct,:);
        accAct = accAct(keepIndsAct,:);
        actFR  = actFR(keepIndsAct,:);

        posPas = posPas(keepIndsPas,:);
        velPas = velPas(keepIndsPas,:);
        accPas = accPas(keepIndsPas,:);

        pasFR =  pasFR(keepIndsPas,:);
        for i = 1:length(guide(:,1))  
            unitNum = find([guide(i,1) == neurons.chan] & [guide(i,2) == neurons.unitNum]);
            inputsAct = zscore([posAct, velAct, accAct]);
            inputsPas = zscore([posPas, velPas, accPas]);
            
            lmAct = fitlm(inputsAct, actFR(:,i));
            sAct(i, boot) = norm(lmAct.Coefficients.Estimate(2:end));
            lmPas = fitlm(inputsPas, pasFR(:,i));
            sPas(i, boot) = norm(lmPas.Coefficients.Estimate(2:end));

        end
    end
    
    f1 = figure('Renderer', 'painters', 'Position', [10 10 450 900]);

    subplot(4,1,1)
    scatter(velAct1(:,1), velAct1(:,2))
    hold on
    scatter(velPas1(:,1), velPas1(:,2))
    axis square
    set(gca,'TickDir','out', 'box', 'off')

    subplot(4,1,3)
    scatter(velAct(:,1), velAct(:,2))
    hold on
    scatter(velPas(:,1), velPas(:,2))
    axis square
    set(gca,'TickDir','out', 'box', 'off')
    
    max1 = max([mean(sPas1'); mean(sAct1')]);
    subplot(4,1,2)
    scatter(mean(sPas1'), mean(sAct1'))
    hold on
    plot([0, max1],[0,max1])
    axis square
    set(gca,'TickDir','out', 'box', 'off')
    
    max1 = max([mean(sPas'); mean(sAct')]);

    subplot(4,1,4)
    scatter(mean(sPas'), mean(sAct'))
    hold on
    plot([0, max1],[0,max1])
    axis square
    set(gca,'TickDir','out', 'box', 'off')
    saveas(f1, [filepath, neurons(1,:).monkey{1}, '_WindowingEffects.pdf'])
end