function [ cdsTask ] = getTask( inTask )
% Inputs :
%    
%   inTask: task name in input file (whatever you call your nev) 
%
% 
% Outputs:
%   cdsTask: translation between the label on the trial and which task
%   class it falls under
    if strcmp(inTask(1:2),'CO')
        cdsTask = 'CObump';
    elseif strcmp(inTask(1:2),'RW')
        cdsTask = 'RW';
    elseif strcmp(inTask(1:3), 'OOR')
        cdsTask = 'OOR';
    elseif strcmp(inTask(1:3), 'TRT')
        cdsTask = 'TRT';
    else
        cdsTask = 'Unknown';
    end

end

