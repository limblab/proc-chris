function [ path ] = getBasePath( )
    compName = getenv('computername');
    arch = computer('arch');
    if strcmp(compName, 'FSM8M1SMD2')
        whichComp = 'GOB2';
        path = ['C:\Users\csv057\Documents\MATLAB\MonkeyData\'];
    elseif strcmp(compName, 'DESKTOP')
        whichComp = 'home';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\'];
    elseif strcmp(compName, 'RESEARCHPC')
        whichComp = 'laptop';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\'];
    elseif strcmp(compName, 'LAPTOP-DK2LKBEH')
        whichComp = 'laptop2';
        path = ['C:\Users\wrest\Documents\MATLAB\MonkeyData\'];
    elseif strcmp(arch, 'glnxa64')
        path = '/media/chris/DataDisk/MonkeyData/';
    else
        error('Computer not recognized......... Exiting');
    end 

end

