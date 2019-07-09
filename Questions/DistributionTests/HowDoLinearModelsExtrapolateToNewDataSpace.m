clear all
close all
x = 100:119;
for i = 1:1000
y = poissrnd(2*x);
lm1 = fitlm(x,y);
b(i) = lm1.Coefficients.Estimate(1);
end
scatter(x,y, 'filled')
xlim([0, 50])
ylim([0,110]) 
hold on
plot(temp', predict(lm1, temp'))
scatter(x1, y1, 'filled')
set(gca,'TickDir','out', 'box', 'off')
