close all
clear velDir
CIwidth = abs(angleDiff(out.velDirCI(:,2), out.velDirCI(:,1)));
tunedFlag = CIwidth<pi/4;
histogram(CIwidth(tunedFlag), 8)
outTuned = out(tunedFlag,:);
figure
for i = 1:height(outTuned)
    velDir(i) = outTuned.velDir(i);
    polarplot([velDir(i), velDir(i)], [0,1])
    hold on
end

figure
histogram(velDir, 8);