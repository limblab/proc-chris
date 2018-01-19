function fh1 = plotBumpsInMoveDir(trials,params)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
    params.neuron = num1;
    params.yMax = 40;
    params.align= 'bumpTime';
    params.xBound = [-.3, .3];
    paramsarray = unitNames;
for i=1:4
    bump = trials{i};
    switch i
        case 1
            subplot(3,3,6)
        case 2
            subplot(3,3,2)
        case 3
            subplot(3,3,4)
        case 4
            subplot(3,3,8)
    end
    fh1 = unitRaster(bump, params);
    
end

end

