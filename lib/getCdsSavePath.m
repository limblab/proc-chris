function [ path1 ] = getCdsSavePath( monkey, date, task )
    
    compName = getenv('computername');
    if strcmp(compName, 'FSM8M1SMD2')
        whichComp = 'GOB2';
        path1 = ['C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\', monkey, '\',date, '\'];
    elseif strcmp(compName, 'Chris-desktop')
        whichComp = 'home';
        path1 = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\CDS\',monkey,'\',date, '\'];
    elseif strcmp(compName, 'RESEARCHPC')
        whichComp = 'laptop';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\CDS\',monkey,'\',date, '\'];
    elseif strcmp(compName, 'LAPTOP-DK2LKBEH')
        whichComp = 'laptop2';
        path1 = ['C:\Users\wrest\Documents\MATLAB\MonkeyData\',monkey,'\',task,'\',date, '\CDS\'];
    else 
        error('Computer not recognized......... Exiting');
    end
end

