function [ path ] = getRawPath( monkey, date, task)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    compName = getenv('computername');
    if strcmp(compName, 'FSM8M1SMD2')
        whichComp = 'GOB2';
        path = ['C:\Users\csv057\Documents\MATLAB\MonkeyData\RawData\', monkey, '\',date, '\'];
    elseif strcmp(compName, 'Chris-desktop')
        whichComp = 'home';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\RawData\',monkey,'\',date, '\'];
    elseif strcmp(compName, 'RESEARCHPC')
        whichComp = 'laptop';
        path = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\RawData\',monkey,'\',date, '\'];
    elseif strcmp(compName, 'LAPTOP-DK2LKBEH')
        whichComp = 'laptop2';
        path = ['C:\Users\wrest\Documents\MATLAB\MonkeyData\',monkey,'\',task,'\',date, '\RawData\'];
    else 
        error('Computer not recognized......... Exiting');
    end    
end

