function [ path ] = getBasicPath( monkey, date, task, resort)
%getRawPath:
%   Gets the path to the raw file that you want to compute the CDS for
%   Inputs :
%    monkey: monkey name as a string
% 
%   task: task name in input file (whatever you call your nev) 
%
%   date: date that you ran it as a string
% Outputs:
%   path: the path to the directory containing the raw .NEV file you want
%   to process
    if nargin <4
        resort = false;
    end
    compName = getenv('computername');
    arch = computer('arch');
    if strcmp(compName, 'FSM8M1SMD2')
        %% GOB2
        whichComp = 'GOB2';
        path = ['C:\Users\csv057\Documents\MATLAB\MonkeyData\', task, '\', monkey, '\',date, filesep];
    elseif strcmp(compName, 'Chris-desktop')
        %% Desktop (windows)
        whichComp = 'home';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\RawData\',monkey,'\',date, '\'];
    elseif strcmp(compName, 'RESEARCHPC')
        %% My (old) laptop
        whichComp = 'laptop';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\RawData\',monkey,'\',date, '\'];
    elseif strcmp(compName, 'LAPTOP-DK2LKBEH')
        %% My (new) laptop
        whichComp = 'laptop2';
        if ~resort
            path = ['D:\MonkeyData\',task,'\',monkey,'\',date, filesep];
        else
            path = ['D:\MonkeyDataResort\',task,'\',monkey,'\',date, filesep];
        end
    elseif strcmp(arch,'glnxa64')
        whichComp = 'linuxDesktop';
        path = ['/media/chris/DataDisk/MonkeyData/', task, '/', monkey, '/', date, filesep];
    else
        error('Computer not recognized......... Exiting');
    end    
end