function tuningBool = isTuned(dir ,CIBound,cutoff)
%UNTITLED2 Summary of this function goes here
%   Detailed explanatio
    if angleDiff(CIBound(1), CIBound(2)) < cutoff & angleDiff(dir, CIBound(1))< pi/2 & angleDiff(dir, CIBound(2))<pi/2
        tuningBool=true;
    else
        tuningBool = false;
    end
end

