function [ path1 ] = getTDSavePath( monkey, date, task )
%     This function gets the save path for the CDS, as a function of the
%     monkey, date and task (and the system you are running on):
%       Inputs:
%           Self explanatory: all strings
% 
% 
%       Outputs:
%           the path to write the CDS to 
%       
%       TODO: Add my linux partition to this
% 
    %% Get where you are
    compName = getenv('computername');
    % if you are on GOB2
    if strcmp(compName, 'FSM8M1SMD2')
        %% GOB2
        whichComp = 'GOB2';
        path1 = ['C:\Users\csv057\Documents\MATLAB\MonkeyData\',task, filesep, monkey,'\',date, '\TD\'];
    elseif strcmp(compName, 'Chris-desktop')
        %% my desktop (PC version)
        whichComp = 'home';
        path1 = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\CDS\',task,'\',monkey, '\', date , '\'];
    elseif strcmp(compName, 'RESEARCHPC')
        %% My (old) laptop
        whichComp = 'laptop';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\CDS\',task,'\',monkey, '\', date, '\'];
    elseif strcmp(compName, 'LAPTOP-DK2LKBEH')
        %% My (new) laptop
        whichComp = 'laptop2';
        path1 = ['C:\Users\wrest\Documents\MATLAB\MonkeyData\',task,'\',monkey,'\',date, '\CDS\'];
    else 
        error('Computer not recognized......... Exiting');
    end
end

