function [bestOverlap, bestScale, bestShift] = getBestTuningRot(curve1, curve2, bins)
    curve1 = [curve1, curve1(1)];
    curve2 = [curve2, curve2(1)];
    bins = [bins, 2*pi+bins(1)];
    curveDeg1 = interp1(bins, curve1, linspace(-pi/2,3*pi/2, 365)); 
    curveDeg2 = interp1(bins, curve2, linspace(-pi/2,3*pi/2, 365)); 
    a =1;
    for i =1:365
        shift = i;
        [scaleVec(i), overlap(i)] = fminsearch(@(scale)mapCurves(shift, scale,curveDeg1, curveDeg2), 1);
        
    end
    [bestOverlap, bestShift]= min(overlap);
    bestScale = scaleVec(bestShift);


    function overlap =  mapCurves(shift, scale, curve1, curve2)
        overlap = norm(circshift(scale.*curve1, shift)-curve2);
    end
end