function [fh1] = visRW(td,params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    params = struct();
    fh1 = figure;
    for trial = 1:length(td)
        gca(fh1)
       fhRaster = trialRaster(td(trial),params);
        pause()
        close all
    end
end

