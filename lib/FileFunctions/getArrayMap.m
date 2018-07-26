function [ arrayPath ] = getArrayMap( monkey, array )
%Inputs :
%    monkey: monkey name as a string
% 
%   array: What array you want the map for
% 
% Outputs:
%   arrayPath: the path to the array
    % if you have only one array
    mapName = dir([getBasePath(), 'MapData\', monkey, '\', array, '\*.cmp']);
    arrayPath = [getBasePath(), 'MapData\', monkey, '\', array, '\',mapName.name];
      
end

