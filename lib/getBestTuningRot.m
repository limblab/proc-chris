function [bestOverlap, bestScale, bestShift] = getBestTuningRot(curve1, curve2, bins, absFlag, method)
    curve1 = [curve1(end),curve1, curve1(1)];
    curve2 = [curve2(end),curve2, curve2(1)];
    plotFigs = false;
    if nargin<4
        absFlag=false;
    end
    if nargin <5
        splineFlag = false;
    end
    bins = [bins(1)- pi/2, bins, 2*pi+bins(1)];
    if strcmp(method, 'spline')
        curveDeg1 = spline(bins, curve1, linspace(-pi/2,3*pi/2, 360));
        curveDeg2 = spline(bins, curve2, linspace(-pi/2,3*pi/2, 360));
    elseif strcmp(method, 'interp')
        curveDeg1 = interp1(bins, curve1, linspace(-pi/2,3*pi/2, 360)); 
        curveDeg2 = interp1(bins, curve2, linspace(-pi/2,3*pi/2, 360)); 
    elseif strcmp(method, 'fourier')
        fitCurve1 = fit(bins', curve1', 'fourier1');
        fitCurve2 = fit(bins', curve2', 'fourier1');
        
        curveDeg1 = feval(fitCurve1, linspace(-pi/2, 3*pi/2, 360));
        curveDeg2 = feval(fitCurve2, linspace(-pi/2, 3*pi/2, 360));
    else
        error('Enter a method')
    end
    

    for i =1:360
        shift = i-180;
        [scaleVec(i), overlap(i)] = fminsearch(@(scale)mapCurves(shift, scale,curveDeg1, curveDeg2), 1);
        
    end
    [bestOverlap, bestShift]= min(overlap);
    bestScale = scaleVec(bestShift);
    if absFlag
        bestShift = abs(bestShift);
    end
    bestShift = bestShift-180;
    
    if plotFigs
       figure
       polarplot(linspace(-pi/2, 3*pi/2, 360), curveDeg1)
       hold on
       polarplot(bins, curve1)
       polarplot(linspace(-pi/2, 3*pi/2, 360), curveDeg2)
       polarplot(bins, curve2)
       bestFit = circshift(bestScale*curveDeg1, bestShift);
       polarplot(linspace(-pi/2, 3*pi/2, 360), bestFit)
       legend({'curve1 Fit', 'curve1', 'curve2 Fit', 'curve2', 'best rotation and scaling'})
       pause();
        
       
    end
    function overlap =  mapCurves(shift, scale, curve1, curve2)
        overlap = norm(circshift(scale.*curve1, shift)-curve2);
    end
end