function processedTrial = compiledCOActPasAnalysis(td, params)
%UNTITLED Summary of this function goes here
%   Detailed explanation
    cutoff = pi/4;
    arrays= {'LeftS1', 'RightCuneate'};
    windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
    windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
    distribution = 'normal';
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    if(td(1).bin_size == .01)
        tdBin = binTD(td,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end
    
    tdBump = td(~isnan([td.bumpDir])); 
    
    tdAct = trimTD(tdBin, windowAct(1,:), windowAct(2,:));
    tdPas = trimTD(tdBump, windowPas(1,:), windowPas(2,:));
    
    for i=1:length(arrays)
        
        params.array= arrays{i};
        params.out_signals = [params.array, '_spikes'];
        params.distribution = distribution;
        params.out_signal_names =td(1).([params.array, '_unit_guide']); 
        
        params.window = windowAct;
        tablePDsAct = getTDPDs(tdAct, params);
        tablePDsAct.sinTuned = isTuned(tablePDsAct.velPD, tablePDsAct.velPDCI, cutoff)';
        
        params.window=  windowPas;
        tablePDsPas = getTDPDs(tdPas, params);
        tablePDsPas.sinTuned = isTuned(tablePDsPas.velPD, tablePDsPas.velPDCI, cutoff)';
        
        params.sinTuned = tablePDsAct.sinTuned  & tablePDsPas.sinTuned;
        [fh, outStruct] = getCOActPasStats(td, params);
        
        processedTrial(i).array = params.array;
        processedTrial(i).date= params.date;
        processedTrial(i).actTrim = params.windowAct;
        processedTrial(i).pasTrim = params.windowPas;
        processedTrial(i).comments = 'Here goes nothing';
        processedTrial(i).actPDTable = tablePDsAct;
        processedTrial(i).pasPDTable = tablePDsPas;
        processedTrial(i).actPasStats = outStruct;
    end
    
end
