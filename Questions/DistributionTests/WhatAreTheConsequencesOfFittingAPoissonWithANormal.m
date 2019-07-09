clear all
close all
for i = 1:1000
    disp(num2str(i))
    p = poissrnd(4, 100000,1);
    meanP(i) = mean(p);
    stdP(i) = std(p);
end
histogram(meanP)
