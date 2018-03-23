function [processedTrial, neuronProcessed1] = compiledCOActPasAnalysis(td, params)
%UNTITLED Summary of this function goes here
%   Detailed explanation
    cutoff = pi/4;
    arrays= {'cuneate'};
    windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
    windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
    distribution = 'normal';
    train_new_model = true;
    neuronProcessed1 = [];
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters

    if(~isfield(td(1), 'idx_movement_on'))
        td = getMoveOnsetAndPeak(td);
    end
    if(td(1).bin_size == .01)
        tdBin = binTD(td,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end
    
    tdAct = tdBin(strcmp({tdBin.result},'R'));
    tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
    
    tdBump = tdBin(~isnan([tdBin.bumpDir])); 
    
    tdPas = trimTD(tdBump, windowPas(1,:), windowPas(2,:));
    
    for i=1:length(arrays)
        params.array= arrays{i};
        params.date = td(1).date;
        params.windowAct = windowAct;
        params.windowPas = windowPas;
        params.out_signals = [params.array, '_spikes'];
        params.distribution = distribution;
        params.out_signal_names =td(1).([params.array, '_unit_guide']); 
        params.num_bins = 4;
        params.window = windowAct;
        if train_new_model

          
            tablePDsAct = getTDPDs(tdAct, params);
            tablePDsAct.sinTuned = checkIsTuned(tablePDsAct, params);

            params.window=  windowPas;
            tablePDsPas = getTDPDs(tdPas, params);
            tablePDsPas.sinTuned = checkIsTuned(tablePDsPas, params);
            sinTunedAct = tablePDsAct.sinTuned;
            sinTunedPas = tablePDsPas.sinTuned;

        elseif(isfield(params, 'tablePDsPas'))
            tablePDsPas = params.tablePDsPas{i};
            sinTunedPas = tablePDsPas.sinTuned;
            tablePDsAct = params.tablePDsAct{i};
            sinTunedAct = tablePDsAct.sinTuned;
        else
            sinTunedAct = ones(length(td(1).([params.array, '_spikes'])(1,:)),1);
            sinTunedPas = ones(length(td(1).([params.array, '_spikes'])(1,:)),1);

        end
        params.sinTuned = sinTunedAct | sinTunedPas;
        [fh, outStruct] = getCOActPasStats(td, params);
%         
        processedTrial(i).array = params.array;
        processedTrial(i).date= params.date;
        processedTrial(i).actTrim = params.windowAct;
        processedTrial(i).pasTrim = params.windowPas;
        processedTrial(i).comments = 'Here goes nothing';
        if exist('tablePDsAct')
            processedTrial(i).actPDTable = tablePDsAct;
            processedTrial(i).pasPDTable = tablePDsPas;
        else
            processedTrial(i).actPDTable = repmat({'PDs not computed'}, [length(params.out_signal_names(:,1)),1]);
            processedTrial(i).pasPDTable = repmat({'PDs not computed'}, [length(params.out_signal_names(:,1)),1]);
        end
        processedTrial(i).actPasStats = outStruct;
        processedTrial(i).tuningCurveAct= getTuningCurves(tdAct, params);
        processedTrial(i).tuningCurvePas = getTuningCurves(tdPas,params);
        clear neuronProcessed;
        neuronProcessed.chan = params.out_signal_names(:,1);
        neuronProcessed.unitNum = params.out_signal_names(:,2);
        neuronProcessed.actTuningCurve = processedTrial(i).tuningCurveAct;
        neuronProcessed.pasTuningCurve = processedTrial(i).tuningCurvePas;
        neuronProcessed.actPD = processedTrial(i).actPDTable;
        neuronProcessed.pasPD = processedTrial(i).pasPDTable;
        neuronProcessed.angBump = [processedTrial(i).actPasStats.angBump]';
        neuronProcessed.angMove = [processedTrial(i).actPasStats.angMove]';
        neuronProcessed.tuned = [processedTrial(i).actPasStats.tuned]';
        neuronProcessed.pasActDif = [processedTrial(i).actPasStats.pasActDif]';
        neuronProcessed.dcBump = [processedTrial(i).actPasStats.dcBump]';
        neuronProcessed.dcMove = [processedTrial(i).actPasStats.dcMove]';
        neuronProcessed.firing = [outStruct.firing]';
        neuronProcessed.modDepthMove = [outStruct.modDepthMove]';
        neuronProcessed.modDepthBump = [outStruct.modDepthBump]';
        neuronProcessed.moveTuned = [outStruct.moveTuned]';
        neuronProcessed.bumpTuned = [outStruct.bumpTuned]';
        neuronProcessed.preMove = [outStruct.preMove]';
        neuronProcessed.postMove = [outStruct.postMove]';
        neuronProcessed.sinTunedAct = sinTunedAct;
        neuronProcessed.sinTunedPas = sinTunedPas;
        
        neuronProcessed = struct2table(neuronProcessed);
        arrName.array = repmat({params.array}, [height(neuronProcessed), 1]);
        arrName.date = repmat({params.date},  [height(neuronProcessed), 1]);
        neuronProcessed = [struct2table(arrName), neuronProcessed];
        neuronProcessed1 = [neuronProcessed1; neuronProcessed];
    end
end

