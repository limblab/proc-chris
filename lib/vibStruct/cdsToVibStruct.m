function [ vibStruct ] = cdsToVibStruct( cds, params )
%% cdsToVibStruct(cds, params)
% this function is to generate a compatible structure for all files where I
% vibrate muscles. The general workflow takes an input cds (not a td bc
% there are no trials in this) and outputs a structure that has the
% vibration start and stop windows, the monkey, date, and array, the
% electrode (the visually displayed one), the muscle, when the vibration is
% on, the firing rate of the unit which was listened to, as well as all
% other units binned firing rates.
%
%
% Inputs: 
%
%   cds: self explanatory:
%
%   params: the params structure with the followin optional fields
%       numScrubs: This parameter is used for filling in gaps when the
%       vibration voltage drops below a certain speed (clipping near edges
%       of vibration, which causes there to be many short illusory
%       vibration pulses. Increasing this scrubbing cleans that up, but may
%       overestimate how long the vibration is actually on
%
%       vibrationCutoff: This is a threshold for teh diff of the vibration
%       signal to see when it should be considered vibration on. Set
%       empirically but dont expect to change that much
%
%       binSize: binned spikes, what binsize do you want
%
%       helperPlot: whether you want a plot to examine if you got any
%       resopnse to your vibration

%% Initializing parameters
    numScrubs =8;
    vibOnCutoff = 20;
    binSize = 50;
    helperPlot = true;
    pName = 'SyncPulse';
    close all
    
    if nargin > 1 && ~isempty(params)
        assignParams(who,params); % overwrite parameters
    end
    %% Setting up empty structure, getting naming from file
    vibStruct = struct('monkey', [], 'date' ,[],'array', [], 'electrode', [], 'muscle', [], 'vibOn', [],'vibTimes',[]);
    filename = cds.meta.rawFileName;
    parts = strsplit(filename, '_');
    
    vibStruct.monkey= parts(1);
    vibStruct.date = parts(2);
%     vibStruct.array = parts(7);
    vibStruct.electrode = str2num(parts{3}(1:end));
    vibStruct.muscle = parts(4);
    %% Getting the vibration signal (what this is called may change)
    vibTime = cds.analog{1,2}.t;
    vibration = cds.analog{1,2}.(pName);
    vibOn = [abs(diff(vibration))>vibOnCutoff; 0];
    [~, peaks1] = findpeaks(vibration);
    pTimes= vibTime(peaks1);
    %% Scrubbing out the defects
    for i = 1:numScrubs
        vibOn = scrubVibration(vibOn);
    end
    vibStruct.vibOn.flag = vibOn;
    vibStruct.vibOn.t = vibTime;
    %% Finding out how many vibration pulses occurred
    numVibes = min(diff(vibOn)==1, diff(vibOn)==-1);
    vibStart = vibTime(diff(vibOn)==1);
    vibEnd = vibTime(diff(vibOn) ==-1);
    %% getting rid of leading/trailing pulses (with only a start or a stop)
    if vibEnd(1) < vibStart(1)
        vibEnd(1) = [];
    end
    if vibStart(end) > vibEnd(end)
        vibStart(end) = [];
    end
    
    vibWindow = [vibStart, vibEnd];
    vibStruct.vibTimes= vibWindow;
    flag = zeros(length(peaks1),1);
    for i = 1:length(vibWindow(:,1))
        flag = flag | (pTimes>vibWindow(i,1) & pTimes<vibWindow(i,2));
        plot(flag)
    end
    pTimes(~flag) = [];
    %% Getting the correct unit by crossreferencing the map file
    sortedUnits = cds.units([cds.units.ID] >0  & [cds.units.ID] <255);
    unitVibedRows = ~cellfun(@isempty, strfind({cds.units.label},['elec', num2str(vibStruct.electrode)]));
    unitVibed = cds.units(find(unitVibedRows & [cds.units.ID] >0 & [cds.units.ID] <255) );
    %% Binning Spikes
    binnedSpike = bin_spikes(sortedUnits, 1:length(sortedUnits), linspace(vibTime(1), vibTime(end), length(vibTime)/binSize)');
    unitVibedBin = bin_spikes(unitVibed, 1, linspace(vibTime(1), vibTime(end), length(vibTime)/binSize)');
    vibStruct.vibUnit.t = linspace(vibTime(1), vibTime(end), length(vibTime)/binSize)';
    vibStruct.vibUnit.firing = unitVibedBin*binSize;
    vibStruct.vibUnit.ts = unitVibed.spikes.ts;
    vibStruct.otherUnits.t = vibStruct.vibUnit.t;
    vibStruct.otherUnits.firing = binnedSpike;
    vibStruct.otherUnits.IDs = [[sortedUnits.chan]', [sortedUnits.ID]'];
    vibStruct.vibOn.vibPeaks = pTimes;
    %% Helper plot for you to look at other units
    if helperPlot
        plot(vibStruct.vibOn.t, vibStruct.vibOn.flag)
        hold on
        yyaxis right
        plot(vibStruct.vibUnit.t, smooth(vibStruct.vibUnit.firing))
    end
   
function [binned_spikes,sg] = bin_spikes(units,unit_idx,t_bin)

    % note that histcounts outputs rows
    binned_spikes = zeros(size(unit_idx,1),length(t_bin));

    % histcounts works weirdly and needs an extra bin
    t_bin = [t_bin; t_bin(end)+mode(diff(t_bin))];

    sg = zeros(length(unit_idx),2);
    for unit = 1:length(unit_idx)
        % get the spikes for that cell in the current time window
        ts = units(unit_idx(unit)).spikes.ts;
        binned_spikes(unit,:) = histcounts(ts,t_bin);
        sg(unit,:) = [units(unit_idx(unit)).chan, units(unit_idx(unit)).ID];
    end
    % must transform to have same dimensions as kinematics etc
    binned_spikes = binned_spikes';
end

end

