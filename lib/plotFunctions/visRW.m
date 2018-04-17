function [fh1] = visRW(td,params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    params = struct();
    for trial = 1:length(td)    
       fhRaster = trialRaster(td(trial),params);
        pause()
        close all
    end
end

