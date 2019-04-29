function [ cdsTask ] = getGenericTask( inTask )
% Inputs :
%    
%   inTask: task name in input file (whatever you call your nev) 
%
% 
% Outputs:
%   cdsTask: translation between the label on the trial and which task
%   class it falls under
    if strcmp(inTask(1:2),'CO')
        cdsTask = 'CO';
    elseif strcmp(inTask(1:2),'RW')
        cdsTask = 'RW';
    elseif strcmp(inTask, 'WF')
        cdsTask = 'WFH';
    elseif strcmp(inTask, 'WFH')
        cdsTask = 'WFH';
    elseif strcmp(inTask(1:3), 'OOR')
        cdsTask = 'OOR';
%     elseif strcmp(inTask(1:9), 'vibration')
%         cdsTask = 'Vibration';
    elseif strcmp(inTask(1:3), 'TRT')
        cdsTask = 'TRT';
    elseif strcmp(inTask, 'SensoryMappings')
        cdsTask = 'Unknown';

    else
        cdsTask = 'Unknown';
    end

end

