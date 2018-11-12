function [fh, outStruct, neurons] = getCOActPasStats(td,params)
  % getCOActPasStats
%   This function is a compiled analysis pipeline for all days which use
%   the CObump paradigm in an attempt to disentangle the active/passive
%   encoding of arm movements. The various things that are run here are:
%
%  This function computes a bunch of stuff, including:
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
%    params: struct can optionally contain fields:
%       beforeBump : time in seconds to use before the bump
%       afterBump : time in seconds to use after the bump
%       beforeMove : time in seconds to use before movement
%       afterMove : time in seconds to use after movement
%       date : date (string)
%       array : array(string)
%       histogramFlag : whether to make firing rate histogram plots
%       circleFlag : whether to make tuning circle plots
%       plotFlag : whether to make population plots
%       saveFig  : whether to save figures
%       numBoots : how many bootstrap iterations to do (1000 default)
%       conf : what the confidence interval to use is (.95 default)
%       sinTuned : if you want to do the plotting with only sinusoidally
%       tuned units, this gives you a method to only plot them.
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
%% Parameters and preprocessing
    beforeBump = .3;
    afterBump = .3;
    beforeMove = .3;
    afterMove = .3;
    
    date= [];
    array= 'cuneate';
    monkey1 = td(1).monkey;
    histogramFlag= false;
    circleFlag = true;
    plotFlag = true;
    saveFig =true;

    if(exist('params') && ~isfield(params,'sinTuned'))
        warning('No sinusoidal tuning provided, assuming all are tuned')
    end
    
    if (td(1).bin_size ~= .01), error('Bad bin size, has to be 10 ms wide');end
        

    numBoots = 1000;
    conf = .95;
    sinTuned = ones(length(td(1).([params.array, '_unit_guide'])(:,1)),1);
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    if isempty(date)
        error('Need to input date') 
    end
    %% Computing helpful temp variables
    unitLabel = array;
    unitGuide = [unitLabel, '_unit_guide'];
    unitSpikes = [unitLabel, '_spikes'];
    spikeLabel = [unitLabel, '_spikes'];
    params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
    params.extra_time = [.4,.6];
    td = td(~isnan([td.target_direction]));
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeak(td, params);

    bumpTrials = td(~isnan([td.bumpDir])); 
    upMove = td([td.target_direction] == pi/2 & isnan([td.bumpDir]));
    leftMove = td([td.target_direction] ==pi& isnan([td.bumpDir]));
    downMove = td([td.target_direction] ==3*pi/2& isnan([td.bumpDir]));
    rightMove = td([td.target_direction]==0& isnan([td.bumpDir]));
    
    upBump = bumpTrials([bumpTrials.bumpDir] == 90);
    downBump = bumpTrials([bumpTrials.bumpDir] == 270);
    leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
    rightBump = bumpTrials([bumpTrials.bumpDir] == 0);
    
    timeVec = linspace(-1*beforeBump, afterBump, length(upMove(1).idx_movement_on-(beforeMove*100):upMove(1).idx_movement_on+(afterMove*100)));
    %% Compute firing for plots around bump start and movement onset
   for num1 = 1:length(td(1).(spikeLabel)(1,:))
       upMoveFiring = zeros(length(upMove), length(timeVec));
       for  i = 1:length(upMove)
            upMoveFiring(i,:) = upMove(i).(spikeLabel)(upMove(i).idx_movement_on-(beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),num1);
       end
       upBumpFiring = zeros(length(upBump), length(timeVec));
        for  i = 1:length(upBump)
            upBumpFiring(i,:) = upBump(i).(spikeLabel)(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),num1);
        end
       
       downMoveFiring = zeros(length(downMove), length(timeVec));
       for  i = 1:length(downMove)
            downMoveFiring(i,:) = downMove(i).(spikeLabel)(downMove(i).idx_movement_on-(beforeMove*100):downMove(i).idx_movement_on+(afterMove*100),num1);
        end
       downBumpFiring = zeros(length(downBump), length(timeVec));
        for  i = 1:length(downBump)
            downBumpFiring(i,:) = downBump(i).(spikeLabel)(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),num1);
        end
       
        
       leftMoveFiring = zeros(length(leftMove), length(timeVec));
        for  i = 1:length(leftMove)
            leftMoveFiring(i,:) = leftMove(i).(spikeLabel)(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),num1);
        end
       leftBumpFiring = zeros(length(leftBump), length(timeVec));
        for  i = 1:length(leftBump)
            leftBumpFiring(i,:) = leftBump(i).(spikeLabel)(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),num1);
        end
        
        
       rightBumpFiring = zeros(length(rightBump), length(timeVec));
        for  i = 1:length(rightBump)
            rightBumpFiring(i,:) = rightBump(i).(spikeLabel)(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),num1);
        end
        rightMoveFiring = zeros(length(rightMove), length(timeVec));
        for  i = 1:length(rightMove)
            rightMoveFiring(i,:) = rightMove(i).(spikeLabel)(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),num1);
        end
