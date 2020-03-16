function [ cdsTask ] = getTask( inTask )
% Inputs :
%    
%   inTask: task name in input file (whatever you call your nev) 
%
% 
% Outputs:
%   cdsTask: translation between the label on the trial and which task
%   class it falls under
 if datetime < datetime(2020, 3, 10)
    if strcmp(inTask(1:2),'CO')
        cdsTask = 'CObump';
    elseif strcmp(inTask(1:2),'RW')
        cdsTask = 'RW';
    elseif strcmp(inTask(1:3), 'OOR')
        cdsTask = 'OOR';
    elseif strcmp(inTask(1:3), 'TRT')
        cdsTask = 'TRT';
    elseif strcmp(inTask, 'WFH')
        cdsTask = 'WF';
    elseif strcmp(inTask, 'bumpDir')
        cdsTask = 'BD';
    elseif strcmp(inTask, 'BD')
        cdsTask = 'BD';
    else
        cdsTask = 'Unknown';
    end
 else
    if strcmp(inTask(1:2),'CO')
        cdsTask = 'CObump';
    elseif strcmp(inTask(1:2),'RW')
        cdsTask = 'RW';
    elseif strcmp(inTask(1:3), 'OOR')
        cdsTask = 'OOR';
    elseif strcmp(inTask(1:3), 'TRT')
        cdsTask = 'TRT';
    elseif strcmp(inTask, 'WFH') | strcmp(inTask, 'WF') |strcmp(inTask, 'WM') | strcmp(inTask, 'WS') |strcmp(inTask, 'WB') | strcmp(inTask, 'WI')
        cdsTask = 'WF';
    elseif strcmp(inTask, 'bumpDir')
        cdsTask = 'BD';
    elseif strcmp(inTask, 'BD')
        cdsTask = 'BD';
    else
        cdsTask = 'Unknown';
    end
 end

end

