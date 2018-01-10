function [ cdsTask ] = getTask( inTask )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
    if strcmp(inTask(1:2),'CO')
        cdsTask = 'CObump';
    elseif strcmp(inTask(1:2),'RW')
        cdsTask = 'RW';
    elseif strcmp(inTask(1:3), 'OOR')
        cdsTask = 'OOR';
    else
        cdsTask = 'Unknown';
    end

end