%% Compute firing rate in window 100 ms after bump onset
       shortRightBumpFiring{num1} = rightBumpFiring(:, beforeBump*100:beforeBump*100+10);
       shortLeftBumpFiring{num1} = leftBumpFiring(:, beforeBump*100:beforeBump*100+10);
       shortUpBumpFiring{num1} = upBumpFiring(:, beforeBump*100:beforeBump*100+10);
       shortDownBumpFiring{num1} = downBumpFiring(:, beforeBump*100:beforeBump*100+10);
%% Compute firing rate in window 100 ms after movement onset
       shortRightMoveFiring{num1} = rightMoveFiring(:, beforeMove*100:beforeMove*100+10);
       shortLeftMoveFiring{num1} = leftMoveFiring(:, beforeMove*100:beforeMove*100+10);
       shortUpMoveFiring{num1} = upMoveFiring(:, beforeMove*100:beforeMove*100+10);
       shortDownMoveFiring{num1} = downMoveFiring(:, beforeMove*100:beforeMove*100+10);
%% Compute general prebump and pre-movement firing rates
       preBumpFiring{num1} = [rightBumpFiring(:, beforeBump*50:beforeBump*100); leftBumpFiring(:, beforeBump*50:beforeBump*100);...
           upBumpFiring(:,beforeBump*50:beforeBump*100); downBumpFiring(:,beforeBump*50:beforeBump*100)];
       preMoveFiring{num1} = [rightMoveFiring(:, 1:beforeMove*50); leftMoveFiring(:, 1:beforeMove*50);...
       upMoveFiring(:,1:beforeMove*50); downMoveFiring(:,1:beforeMove*50)];
   
   end
   
           

   

   sigDif = zeros(length(shortLeftBumpFiring),1);
