function tuningBool = isTuned(dir1 ,CIBound,cutoff)
%UNTITLED2 Summary of this function goes here
%   Detailed explanati
    for i = 1:length(dir1)
        if abs(angleDiff(CIBound(i, 2), CIBound(i,1))) < cutoff & angleDiff(dir1(i), CIBound(i,1))< pi/2 & angleDiff(dir1(i), CIBound(i,2))<pi/2
            tuningBool(i)=true;
        else
            tuningBool(i) = false;
        end
    end
end

