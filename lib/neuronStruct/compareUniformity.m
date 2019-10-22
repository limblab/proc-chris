function [tab] = compareUniformity(neurons1, neurons2)
numBoots = 1000;
useRtest = true;
useVtest = false;
actAngs1 = [neurons1.actPD.velPD];
actAngs2 = [neurons2.actPD.velPD];

actMean1 = circ_mean(actAngs1);
actMean2 = circ_mean(actAngs2);
inds1 = randi(length(actAngs1), length(actAngs1), numBoots);
inds2 = randi(length(actAngs2), length(actAngs1), numBoots);

for i = 1:numBoots
    bootAngs1 = actAngs1(inds1(:,i));
    bootAngs2 = actAngs2(inds2(:,i));
    if useVtest
    [p1(i), uni1(i)] = circ_vtest(bootAngs1, actMean1);
    [p2(i), uni2(i)] = circ_vtest(bootAngs2, actMean2);
    elseif useRtest
    uni1(i) = circ_r(bootAngs1);
    uni2(i) = circ_r(bootAngs2);
    end
    
end

r1CI = quantile(uni1, [.025, .5, .975]);
r2CI = quantile(uni2, [.025, .5, .975]);

sUni1 = sort(uni1);
sUni2 = sort(uni2);

lowUni1 = sUni1(numBoots*.025);
highUni1 = sUni1(numBoots*.975);

lowUni2 = sUni2(numBoots*.025);
highUni2 = sUni2(numBoots*.975);

mUni1 = sUni1(numBoots*.5);
mUni2 = sUni2(numBoots*.5);


tab = table([r1CI(1); r2CI(1)],[r1CI(2);r2CI(2)], [r1CI(3); r2CI(3)], 'VariableNames', {'LowCI','mean','HighCI'});


end