for i = 1:length(shortLeftBumpFiring)
    %% compute bootstrapped confidence interval for bumps
    postBumpFiring{i} = [shortRightBumpFiring{i}; shortLeftBumpFiring{i}; shortUpBumpFiring{i}; shortDownBumpFiring{i}];
    [meanRightBump, botRightBump, topRightBump,bootstatRightBump] = bootstrpFiringRates(shortRightBumpFiring{i},numBoots, conf);
    [meanLeftBump, botLeftBump, topLeftBump, bootstatLeftBump] = bootstrpFiringRates(shortLeftBumpFiring{i},numBoots, conf);
    [meanUpBump, botUpBump, topUpBump, bootstatUpBump] = bootstrpFiringRates(shortUpBumpFiring{i},numBoots, conf);
    [meanDownBump, botDownBump, topDownBump, bootstatDownBump] = bootstrpFiringRates(shortDownBumpFiring{i},numBoots, conf);
    [meanPreBump(i), botPreBump(i), topPreBump(i), bootstatPreBump] = bootstrpFiringRates(preBumpFiring{i},numBoots,conf);
    [meanPostBump(i), botPostBump(i), topPostBump(i), bootstatPostBump] = bootstrpFiringRates(postBumpFiring{i}, numBoots, conf);
    dcBump(i) = meanPostBump(i) - meanPreBump(i);
    %% compute significance etc.
    bumpTuned(i) = meanDownBump > topPreBump(i) | meanUpBump > topPreBump(i) | meanRightBump > topPreBump(i)| meanLeftBump > topPreBump(i) |...
        meanDownBump < botPreBump(i) | meanUpBump< botPreBump(i) | meanRightBump< botPreBump(i) | meanLeftBump < botPreBump(i);
    rightSigBump(i) = topRightBump<meanLeftBump | topRightBump<meanUpBump | topRightBump<meanDownBump | botRightBump > meanLeftBump | botRightBump >meanUpBump | botRightBump > meanDownBump;
    leftSigBump(i) = topLeftBump<meanRightBump | topLeftBump<meanUpBump | topLeftBump<meanDownBump | botLeftBump > meanRightBump | botLeftBump >meanUpBump | botLeftBump > meanDownBump;
    upSigBump(i) = topUpBump<meanRightBump | topUpBump<meanLeftBump | topUpBump<meanDownBump | botUpBump > meanRightBump | botUpBump >meanLeftBump | botUpBump > meanDownBump;
    downSigBump(i) = topDownBump<meanRightBump | topDownBump<meanUpBump | topDownBump<meanLeftBump | botDownBump > meanRightBump | botDownBump >meanUpBump | botDownBump > meanLeftBump;
    
    sigDifBump(i) = rightSigBump(i) | leftSigBump(i) | upSigBump(i) | downSigBump(i);
    

%     figure
%     histogram(bootstatPreMove)
%     hold on
%     histogram(bootstatPostMove)
%     histogram(bootstatPreBump)
%     histogram(bootstatPostBump)
%     legend('show')
%% compute confidence intervals for active movements
    postMoveFiring{i} = [shortRightMoveFiring{i}; shortLeftMoveFiring{i}; shortUpMoveFiring{i}; shortDownMoveFiring{i}];
    [meanRightMove, botRightMove, topRightMove,bootstatRightMove] = bootstrpFiringRates(shortRightMoveFiring{i},numBoots, conf);
    [meanLeftMove, botLeftMove, topLeftMove, bootstatLeftMove] = bootstrpFiringRates(shortLeftMoveFiring{i},numBoots, conf);
    [meanUpMove, botUpMove, topUpMove, bootstatUpMove] = bootstrpFiringRates(shortUpMoveFiring{i},numBoots, conf);
    [meanDownMove, botDownMove, topDownMove, bootstatDownMove] = bootstrpFiringRates(shortDownMoveFiring{i},numBoots, conf);
    [meanPreMove(i), botPreMove(i), topPreMove(i), bootstatPreMove] = bootstrpFiringRates(preMoveFiring{i},numBoots,conf);
    [meanPostMove(i), botPostMove(i), topPostMove(i), bootstatPostMove] = bootstrpFiringRates(postMoveFiring{i}, numBoots, .99);
    dcMove(i) = meanPostMove(i) - meanPreMove(i);
    modDepthMove(i) = max([meanUpMove, meanDownMove, meanLeftMove, meanRightMove]) - min([meanUpMove, meanDownMove, meanLeftMove, meanRightMove]);
    modDepthBump(i) = max([meanUpBump, meanDownBump, meanLeftBump, meanRightBump]) - min([meanUpBump, meanDownBump, meanLeftBump, meanRightBump]);

    %% compute significance for active movements
    rightMoveSig(i) = topRightMove<meanLeftMove | topRightMove<meanUpMove | topRightMove<meanDownMove | botRightMove > meanLeftMove | botRightMove >meanUpMove | botRightMove > meanDownMove;
    leftMoveSig(i) = topLeftMove<meanRightMove | topLeftMove<meanUpMove | topLeftMove<meanDownMove | botLeftMove > meanRightMove | botLeftMove >meanUpMove | botLeftMove > meanDownMove;
    upMoveSig(i) = topUpMove<meanRightMove | topUpMove<meanLeftMove | topUpMove<meanDownMove | botUpMove > meanRightMove | botUpMove >meanLeftMove | botUpMove > meanDownMove;
    downMoveSig(i) = topDownMove<meanRightMove | topDownMove<meanUpMove | topDownMove<meanLeftMove | botDownMove > meanRightMove | botDownMove >meanUpMove | botDownMove > meanLeftMove;
    moveTuned(i) = meanDownMove > topPreMove(i) | meanUpMove > topPreMove(i) | meanRightMove > topPreMove(i)| meanLeftMove > topPreMove(i) |...
    meanDownMove < botPreMove(i) | meanUpMove< botPreMove(i) | meanRightMove< botPreMove(i) | meanLeftMove < botPreMove(i);

    sigDifMove(i) = rightMoveSig(i) | leftMoveSig(i) | upMoveSig(i) | downMoveSig(i);
    %
