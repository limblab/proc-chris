function [ nevName ] = getNameNEV( monkey, date, task, array, number, isSorted)
%% getNameNEV: function to compose the name of the nev file given a bunch of inputs
%Inputs :
%    monkey: monkey name as a string
% 
%   task: task name in input file (whatever you call your nev) 
%
%   date: date that you ran it as a string
% 
%   array: string of array name
% 
%   numbers: either an int or a cell array of ints (one for each array)
% 
%   areSorted: either a boolean or a cell array of booleans(one for each
%   array)
% 
% Outputs:
%   nevName: the compiled name of the NEV to search for given the inputs:
    
    if isSorted
        nevName = ['Sorted\',monkey, '_', date, '_', task, '_', array, '_', num2str(number, '%03i'), '-sorted'];
    else
        nevName = [monkey, '_', date, '_', task, '_', array, '_', num2str(number, '%03i')];
    end
end

