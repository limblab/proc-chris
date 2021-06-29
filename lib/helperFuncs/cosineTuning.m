function neurons = cosineTuning(td, neurons, params)
    windowAct = {'idx_movement_on', 0; 'idx_movement_on',13};
    windowPas = {'idx_bumpTime', 0; 'idx_bumpTime', 13};
    if nargin > 2, assignParams(who,params); end % overwrite parameters
    array= getTDfields(td, 'arrays');
    array = array{1};
    tdAct = td(~isnan([td.idx_movement_on]));
    tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
    tdAct = tdAct(isnan([tdAct.idx_bumpTime]));

    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, windowPas(1,:), windowPas(2,:));
    
    dirsB = unique([td.bumpDir]);
    dirsB(isnan(dirsB))= [];
    dirsB(mod(dirsB, 45)~=0)=[];
    
    dirsM = unique([td.target_direction]);
    dirsM(isnan(dirsM)) = [];
    for dir1 = 1:length(dirsM)
        tdDir{dir1} =  tdAct([tdAct.target_direction] == dirsM(dir1));
        firing{dir1} = cat(3, tdDir{dir1}.([array,'_spikes']));
    end
    for dir1 = 1:length(dirsM)
        tuning(dir1,:) = mean(mean(firing{dir1},3),1);
    end
    
    for dir1 = 1:length(dirsB)
        tdDir{dir1} =  tdPas([tdPas.bumpDir] == dirsB(dir1));
        firing{dir1} = cat(3, tdDir{dir1}.([array,'_spikes']));
    end
    for dir1 = 1:length(dirsB)
        tuningB(dir1,:) = mean(mean(firing{dir1},3),1);
    end
    
    theta = dirsM;
    thetaB = dirsB;
    for unit = 1:length(tuning(1,:))
        fun = @(x) sum((tuning(:,unit)' - (x(1)*cos(theta - x(2)) + x(3))).^2);
        funB = @(xB) sum((tuningB(:,unit)' - (xB(1)*cos(thetaB - xB(2)) + xB(3))).^2);
        x0 = [.1, pi/2, .1];
        
        xEst = fminsearch(fun, x0);
        xEstB = fminsearch(funB, x0);
        
        paramsEst(:,unit) = xEst;
        estTuning(unit,:) = paramsEst(1,unit)*cos(theta - paramsEst(2,unit)) + paramsEst(3,unit);
        
        paramsEstB(:,unit) = xEstB;
        estTuningB(unit,:) = paramsEstB(1,unit)*cos(thetaB - paramsEstB(2,unit)) + paramsEstB(3,unit);

        r2CosCorr = corrcoef(estTuning(unit,:)', tuning(:,unit));
        r2CosCorrB = corrcoef(estTuningB(unit,:)', tuningB(:,unit));
        
        r2Cos(unit) = r2CosCorr(1,2).^2;
        r2CosB(unit) = r2CosCorrB(1,2).^2;
    end
    neurons.r2CosineMove = r2Cos';
    neurons.r2CosineBump = r2CosB';
end