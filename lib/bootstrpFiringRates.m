function [meanFiring, ciLow, ciHigh, bootstat] = bootstrpFiringRates(firing, numBoot, CI)
%bootstrpFiringRates: Compute mean and CI for a set of firing rates
%   Inputs: 
%       firing (nx1) vector, where n is the number of trials
%       Each row contains the average firing rate in a window on a given
%       trial
%       
%       numBoot: integer: number of bootstrap iterations to run
%
%       CI: integer: Confidence interval for high and low bounds. 
%   Outputs:
%       mean: double: mean firing rate of bootstrapped samples
%       ciLow: double: low end firing rate of the neuron in the trials
%       ciHigh: double: high end firing rate ...
%       bootstat: all bootstrapped values if needed
%
%   NOTE: this function assumes 10 ms bins. Keep that in mind

    temp = mean(firing*100,2);
    bootstat= bootstrp(numBoot, @mean, temp);
    sortedBootstat = sort(bootstat);
     meanFiring = mean(sortedBootstat);
    ciLow = sortedBootstat(floor(numBoot*(1-CI)/2) );
    ciHigh = sortedBootstat(floor(numBoot*(CI)/2) );

end