%% Compute population vector PD and bootstrapped confidence interval
    upVec = [0, 1];
    downVec = [0,-1];
    rightVec = [1,0];
    leftVec = [-1, 0];
    
    pdVecMove(i,:) =  meanDownMove*downVec + meanUpMove*upVec + meanRightMove*rightVec + meanLeftMove*leftVec;
    pdVecBump(i,:) = meanDownBump*downVec + meanUpBump*upVec + meanRightBump*rightVec + meanLeftBump*leftVec;
    
    pdVecMoveBoot{i} = bootstatDownMove*downVec + bootstatUpMove*upVec + bootstatRightMove*rightVec + bootstatLeftMove*leftVec;
    pdVecBumpBoot{i} = bootstatDownBump*downVec + bootstatUpBump*upVec + bootstatRightBump*rightVec + bootstatLeftBump*leftVec;
    angBump(i) = atan2(pdVecBump(i, 2), pdVecBump(i,1));
    magBump(i) = norm(pdVecBump(i,:));
    angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
    bootPDAngMove{i} = angleDiff(atan2(pdVecMoveBoot{i}(:,2), pdVecMoveBoot{i}(:,1)), angMove(i), true, true);
    bootPDMagMove{i} = rownorm(pdVecMoveBoot{i});
    angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
    
    bootPDAngBump{i} = angleDiff(atan2(pdVecBumpBoot{i}(:,2), pdVecBumpBoot{i}(:,1)), angBump(i), true, true);
    bootPDMagBump{i} = rownorm(pdVecBumpBoot{i});
 
    
    sortedAngBump = sort(bootPDAngBump{i});
    lowAngBump(i) = sortedAngBump(50)+ angBump(i);
    highAngBump(i) = sortedAngBump(950) + angBump(i);
    
    sortedAngMove = sort(bootPDAngMove{i});
    lowAngMove(i) = sortedAngMove(50) +angMove(i);
    highAngMove(i) = sortedAngMove(950)+ angMove(i);

    %% General sanity checks and removing units I know to not be cuneate
    goodFiring(i) = meanDownMove>0 & meanUpMove >0 & meanRightMove >0 & meanLeftMove >0 & meanDownBump >0 & meanUpBump >0 & meanRightBump>0 & meanLeftBump >0;
    
    if strcmp(array, 'cuneate') | strcmp(array, 'RightCuneate')
