function [ path ] = getRawPath( monkey, date, task)
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
    path = [getBasicPath(monkey, date, task), 'NEV', filesep];
end

