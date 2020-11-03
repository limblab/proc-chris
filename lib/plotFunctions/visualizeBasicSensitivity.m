function neurons = visualizeBasicSensitivity(neurons, td, params)
% clear all
path1 = 'D:\Figures\SensitivityChecks1\';

windowAct = [];
windowPas = [];
plotDistributions = true;
if nargin > 2, assignParams(who,params); end % overwrite parameters


    smoothWidth = 0.02;
    windowInds = true;
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td);
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
    
    speedAct = cat(1,tdAct.speed);
    speedPas =cat(1,tdPas.speed);
    
    accAct = cat(1,tdAct.acc);
    accPas = cat(1,tdPas.acc);
    if windowInds
        [keepIndsAct, keepIndsPas] = getKeepInds(velAct, velPas);

        velAct = velAct(keepIndsAct,:);
        actFR  = actFR(keepIndsAct,:);

        velPas = velPas(keepIndsPas,:);
        pasFR =  pasFR(keepIndsPas,:);
        
        speedAct = speedAct(keepIndsAct,:);
        speedPas = speedPas(keepIndsPas,:);
        
        accAct = accAct(keepIndsAct,:);
        accPas = accPas(keepIndsPas,:);
    end
   
    if plotDistributions
        fh1 = figure;
        histogram(speedAct,0:2:46, 'Normalization', 'probability')
        hold on
        histogram(speedPas,0:2:46, 'Normalization', 'probability')
        title('Speed distributions')
        legend('Active', 'Passive')
        
        fh2 = figure;
        histogram(accAct(:,1),-600:10:600, 'Normalization', 'probability')
        hold on
        histogram(accPas(:,1),-600:10:600, 'Normalization', 'probability')
        title('Acceleration distributions x acc')
        legend('Active', 'Passive')
        
        fh3 = figure;
        histogram(accAct(:,2),-600:10:600, 'Normalization', 'probability')
        hold on
        histogram(accPas(:,2),-600:10:600, 'Normalization', 'probability')
        title('Acceleration distributions y Acc')
        legend('Active', 'Passive')
        
        n1 = neurons(1,:);
        window = neurons(1,:).actWindow{1};
        fnameAccX = strjoin([n1.monkey, window{1,1}, num2str(window{1,2}), window{2,1}, num2str(window{2,2}), 'AccXMatch.png'],'');
        fnameSpeed = strjoin([n1.monkey, window{1,1}, num2str(window{1,2}), window{2,1}, num2str(window{2,2}), 'SpeedMatch.png'],'');
        fnameAccY = strjoin([n1.monkey, window{1,1}, num2str(window{1,2}), window{2,1}, num2str(window{2,2}), 'AccYMatch.png'],'');

        saveas(fh1, [path1,fnameSpeed]);
        saveas(fh2, [path1,fnameAccX]);
        saveas(fh3, [path1,fnameAccY]);

    end
    
end
%%