%         trueCuneate = getTrueCuneate(td, params);
        tuned(i) = sigDifMove(i) & sigDifBump(i) & goodFiring(i)& sinTuned(i);% & trueCuneate(i);%&sinTunedMove(i) & sinTunedBump(i);
    else
        tuned(i) = sigDifMove(i) & sigDifBump(i) & goodFiring(i)& sinTuned(i) ;%&sinTunedMove(i) & sinTunedBump(i);

    end
    mkdir([getBasicPath(td(1).monkey, dateToLabDate(date), getGenericTask(td(1).task)),'plotting', filesep,'NeuronPlots',filesep]);
    title1 = [getBasicPath(td(1).monkey, dateToLabDate(date), getGenericTask(td(1).task)),'plotting', filesep,'NeuronPlots',filesep, array,'_',td(1).monkey,'_Electrode_',date, '_', num2str(td(1).(unitGuide)(i,1)), ' Unit ', num2str(td(1).(unitGuide)(i,2))];
    title2 = [array,'_',td(1).monkey,'_Electrode_',date, '_', num2str(td(1).(unitGuide)(i,1)), ' Unit ', num2str(td(1).(unitGuide)(i,2))];
    
    if tuned(i)
        title1 = [title1, '_TUNED'];
        title2 = [title2, '_TUNED'];
    end
    %% Histogram plotting
    if histogramFlag & tuned(i)

        f1 = figure('Position', [100, 100, 1200, 800]);
        sp1 = subplot(2,1,1);
        histogram(bootstatRightBump)
        hold on
        histogram(bootstatLeftBump)
        histogram(bootstatUpBump)
        histogram(bootstatDownBump)
        histogram(bootstatPreBump)
        title([strrep(title2, '_', ' '), ' Bump Tuning'])
        xlabel('Firing')
        legend('show')

        sp2= subplot(2,1,2);
        histogram(bootstatRightMove)
        hold on
        histogram(bootstatLeftMove)
        histogram(bootstatUpMove)
        histogram(bootstatDownMove)
        histogram(bootstatPreMove)
        title([strrep(title2, '_', ' '), ' Move Tuning'])
        xlabel('Firing')
        legend('show')

        linkaxes([sp1, sp2]);
        figTitle = [title1, 'Histogram.pdf'];
        if(saveFig)
            saveas(f1,strrep(figTitle, ' ', '_'));
        end
    end
    %% circle plotting
    if circleFlag & tuned(i)
        theta = [0, pi/2, pi, 3*pi/2, 0];
        bumpMean = [meanRightBump, meanUpBump, meanLeftBump, meanDownBump, meanRightBump];
        bumpHigh = [topRightBump , topUpBump, topLeftBump, topDownBump, topRightBump];
        bumpLow = [botRightBump, botUpBump, botLeftBump, botDownBump, botRightBump];

        moveMean = [meanRightMove, meanUpMove, meanLeftMove, meanDownMove, meanRightMove];
        moveHigh = [topRightMove , topUpMove, topLeftMove, topDownMove, topRightMove];
        moveLow = [botRightMove, botUpMove, botLeftMove, botDownMove, botRightMove]; 

        f2 = figure('Position', [100, 0, 600, 600]); 
        polarplot(theta, bumpHigh, 'Color', [1,.4,.4], 'LineWidth', 2)
        hold on 
        polarplot(theta, bumpMean, 'Color', [1,0,0], 'LineWidth', 2)
        polarplot(theta, bumpLow, 'Color', [1,.4,.4], 'LineWidth', 2)

        polarplot([angBump(i), angBump(i)], [0, magBump(i)],'Color', [1,0,0], 'LineWidth', 2);
        polarplot([lowAngBump(i), lowAngBump(i)], [0, magBump(i)],'Color', [1, .4,.4], 'LineWidth', 2);
        polarplot([highAngBump(i), highAngBump(i)], [0, magBump(i)],'Color', [1, .4,.4], 'LineWidth', 2);
        title('Bump')
        
        polarplot(theta, moveHigh, 'Color', [.4,.4,1], 'LineWidth', 2)
        polarplot(theta, moveMean, 'Color', [0,0,1], 'LineWidth', 2)
        polarplot(theta, moveLow, 'Color', [.4,.4,1], 'LineWidth', 2)
        
        angMove(i) = atan2(pdVecMove(i,2), pdVecMove(i,1));
        magMove(i) = norm(pdVecMove(i,:));
        polarplot([angMove(i), angMove(i)], [0, magMove(i)],'Color', [0 0 1 ], 'LineWidth', 2);
        polarplot([lowAngMove(i), lowAngMove(i)], [0, magMove(i)],'Color', [.4 .4 1], 'LineWidth', 2);
        polarplot([highAngMove(i), highAngMove(i)], [0, magMove(i)],'Color', [.4 .4 1], 'LineWidth', 2);
        
        title([strrep(title2, '_', ' '), ' Tuning Curves'])
        legend('show')
        figTitle = [title1, 'TuningCurve.pdf'];
        if(saveFig)
            saveas(f2, strrep(figTitle, ' ', '_'));
        end
    end
    close all
