function [r2Unity, coCoeff] = getUnityR2(data1, data2)
    ssRes = norm(data2-data1);
    ssTot = norm(data2-mean(data2));
    r2Unity = 1 - (ssRes/ssTot);
    coCoeff = corrcoef(data1, data2);
end