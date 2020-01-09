function [tab] = compareUniformity(neurons1, neurons2, simInputs)
numBoots = 1000;
useRtest = true;
useVtest = false;
if istable(neurons1)
    actAngs1 = [neurons1.actPD.velPD];
else
    actAngs1 = neurons1;
end
if ~isempty(neurons2)
    actAngs2 = [neurons2.actPD.velPD];
else
    actAngs2 = simInputs;
end
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

r1CI = quantile(uni1, [.05, .5, .95]);
r2CI = quantile(uni2, [.05, .5, .95]);


tab = table([r1CI(1); r2CI(1)],[r1CI(2);r2CI(2)], [r1CI(3); r2CI(3)], 'VariableNames', {'LowCI','mean','HighCI'});


end