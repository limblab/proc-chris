function [fh1, percentTuned, tablePD, tunedPDs] = plotForceTuningDist(tablePDs, fh1, color, cutoff)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    coActPasPDs = tablePDs;
    for i =1:height(tablePDs)
       curve = coActPasPDs(i,:);
       coActPasPDs.forceTuned(i) = isTuned(curve.forcePD,curve.forcePDCI, cutoff);
    end
    totalTuned = sum(coActPasPDs.forceTuned);
    percentTuned = totalTuned/length(coActPasPDs.forceTuned);
    
    tunedPDs = [coActPasPDs.forcePD(logical([coActPasPDs.forceTuned]))];
    fh1;
    hold on
    for i = 1:sum(coActPasPDs.forceTuned)
        polar([tunedPDs(i), tunedPDs(i)], [0,1], color)
    end
    tablePD = coActPasPDs;
end

