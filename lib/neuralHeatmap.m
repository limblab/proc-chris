%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function handle = neuralHeatmap(td,params)
%
%   This will generate a heatmap of the firing of the neuron in the
%   workspace of the task. The bounds and number of bins are configurable. 
%   Returns a cell array of figure handles for the plots.
%
% INPUTS:
%   trial_data : (struct) trial_data struct
%   params     : parameter struct
%     array:        The array to use ('cuneate', 'area2'
%     unitsToPlot:  Which units you want to generate plots for
%     numBounds:    How many divisions do you want each dim of the
%     workspace to take up?
%     xLimits:      Where you want the x limits of the workspace to fall.
%     Usful for restricted workspace tasks etc.
%     yLimits:      Same for y axis
%     useJointPCA:  In case you want to use PC space for the separation.
%     Seems very similar to cartesian space in found dimension, but if you
%     care to, it uses first two. Can be easily changed.
%
% OUTPUTS:
%   trial_data : same struct, with fields for:
%       idx_peak_speed
%       idx_movement_onset
%
% Written by Chris Versteeg. Updated Nov 2017.
function [handle, spikingInBounds, varInBounds] = neuralHeatmap(td, params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETER DEFAULTs
    array = 'cuneate';
    unitsToPlot = 8;
    numBounds = 6;
    xLimits = [-10,10];
    yLimits = [-40, -25];
    useJointPCA = false;
    plotError = false;
    velocityCutoffHigh =  Inf;
    velocityCutoffLow = -Inf;
    %
    if nargin > 1, assignParams(who,params); end
    pos = cat(1,td.pos);
    unitNames = td.([array, '_unit_guide']);
    if useJointPCA
        temp = cat(1, td.opensim_pca);
        pos = temp(:,1:2);
    end
    firingTotal = cat(1, td.([array '_spikes']));
    firing = firingTotal(:, unitsToPlot);
    numUnits = length(unitsToPlot);
    xEdges = linspace(xLimits(1), xLimits(2), numBounds+1);
    yEdges = linspace(yLimits(1), yLimits(2), numBounds+1);
    timeInBounds = zeros(numBounds, numBounds);
    spikingInBounds = zeros(numBounds, numBounds, numUnits);
    speed = rownorm(cat(1, td.vel));
    for i = 1:numBounds
        for j = 1:numBounds
            inBounds = pos(:,1) > xEdges(i) & pos(:,1) <xEdges(i+1) & pos(:,2) > yEdges(j) & pos(:,2) < yEdges(j+1);
            timeInBounds(i,j) = sum(inBounds);
            spikingInBounds(i,j,:) = mean(firing(inBounds & (speed>velocityCutoffLow)' & (speed<velocityCutoffHigh)',:))./td(1).bin_size;
            varInBounds(i,j,:) = std(firing(inBounds,:)./td(1).bin_size);
        end
    end
    for i = 1:numUnits
        handle{i} = figure;
        imagesc(spikingInBounds(:,:, i))
        colorbar
        title(['Mean Firing Rate (Hz) Electrode ', num2str(unitNames(i,1)),' Unit ', num2str(unitNames(i,2)), ' in Workspace Region'])
        if plotError
            figure
            imagesc(varInBounds(:,:,i));
            colorbar
            title(['Firing Variability (std in Hz) unit ', num2str(i), ' in Workspace Region'])
        end        
    end
end

