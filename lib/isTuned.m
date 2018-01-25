function tuningBool = isTuned(dir ,CIBound,cutoff)
%UNTITLED2 Summary of this function goes here
%   Detailed explanati
    for i = 1:length(dir)
        if angleDiff(CIBound(i, 2), CIBound(i,1)) < cutoff & angleDiff(dir(i), CIBound(i,1))< pi/2 & angleDiff(dir(i), CIBound(i,2))<pi/2
            tuningBool(i)=true;
        else
            tuningBool(i) = false;
        end
    end
end

