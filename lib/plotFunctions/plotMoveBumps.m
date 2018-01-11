function fh1 = plotMoveBumps(rightUpLeftDown, params)
%   Detailed explanation goes here
    params.neuron = num1;
    params.yMax = 40;
    params.align= 'bumpTime';
    params.xBound = [-.3, .3];
    paramsarray = unitNames;

for i = 1:4
    trials = rightUpLeftDown(i,:);
    fh1 = plotBumpsInMoveDir(trials, params);

end
end

