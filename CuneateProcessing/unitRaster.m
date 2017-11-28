function fh1 = unitRaster(trialData, params)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    xBound = [-.3, .3];
    yMax = 40;
    array ='cuneate';
    align= 'movement_on';
    neuron =1;
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    count=0;
    numTrials = length(trialData);
    for trialNum = 1:length(trialData)

        count =count +1;
        trial = trialData(trialNum);
        alignStart = trial.bin_size * (trial.(['idx_',align]) - trial.idx_startTime);
        numSpikes = length(trial.([array, '_ts']){neuron});
       for spike = 1:numSpikes
           fh1 = plot([trial.([array, '_ts']){neuron}(spike)-alignStart, trial.([array, '_ts']){neuron}(spike)-alignStart], [count*yMax/numTrials, (count+.8)*yMax/numTrials], 'k');
           hold on
       end
    end
    xlim(xBound);
    ylim([0, yMax]); 
end

