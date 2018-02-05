function [overlapDist, scaleDist, shiftDist] = getBaselineRotationDist(curveIn1, curveIn2, params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    numBoots= length(curveIn1);
    method = 'interp';
    bins = linspace(-pi,pi,5);
    bins = bins(2:end);
    if nargin > 2, assignParams(who,params); end % overwrite parameters

    %% Outer bootstrap loop
    overlapDist = zeros(numBoots, 1);
    scaleDist = zeros(numBoots,1);
    shiftDist = zeros(numBoots,1);
    for i = 1:length(curveIn1(:,1))
        curve1 = curveIn1(randi(length(curveIn1(:,1))),:);
        curve2 = curveIn2(randi(length(curveIn2(:,1))),:);
        [overlapDist(i), scaleDist(i), shiftDist(i)] = getBestTuningRot(curve1, curve2, bins, false, method);
        disp(['Done boot ', num2str(i)])
    end
end

