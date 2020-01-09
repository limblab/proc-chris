function p = doNonParametricForUnityLine(numTests, data)
    xLarger = sum(data(:,1)>data(:,2));
    testData = rand(length(data(:,1)), 2, numTests);
    for i = 1:numTests
        xLargerSim(i) = sum(testData(:,1,i)>testData(:,2,i));
    end
    quant = quantile(xLargerSim, [1/numTests:1/numTests:1.0]);
    p = (numTests - find(xLarger<=quant, 1))/numTests;
end