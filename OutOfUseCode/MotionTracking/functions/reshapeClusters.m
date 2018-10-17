function [ clusterMat ] = reshapeClusters( clusterVec )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:length(clusterVec)
        clusterMat{i}=  reshape(clusterVec{i}, [length(clusterVec{i})/3, 3]);    
    end

end

