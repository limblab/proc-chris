function processedTrial = compiledCOActPasAnalysis(td, params)
%UNTITLED Summary of this function goes here
%   Detailed explanation
    cutoff = pi/4;
    arrays= {'RightCuneate', 'LeftS1'};
    windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
    windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
    distribution = 'normal';
    train_new_model = true;
    cuneate_flag = true;
    
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
        params.out_signals = [params.array, '_spikes'];
        params.distribution = distribution;
        params.out_signal_names =td(1).([params.array, '_unit_guide']); 
        params.num_bins = 4;
        params.window = windowAct;
        if train_new_model

          
            tablePDsAct = getTDPDs(tdAct, params);
            tablePDsAct.sinTuned = isTuned(tablePDsAct.velPD, tablePDsAct.velPDCI, cutoff)';

            params.window=  windowPas;
            tablePDsPas = getTDPDs(tdPas, params);
            tablePDsPas.sinTuned = isTuned(tablePDsPas.velPD, tablePDsPas.velPDCI, cutoff)';
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
            processedTrial(i).actPDTable = 'PDs not computed';
            processedTrial(i).pasPDTable = 'PDs not computed';
        end
        processedTrial(i).actPasStats = outStruct;
        processedTrial(i).tuningCurveAct= getTuningCurves(tdAct, params);
        processedTrial(i).tuningCurvePas = getTuningCurves(tdPas,params);
    end
    
end

