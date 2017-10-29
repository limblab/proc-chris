function [ ang, gain, rotatedCurve, rotatedBins ] = getTuningRotation( bumpCurve, moveCurve, bins )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    
    fun1 = @(x,a,b) norm((a' - x(1)*b'*[cos(x(2)), -sin(x(2));sin(x(2)), cos(x(2))]).^2);
    a = bumpCurve.binnedFR .*[cos(bins); sin(bins)] ;
    b = moveCurve.binnedFR .*[cos(bins); sin(bins)];
    fun2 = @(x)fun1(x,a,b);
    out1 = fminsearch(fun2, [.5, .5]);
    ang = out1(2);
    gain = out1(1);
    rotMat = [cos(ang), -sin(ang); sin(ang), cos(ang)];
    xyMat = [cos(bins); sin(bins)];
    rotatedCurve = moveCurve.binnedFR *gain;
    xyRot = xyMat'*[cos(ang), -sin(ang);sin(ang), cos(ang)];
    rotatedBins = atan2(xyRot(:,2), xyRot(:,1));
    
    figure
    polarplot([rotatedBins; rotatedBins(1)], [rotatedCurve, rotatedCurve(1)])
    hold on
    polarplot([bins, bins(1)], [bumpCurve.binnedFR, bumpCurve.binnedFR(1)])
    polarplot([bins, bins(1)], [moveCurve.binnedFR, moveCurve.binnedFR(1)])
    legend('show')
    end

