function [processedTrial, neuronProcessed1] = compiledCOActPasAnalysis(td, params)
% compiledCOActPasAnalysis:
%   This function is a compiled analysis pipeline for all days which use
%   the CObump paradigm in an attempt to disentangle the active/passive
%   encoding of arm movements. The various things that are run here are:
%
%   GLMs: This computes a GLM for each neuron as a function of the handle
%   movement direction. These can be used to construct tuning curves,
%   determine sinusoidal tuning etc. This model is fit for all neurons in
%   both the active and the passive windows.
%
%   The majority of the rest of 
% the work is done by computeCOactpasStats,
%   a helper function which does a lot of the other statistical
%   comparisions including:
%       Tuning curves
%       Bump and movement tuning and directional tuning metrics
%       Modulation depths
%       Active/passive directional differences
%       DC firing changes in active and passive
%       Mean and conf int. for firing rates in all directions

%Inputs :
%    td: trial_data format binned at either 10 ms or 50 ms. (the code
%    changes it to 50 ms)
%  
% Outputs:
%   processedTrial: the compiled stats from this td. This is overall neural
%   function stuff
%       Tuning curves
%       Bump and movement tuning and directional tuning metrics
%       Modulation depths
%       Active/passive directional differences
%       DC firing changes in active and passive
%       Mean and conf int. for firing rates in all directions
%       
%   neuronProcessed1: This is simply an easier format to display
%   essentially the same date. This convert the processed trial to change
%   the format so that it is a table which each neuron represented as a
%   row, with columns describing the various stats that correspond to that
%   neuron. The fields of this structure are as follows:
%         monkey : what monkey this came from

%         date   : the date that the neuron was processed

%         array  : the array that the neuron came from

%         chan   : the channel of the array that the neuron came from

%         unitNum : the unitNumber on the channel

%         actTuningCurve : firing rates in each of the 4 directions
%         (active)

%         pasTuningCurve : firing rates in each of the 4
%         directions (passive)

%         actPD : The pop vec. fit preferred direction  (active)

%         pasPD : The pop vec. fit preferred direction (passive)

%         angBump : the PD and the bootstrapped confidence interval
%         (active GLM sinusoidally fit)

%         angMove : the PD and the bootstrapped confidence interval
%         (passive GLM sinusoidally fit)

%         tuned : Checks to see if the neuron is tuned in some way
%         (connfigurable)
%
%         pasActDif: angle between the active/passive GLM computed PDs
%
%         dcBump: Average firing change across all conditions for passive
%         case
%
%         dcMove:  Average firing change across all conditions for active
%         case

%         firing: Mean firing and CIs for all directions

%         modDepthMove: Difference between highest mean firing and lowest
%         mean firind during active

%         modDepthBump: Differences bewteen highest mean firing and lowest
%         mean firing during passive

%        
%         moveTuned : One direction is statistically different than another
%         direction in active movements

%         bumpTuned : One direction is significantly different than another
%         direction in passive movements

%         preMove : Mean firing and CI for time before movement begins

%         postMove : MEan firing and CI for time after movement starts

%         sinTunedAct : Whether the unit is sinusoidally tuned in the
%         active case

%         sinTunedPas : Whetehr the unit is sinusoidally tuned in the
%         passive case

