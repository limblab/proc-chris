function [ vibOn1 ] = scrubVibration( vibOn )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    vibOn1 = vibOn;
    for i = 1:length(vibOn)-1
        if vibOn(i) == 1
            vibOn1(i+1) = 1;
        end
    end
    for j = 2:length(vibOn)
        if vibOn(j) == 1
            vibOn1(i-1) = 1;
        end
    end

end

