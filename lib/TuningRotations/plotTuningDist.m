function [fh1, percentTuned, tablePD] = plotTuningDist(tablePDs, fh1, color, cutoff)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    coActPasPDs = tablePDs;
    for i =1:height(tablePDs)
       curve = coActPasPDs(i,:);
       coActPasPDs.velTuned(i) = isTuned(curve.velPD,curve.velPDCI, cutoff);
    end
    totalTuned = sum(coActPasPDs.velTuned);
    percentTuned = totalTuned/length(coActPasPDs.velTuned);
    
    tunedPDs = [coActPasPDs.velPD(coActPasPDs.velTuned)];
    fh1;
    hold on
    for i = 1:sum(coActPasPDs.velTuned)
        polar([tunedPDs(i), tunedPDs(i)], [0,1], color)
    end
    tablePD = coActPasPDs;
end

