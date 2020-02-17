function p = doNonParametricForUnityLine(numTests, data)
type1 = false;
if type1
    xLarger = sum(data(:,1)>data(:,2));
    testData = rand(length(data(:,1)), 2, numTests);
    for i = 1:numTests
        xLargerSim(i) = sum(testData(:,1,i)>testData(:,2,i));
    end
    quant = quantile(xLargerSim, [1/numTests:1/numTests:1.0]);
    p = (numTests - find(xLarger<=quant, 1))/numTests;
else
    % y = x
    % x-y =0
    % A = 1
    % B = -1
    % d = abs(x1 - y1)/sqrt(2)
    for i = 1:length(data(:,1))
        d(i) = (data(i,1) - data(i,2))/sqrt(2);
    end
    [h1, p] = ttest(d)
end
end