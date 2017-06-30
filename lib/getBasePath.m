function [ path ] = getBasePath( monkey )
    compName = getenv('computername');
    if strcmp(compName, 'FSM8M1SMD2')
        whichComp = 'GOB2';
        path = ['C:\Users\csv057\Documents\MATLAB\MonkeyData\RawData\', monkey, '\'];
    elseif strcmp(compName, 'Chris-desktop')
        whichComp = 'home';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\RawData\',monkey,'\'];
    elseif strcmp(compName, 'RESEARCHPC')
        whichComp = 'laptop';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\RawData\',monkey,'\'];
    else 
        error('Computer not recognized......... Exiting');
    end 

end

