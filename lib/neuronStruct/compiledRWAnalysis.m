function [processedTrial, neuronProcessed1] = compiledRWAnalysis(td, params)
% compiledCOActPasAnalysis:
%   This function is a compiled analysis pipeline for all days which use
%   the RW paradigm. The various things that are run here are:
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
%       Modulation depths
%       Mean and conf int. for firing rates in all directions

%Inputs :
%    td: trial_data format binned at either 10 ms or 50 ms. (the code
%    changes it to 50 ms)
%  
% Outputs:
%   processedTrial: the compiled stats from this td. This is overall neural
%   function stuff
%       Tuning curves
%       Modulation depths
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

%         tuningCurve : firing rates in each of the 4 directions
%         (active)

%         PD : The pop vec. fit preferred direction  (active)

%         tuned : Checks to see if the neuron is tuned in some way
%         (connfigurable)
%
%

%         firing: Mean firing and CIs for all directions

%         modDepth: Difference between highest mean firing and lowest
%         mean firind during active

%% Parameter defaults

    
    cutoff = pi/4; %cutoff for significant of sinusoidal tuning
    arrays= {'cuneate'}; %default arrays to look for
    windowAct= {'idx_movement_on', 0; 'idx_movement_on',5}; %Default trimming windows active
    distribution = 'normal'; %what distribution to use in the GLM models
    train_new_model = true; %whether to train new models (can pass in old models in params struct to save time, or don't and it'll run but pass a warning
    neuronProcessed1 = []; %
    monkey  = td(1).monkey;
    doTrim = false;
    %% Assign params
    if nargin > 1, assignParams(who,params); end % overwrite parameters
%% td preprocessing
    if(~isfield(td(1), 'idx_movement_on'))
        td = getMoveOnsetAndPeak(td);
    end
    if(td(1).bin_size == .01)
        tdBin = binTD(td,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end
    if doTrim
        tdAct = tdBin(strcmp({tdBin.result},'R'));
        tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
    else
        tdAct = tdBin;
    end
    params.arrays = arrays;
    %% Start the main processing
    for i=1:length(arrays) % iterate through arrays
        params.monkey = td(1).monkey;
        params.array= arrays{i};
        params.date = td(1).date;
        params.windowAct = windowAct;
        params.in_signals = 'vel';
        params.out_signals = [params.array, '_spikes'];
        params.distribution = distribution;
        params.out_signal_names =td(1).([params.array, '_unit_guide']); 
        params.num_bins = 8;
        params.window = windowAct;
        %% To train new GLM
        if train_new_model
            tablePDs = getTDPDs(tdAct, params);
            tablePDs.sinTuned = tablePDs.([params.in_signals, 'Tuned']);
            sinTuned = tablePDs.sinTuned;
        elseif(isfield(params, 'tablePDsPas'))
            %% if you passed in tablePDsPas and table PDsAct as params
            tablePDs = params.tablePDsAct{i};
            sinTuned = tablePDs.sinTuned;
        else
            %% or if you want to not train a model, it assumes all are sinusoidally tuned
            sinTuned = ones(length(td(1).([params.array, '_spikes'])(1,:)),1);

        end
        params.sinTuned = sinTuned;
%         
        processedTrial(i).array = params.array;
        processedTrial(i).date= params.date;
        processedTrial(i).actTrim = params.windowAct;
        processedTrial(i).comments = 'Here goes nothing';
  
        if exist('tablePDsAct')
            %% if you have GLM fits, put them in 
            processedTrial(i).actPDTable = tablePDs;
        else
            processedTrial(i).actPDTable = repmat({'PDs not computed'}, [length(params.out_signal_names(:,1)),1]);
            processedTrial(i).pasPDTable = repmat({'PDs not computed'}, [length(params.out_signal_names(:,1)),1]);

        end
        %% Set all fields properly (probably a better way to do this)
        processedTrial(i).tuningCurve= getTuningCurves(tdAct, params);
        mapping = td(1).([params.array,'_naming']);
        clear neuronProcessed;
        neuronProcessed.chan = params.out_signal_names(:,1);
        neuronProcessed.ID = params.out_signal_names(:,2);
        %% Iterate through the channels (channel #) and assign electrode # (corresponding to sensory mapping)
        % mapping is an nx2 matrix where n = number of units; the first
        % column corresponds to the channel # (what is in the cds) while
        % the second column is what I see when I do the sensory mapping.
        % The neuronProcessed.chan
        for j = 1:length(neuronProcessed.chan)
            neuronProcessed.mapName(j, 1) = mapping(find(mapping(:,1) == neuronProcessed.chan(j)), 2);
        end
        neuronProcessed.actWindow = repmat({windowAct}, [length(params.out_signal_names(:,1)),1]);
        neuronProcessed.unitNum = params.out_signal_names(:,2);
        neuronProcessed.isSorted = neuronProcessed.unitNum >0;
        neuronProcessed.isTuned = tablePDs.sinTuned;
        neuronProcessed.tuningCurve = processedTrial(i).tuningCurve;
        neuronProcessed.modDepth = tablePDs.([params.in_signals, 'Moddepth']);
        neuronProcessed.PD = tablePDs;

        neuronProcessed = struct2table(neuronProcessed);
        arrName.array = repmat({params.array}, [height(neuronProcessed), 1]);
        arrName.date = repmat({params.date},  [height(neuronProcessed), 1]);
        arrName.monkey = repmat({td(1).monkey}, [height(neuronProcessed),1]);
        arrName.task = repmat({td(1).task}, [height(neuronProcessed),1]);
        neuronProcessed = [struct2table(arrName), neuronProcessed];
        neuronProcessed1 = [neuronProcessed1; neuronProcessed];
    end
end