%% Parameter defaults

    includeSpeedTerm = false;
    cutoff = pi/2; %cutoff for significant of sinusoidal tuning
    arrays= {'cuneate'}; %default arrays to look for
    windowAct= []; %Default trimming windows active
    windowPas =[]; % Default trimming windows passive
    windowEncPSTH = {'idx_movement_on', -30;'idx_movement_on', 60};
    distribution = 'poisson'; %what distribution to use in the GLM models
    train_new_model = true; %whether to train new models (can pass in old models in params struct to save time, or don't and it'll run but pass a warning
    neuronProcessed1 = []; %
    monkey  = td(1).monkey;
    %% Assign params
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    array = getArrayName(td);

    tdAct = td(strcmp({td.result},'R'));
    tdAct = tdAct(~isnan([tdAct.idx_movement_on]));
    tdAct= tdAct(isnan([tdAct.idx_bumpTime]));
    
    tdPSTH = trimTD(tdAct, windowEncPSTH(1,:), windowEncPSTH(2,:));
    
    tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
    
    tdBump = td(~isnan([td.bumpDir]) & abs([td.bumpDir]) <361); 
    tdPas = trimTD(tdBump, windowPas(1,:), windowPas(2,:));
    
%% td preprocessing
    if(~isfield(td(1), 'idx_movement_on'))
        td = getMoveOnsetAndPeak(td);
    end
    if(tdAct(1).bin_size == .01)
        tdAct = binTD(tdAct,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end
    if(tdPas(1).bin_size == .01)
        tdPas = binTD(tdPas,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end

    
    
    %% Start the main processing
    for i=1:length(arrays) % iterate through arrays
        params.monkey = td(1).monkey;
        params.array= arrays{i};
        params.date = params.date;
        params.windowAct = windowAct;
        params.windowPas = windowPas;
        params.out_signals = [params.array, '_spikes'];
        params.distribution = distribution;
        params.out_signal_names =td(1).([params.array, '_unit_guide']); 
        params.num_bins = 8;
        params.window = windowAct;
        %% To train new GLM
        if train_new_model
            tablePDsAct = getTDPDsSpeedCorr(tdAct, params);
            tablePDsAct.sinTuned = tablePDsAct.velTuned;

            params.window=  windowPas;
            tablePDsPas = getTDPDsSpeedCorr(tdPas, params);
            tablePDsPas.sinTuned = tablePDsPas.velTuned;
            sinTunedAct = tablePDsAct.sinTuned;
            sinTunedPas = tablePDsPas.sinTuned;
        elseif(isfield(params, 'tablePDsPas'))
            %% if you passed in tablePDsPas and table PDsAct as params
            tablePDsPas = params.tablePDsPas{i};
            sinTunedPas = tablePDsPas.sinTuned;
            tablePDsAct = params.tablePDsAct{i};
            sinTunedAct = tablePDsAct.sinTuned;
        else
            %% or if you want to not train a model, it assumes all are sinusoidally tuned
            sinTunedAct = ones(length(td(1).([params.array, '_spikes'])(1,:)),1);
            sinTunedPas = ones(length(td(1).([params.array, '_spikes'])(1,:)),1);

        end
%         save('tablePDs', 'tablePDsPas', 'tablePDsAct')
        params.sinTuned = sinTunedAct | sinTunedPas;
        [fh, outStruct] = getCOActPasStatsArbDir(td, params);
%         
        processedTrial(i).array = params.array;
        processedTrial(i).date= params.date;
        processedTrial(i).actTrim = params.windowAct;
        processedTrial(i).pasTrim = params.windowPas;
        processedTrial(i).comments = 'Here goes nothing';
  
        if exist('tablePDsAct')
            %% if you have GLM fits, put them in 
            processedTrial(i).actPDTable = tablePDsAct;
            processedTrial(i).pasPDTable = tablePDsPas;
        else
            processedTrial(i).actPDTable = repmat({'PDs not computed'}, [length(params.out_signal_names(:,1)),1]);
            processedTrial(i).pasPDTable = repmat({'PDs not computed'}, [length(params.out_signal_names(:,1)),1]);

        end
        %% Set all fields properly (probably a better way to do this)
        processedTrial(i).actPasStats = outStruct;
        params.num_bins = sum(~isnan(unique([tdAct.target_direction])));
        processedTrial(i).tuningCurveAct= getTuningCurves(tdAct, params);
        params.num_bins = params.num_bins;
        processedTrial(i).tuningCurvePas = getTuningCurves(tdPas,params);
        clear neuronProcessed;
        
        neuronProcessed.chan = params.out_signal_names(:,1);
        if any(contains(fieldnames(td),[params.array, '_naming']))
            mapping = td(1).([params.array,'_naming']);
            for j = 1:length(neuronProcessed.chan)
                neuronProcessed.mapName(j, 1) = mapping(find(mapping(:,1) == neuronProcessed.chan(j)), 2);
            end
        end
        neuronProcessed.ID = params.out_signal_names(:,2);
        %% Iterate through the channels (channel #) and assign electrode # (corresponding to sensory mapping)
        % mapping is an nx2 matrix where n = number of units; the first
        % column corresponds to the channel # (what is in the cds) while
        % the second column is what I see when I do the sensory mapping.
        % The neuronProcessed.chan
        
        neuronProcessed.actWindow = repmat({windowAct}, [length(params.out_signal_names(:,1)),1]);
        neuronProcessed.pasWindow = repmat({windowPas}, [length(params.out_signal_names(:,1)),1]);
        neuronProcessed.unitNum = params.out_signal_names(:,2);
        neuronProcessed.isSorted = neuronProcessed.unitNum >0;
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
        neuronProcessed.fMove = [outStruct.fMove]';
        neuronProcessed.fBump = [outStruct.fBump]';
        neuronProcessed.minPValMove = [outStruct.minPValMove]';
        neuronProcessed.minPValBump = [outStruct.minPValBump]';
        neuronProcessed.firing = [outStruct.firing]';
        neuronProcessed.modDepthMove = [outStruct.modDepthMove]';
        neuronProcessed.modDepthBump = [outStruct.modDepthBump]';
        neuronProcessed.moveTuned = [outStruct.moveTuned]';
        neuronProcessed.bumpTuned = [outStruct.bumpTuned]';
        neuronProcessed.preMove = [outStruct.preMove]';
        neuronProcessed.postMove = [outStruct.postMove]';
        neuronProcessed.sensMove = [outStruct.moveSens]';
        neuronProcessed.sensBump = [outStruct.bumpSens]';
        neuronProcessed.sinTunedAct = sinTunedAct;
        neuronProcessed.sinTunedPas = sinTunedPas;
        

        neuronProcessed = struct2table(neuronProcessed);
        arrName.array = repmat({params.array}, [height(neuronProcessed), 1]);
        arrName.date = repmat({params.date},  [height(neuronProcessed), 1]);
        arrName.monkey = repmat({td(1).monkey}, [height(neuronProcessed),1]);
        arrName.task = repmat({td(1).task}, [height(neuronProcessed),1]);
        neuronProcessed = [struct2table(arrName), neuronProcessed];
        neuronProcessed1 = [neuronProcessed1; neuronProcessed];
    end
    [sinTunedAct, sinTunedPas] = checkIsTuned(neuronProcessed1, cutoff);
    neuronProcessed1.sinTunedAct = sinTunedAct;
    neuronProcessed1.sinTunedPas = sinTunedPas;
end

