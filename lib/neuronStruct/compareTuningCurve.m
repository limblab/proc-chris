function same = compareTuningCurve(tc1, tc2)
    c1 = tc1.velCurve;
    c2 = tc2.velCurve;
    cIL1 = tc1.velCurveCIlow;
    cIL2 = tc2.velCurveCIlow;
    cIH1 = tc1.velCurveCIhigh;
    cIH2 = tc2.velCurveCIhigh;
    
    same = true;
    for i= 1:length(c1(1,:))
        if c1(i) > cIL2(i) & c1(i) < cIH2(i) & c2(i) > cIL1(i) & c2(i) < cIH1(i)
            same = false;
        end
    end
end