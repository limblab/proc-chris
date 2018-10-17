count = 1;
all_medians_new = all_medians;
for i = 1:length(all_medians(1,1,:))
    if (~isnan(all_medians(8,1,i))) & ~isnan(all_medians(9,:,i)) & ~isnan(all_medians(7,:,i))
        proxArm = all_medians(8,:,i);
        shoulder = all_medians(9,:,i);
        distalArm = all_medians(7,:,i);
        vec = shoulder- distalArm;
        misVec = proxArm - distalArm;
        distAlongVec(count) = (dot(misVec,vec)/norm(vec)^2);
        count = count+1;
    end   
end
meanDist = mean(distAlongVec);
for i = 1:length(all_medians(1,1,:))
    if (isnan(all_medians(8,1,i))) & ~isnan(all_medians(9,:,i))
        shoulder = all_medians(9,:,i);
        distalArm = all_medians(7,:,i);
        vec = shoulder- distalArm;
        all_medians_new(8,:,i) = distalArm + meanDist*vec;
    end
end


count = 1;
all_medians_new = all_medians;
for i = 1:length(all_medians(1,1,:))
    if (~isnan(all_medians(2,1,i))) & ~isnan(all_medians(3,:,i)) & ~isnan(all_medians(4,:,i)) & ~isnan(all_medians(5,:,i))
        point1 = all_medians(3,:,i);
        point2 = all_medians(4,:,i);
        point3 = all_medians(2,:,i);
        point4 = all_medians(5,:,i);
        vec34(count,:) = point4 - point3;
        
        shoulder = all_medians(9,:,i);
        distalArm = all_medians(7,:,i);
        vec = shoulder- distalArm;
        misVec = proxArm - distalArm;
        distAlongVec(count) = (dot(misVec,vec)/norm(vec)^2);
        count = count+1;
    end   
end
meanDist = mean(distAlongVec);
for i = 1:length(all_medians(1,1,:))
    if (isnan(all_medians(8,1,i))) & ~isnan(all_medians(9,:,i))
        shoulder = all_medians(9,:,i);
        distalArm = all_medians(7,:,i);
        vec = shoulder- distalArm;
        all_medians_new(8,:,i) = distalArm + meanDist*vec;
    end
end

