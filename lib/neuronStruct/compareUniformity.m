function [lowUni1, highUni1, lowUni2, highUni2] = compareUniformity(neurons1, neurons2)
numBoots = 1000;
actAngs1 = [neurons1.actPD.velPD];
actAngs2 = [neurons2.actPD.velPD];

actMean1 = circ_mean(actAngs1);
actMean2 = circ_mean(actAngs2);
inds1 = randi(length(actAngs1), length(actAngs1), numBoots);
inds2 = randi(length(actAngs2), length(actAngs2), numBoots);
for i = 1:numBoots
    bootAngs1 = actAngs1(inds1(:,i));
    bootAngs2 = actAngs2(inds2(:,i));
    
    [p1(i), uni1(i)] = circ_otest(bootAngs1);%, actMean1);
    [p2(i), uni2(i)] = circ_otest(bootAngs2);%, actMean2);
    
end
sUni1 = sort(uni1);
sUni2 = sort(uni2);

lowUni1 = sUni1(numBoots*.025);
highUni1 = sUni1(numBoots*.975);

lowUni2 = sUni2(numBoots*.025);
highUni2 = sUni2(numBoots*.975);
sp1 = sort(p1)
sp2 = sort(p2)
sp1(25)
sp2(25)
sp1(975)
sp2(975)
sp2(500)

end