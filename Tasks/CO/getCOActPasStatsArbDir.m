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
    beforeBump = 0;
    afterBump = 13;
    beforeMove = 0;
    afterMove = 13;
    
    date= params.date;
    array= getTDfields(td, 'arrays');
    array = array{1};
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
    sinTuned = ones(length(td(1).([array, '_unit_guide'])(:,1)),1);
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    if isempty(date)
        error('Need to input date') 
    end
    %% Computing helpful temp variables
    unitLabel = array;
    unitGuide = [unitLabel, '_unit_guide'];
    spikeLabel = [unitLabel, '_spikes'];
    
    
    dirsM = unique([td.target_direction]);
    dirsM = dirsM(~isnan(dirsM));
    td = td(~isnan([td.idx_movement_on]));
    preMove = trimTD(td, {'idx_movement_on', -10}, {'idx_movement_on', -5});
    postMove = trimTD(td, {'idx_movement_on', beforeMove}, {'idx_movement_on',afterMove});
    preMoveFiring = cat(3, preMove.(spikeLabel)).*100;
    
    preMoveStat.meanCI(:,1) = squeeze(mean(mean(preMoveFiring, 3),1))';
    preMoveStat.meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(preMoveFiring))')';

    
    for i = 1:length(dirsM)
        postMoveDir{i} = postMove([postMove.target_direction] == dirsM(i));
        postMoveFiring{i} = cat(3, postMoveDir{i}.(spikeLabel))*100;
        postMoveStat(i).meanCI(:,1) = squeeze(mean(mean(postMoveFiring{i}, 3),1))';
        postMoveStat(i).meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(postMoveFiring{i}))')';

    end
    
    tdBump = td(~isnan([td.bumpDir]));
    dirsBump = unique([td.bumpDir]);
    dirsBump = dirsBump(~isnan(dirsBump));
    
    dirsBump = dirsBump(abs(dirsBump)<361);
    preBump = trimTD(tdBump, {'idx_bumpTime', -10}, {'idx_bumpTime', -5});

    postBump = trimTD(tdBump, {'idx_bumpTime', beforeBump}, {'idx_bumpTime', afterBump});
    for i = 1:length(dirsBump)
        postBumpDir{i}= postBump([postBump.bumpDir] == dirsBump(i));
        postBumpFiring{i} = cat(3, postBumpDir{i}.(spikeLabel)).*100;
        postBumpStat(i).meanCI(:,1) = squeeze(mean(mean(postBumpFiring{i}, 3),1))';
        postBumpStat(i).meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(postBumpFiring{i}))')';

    end
    preBumpFiring = cat(3, preBump.(spikeLabel)).*100;
    
    preBumpStat.meanCI(:,1) = squeeze(mean(mean(preBumpFiring, 3),1))';
    preBumpStat.meanCI(:,2:3) = bootci(100, @mean, squeeze(mean(preBumpFiring))')';

    
    timeVec = linspace(-.01*beforeBump, .01*afterBump, length(postMove(1).pos(:,1)));
    %% Compute firing for plots around bump start and movement onset
    t = cat(3, postMoveStat.meanCI);
    bumpTot = cat(3, postBumpStat.meanCI);
    moveTot = cat(3, postMoveStat.meanCI);
    bumpPre = cat(2, preBumpStat.meanCI);
    movePre = cat(2, preMoveStat.meanCI);
    theta = linspace(0, max(dirsM), length(dirsM));
    if max(dirsM)>2*pi
        theta = deg2rad(theta);
    end

   for i = 1:length(td(1).(spikeLabel)(1,:))
    
    bumpX = sum(squeeze(cos(theta)'.*squeeze(bumpTot(i,1,:)))');
    bumpY = sum(squeeze(sin(theta)'.*squeeze(bumpTot(i,1,:)))');

    moveX = sum(squeeze(cos(theta)'.*squeeze(moveTot(i,1,:)))');
    moveY = sum(squeeze(sin(theta)'.*squeeze(moveTot(i,1,:)))');
    angMove(i) = atan2(moveY, moveX);
    angBump(i) = atan2(bumpY, bumpX);

    mkdir([getBasicPath(td(1).monkey, dateToLabDate(date), getGenericTask(td(1).task)),'plotting', filesep,'NeuronPlots',filesep]);
    title1 = [getBasicPath(td(1).monkey, dateToLabDate(date), getGenericTask(td(1).task)),'plotting', filesep,'NeuronPlots',filesep, array,'_',td(1).monkey,'_Electrode_',date, '_', num2str(td(1).(unitGuide)(i,1)), ' Unit ', num2str(td(1).(unitGuide)(i,2))];
    title2 = [array,'_',td(1).monkey,'_Electrode_',date, '_', num2str(td(1).(unitGuide)(i,1)), ' Unit ', num2str(td(1).(unitGuide)(i,2))];
    moveTuned(i) = any(preMoveStat.meanCI(i,3) < t(i, 1,:)) | any(preMoveStat.meanCI(i, 2) > t(i,1, :));
    bumpTuned(i) = any(preBumpStat.meanCI(i,3) < t(i, 1,:)) | any(preBumpStat.meanCI(i, 2) > t(i,1, :));
    tuned(i) = moveTuned(i)|bumpTuned(i);
    if tuned(i)
        title1 = [title1, '_TUNED'];
        title2 = [title2, '_TUNED'];
    end
    %% circle plotting
    if circleFlag & tuned(i)
        
        bumpHigh =squeeze(bumpTot(i, 3, :));
        bumpMean = squeeze(bumpTot(i,1,:));
        bumpLow = squeeze(bumpTot(i,2,:));
        
        moveHigh = squeeze(moveTot(i,3,:));
        moveMean = squeeze(moveTot(i,1,:));
        moveLow  = squeeze(moveTot(i,2,:));
        
        thetaPlot = [theta,theta(1)];
        
        f2 = figure('Position', [100, 0, 600, 600]); 
        polarplot(thetaPlot, [bumpHigh; bumpHigh(1)], 'Color', [1,.4,.4], 'LineWidth', 2)
        hold on 
        polarplot(thetaPlot, [bumpMean;bumpMean(1)], 'Color', [1,0,0], 'LineWidth', 2)
        polarplot(thetaPlot, [bumpLow;bumpLow(1)], 'Color', [1,.4,.4], 'LineWidth', 2)
        
        polarplot(thetaPlot, [moveHigh;moveHigh(1)], 'Color', [.4,.4,1], 'LineWidth', 2)
        polarplot(thetaPlot, [moveMean;moveMean(1)], 'Color', [0,0,1], 'LineWidth', 2)
        polarplot(thetaPlot, [moveLow; moveLow(1)], 'Color', [.4,.4,1], 'LineWidth', 2)
        
        polarplot([angBump(i), angBump(i)], [0, max([moveHigh])],'Color', [1,0,0], 'LineWidth', 2);
        polarplot([angMove(i), angMove(i)], [0, max([bumpHigh])], 'Color', [0,0,1],'LineWidth',2);
        
        title([strrep(title2, '_', ' '), ' Tuning Curves'])
        figTitle = [title1, 'TuningCurve.'];
        if(saveFig)
            saveas(f2, [strrep(figTitle, ' ', '_'),'pdf']);
            saveas(f2, [strrep(figTitle, ' ', '_'),'png']);
        end
    end
    close all
%% Generate output structure


outStruct(i).moveTuned= moveTuned(i);
outStruct(i).bumpTuned = bumpTuned(i);
outStruct(i).preMove.mean = movePre(i,1);
outStruct(i).preMove.high = movePre(i,3);
outStruct(i).preMove.low = movePre(i,2);

outStruct(i).postMove.mean = moveTot(i,1,:);
outStruct(i).postMove.high = moveTot(i,3,:);
outStruct(i).postMove.low = moveTot(i,2,:);

%%

%%
outStruct(i).monkey = monkey1;
outStruct(i).date = date;
outStruct(i).array = array;
outStruct(i).angBump = angBump(i);
outStruct(i).angMove = angMove(i);

pasActDif = angleDiff(angBump(i), angMove(i));
% 
outStruct(i).pasActDif = pasActDif;
outStruct(i).firing.active = moveTot;
outStruct(i).firing.passive = bumpTot;
% outStruct(i).numPasDif = sum(sigDifBump(i));
% outStruct(i).numActDif = sum(sigDifMove(i));


outStruct(i).dcBump = mean(bumpTot(i, 1, :)- bumpPre(i,1));
outStruct(i).dcMove= mean(moveTot(i,1, :) - movePre(i,1));


outStruct(i).modDepthMove=max(moveTot(i,1,:)) - min(moveTot(i,1,:));
outStruct(i).modDepthBump = max(bumpTot(i,1,:)) - min(bumpTot(i,1,:));

outStruct(i).tuned= tuned(i);
end
%% If I want to plot stuff


if plotFlag
    coActPasPlotting(outStruct);
end
fh=[];
end

