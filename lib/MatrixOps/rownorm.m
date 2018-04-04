function [ rowNorm ] = rownorm( mat )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    rowNorm = sqrt(sum(mat'.^2,1));

end