%% Generate output structure
outStruct(i).angBump.high = highAngBump(i);
outStruct(i).angBump.low = lowAngBump(i);
outStruct(i).angBump.mean = angBump(i);

outStruct(i).angMove.high = highAngMove(i);
outStruct(i).angMove.low = lowAngMove(i);
outStruct(i).angMove.mean = angMove(i);

outStruct(i).moveTuned= sigDifMove(i);
outStruct(i).bumpTuned = sigDifBump(i);
outStruct(i).preMove.mean = meanPreMove(i);
outStruct(i).preMove.high = topPreMove(i);
outStruct(i).preMove.low = botPreMove(i);

outStruct(i).postMove.mean = meanPostMove(i);
outStruct(i).postMove.high = topPostMove(i);
outStruct(i).postMove.low = botPostMove(i);

%%
outStruct(i).firing.bump.left.mean = meanLeftBump;
outStruct(i).firing.bump.left.high = topLeftBump;
outStruct(i).firing.bump.left.low= botLeftBump;
outStruct(i).firing.bump.left.all = shortLeftBumpFiring{i};

outStruct(i).firing.bump.right.mean = meanRightBump;
outStruct(i).firing.bump.right.high = topRightBump;
outStruct(i).firing.bump.right.low = botRightBump;
outStruct(i).firing.bump.right.all = shortRightBumpFiring{i};

outStruct(i).firing.bump.up.mean = meanUpBump;
outStruct(i).firing.bump.up.high = topUpBump;
outStruct(i).firing.bump.up.low = botUpBump;
outStruct(i).firing.bump.up.all = shortUpBumpFiring{i};


outStruct(i).firing.bump.down.mean = meanDownBump;
outStruct(i).firing.bump.down.high = topDownBump;
outStruct(i).firing.bump.down.low = botDownBump;
outStruct(i).firing.bump.down.all = shortDownBumpFiring{i};


%%

outStruct(i).firing.move.left.mean = meanLeftMove;
outStruct(i).firing.move.left.high = topLeftMove;
outStruct(i).firing.move.left.low= botLeftMove;
outStruct(i).firing.move.left.all = shortLeftMoveFiring{i};


outStruct(i).firing.move.right.mean = meanRightMove;
outStruct(i).firing.move.right.high = topRightMove;
outStruct(i).firing.move.right.low = botRightMove;
outStruct(i).firing.move.right.all = shortRightMoveFiring{i};


outStruct(i).firing.move.up.mean = meanUpMove;
outStruct(i).firing.move.up.high = topUpMove;
outStruct(i).firing.move.up.low = botUpMove;
outStruct(i).firing.move.up.all = shortUpMoveFiring{i};


outStruct(i).firing.move.down.mean = meanDownMove;
outStruct(i).firing.move.down.high = topDownMove;
outStruct(i).firing.move.down.low = botDownMove;
outStruct(i).firing.move.down.all = shortDownMoveFiring{i};

%%
outStruct(i).monkey = monkey1;
outStruct(i).date = date;
outStruct(i).array = array;


pasActDif = angleDiff(angBump(i), angMove(i));

outStruct(i).pasActDif = pasActDif;
outStruct(i).numPasDif = sum(sigDifBump(i));
outStruct(i).numActDif = sum(sigDifMove(i));


outStruct(i).dcBump = dcBump(i);
outStruct(i).dcMove= dcMove(i);

outStruct(i).modDepthMove=modDepthMove(i);
outStruct(i).modDepthBump = modDepthBump(i);

outStruct(i).tuned= tuned(i);
end
%% If I want to plot stuff


if plotFlag
    coActPasPlotting(outStruct);
end
fh=[];
end

