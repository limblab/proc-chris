function [ neuronProcessed1] = compiledRWAnalysis(td, params)
%UNTITLED Summary of this function goes here
%   Detailed explanation
    cutoff = pi/4;
    arrays= {'RightCuneate', 'LeftS1'};
    
    windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
    windowPas ={'idx_trial_start',0; 'idx_movement_on',0};
    
    distribution = 'normal';
    train_new_model = true;
    neuronProcessed1 = [];
    
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    
    [tdIdx,td] = getTDidx(td, 'result', 'R');
    
    if(td(1).bin_size == .01)
        td1 = binTD(td,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end
    td1 = removeBadTrials(td1);
    if(~isfield(td1(1), 'idx_movement_on'))
        td1 = getMoveOnsetAndPeak(td1);
    end
    





    td1 = removeBadNeurons(td1);
    td1 = getRWMovements(td1, params);
    tdBin = removeBadTrials(td1);
    
    tdAct = trimTD(tdBin, windowAct(1,:), windowAct(2,:));
    
    tdPas = trimTD(tdBin, windowPas(1,:), windowPas(2,:));
    
    params.cutoff = cutoff;
    for i=1:length(arrays)
        params.array= arrays{i};
        params.out_signals = [params.array, '_spikes'];
        params.distribution = distribution;
        params.out_signal_names =td(1).([params.array, '_unit_guide']); 
        params.num_bins = 4;
        params.window = windowAct;
        if train_new_model

          
            tablePDsAct = getTDPDs(tdAct, params);
            tablePDsAct.sinTuned = checkIsTuned(tablePDsAct, params);
            sinTunedAct = tablePDsAct.sinTuned;


        elseif(isfield(params, 'tablePDsAct'))
            tablePDsAct = params.tablePDsAct{i};
            sinTunedAct = tablePDsAct.sinTuned;
        else
            sinTunedAct = ones(length(td(1).([params.array, '_spikes'])(1,:)),1);
            sinTunedPas = ones(length(td(1).([params.array, '_spikes'])(1,:)),1);

        end
        params.sinTuned = sinTunedAct;
%         
        processedTrial(i).array = params.array;
        processedTrial(i).date= params.date;
        processedTrial(i).actTrim = params.windowAct;
        processedTrial(i).pasTrim = params.windowPas;
        processedTrial(i).comments = 'Here goes nothing';
        if exist('tablePDsAct')
            processedTrial(i).actPDTable = tablePDsAct;
        else
            processedTrial(i).actPDTable = 'PDs not computed';
        end
        
        clear neuronProcessed;
        processedTrial(i).tuningCurveAct= getTuningCurves(tdAct, params);
        neuronProcessed.chan = params.out_signal_names(:,1);
        neuronProcessed.unitNum = params.out_signal_names(:,2);
        neuronProcessed.actTuningCurve = processedTrial(i).tuningCurveAct;
        neuronProcessed.actPD = processedTrial(i).actPDTable;
        neuronProcessed.sinTunedAct = processedTrial(i).actPDTable.sinTuned;
        
        neuronProcessed = struct2table(neuronProcessed);
        arrName.array = repmat({params.array}, [height(neuronProcessed), 1]);
        arrName.date = repmat({params.date},  [height(neuronProcessed), 1]);
        neuronProcessed = [struct2table(arrName), neuronProcessed];
        neuronProcessed1 = [neuronProcessed1; neuronProcessed];
    end
end