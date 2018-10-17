%% Do analysis (Muscle Lengths)
fitData = zscore(motionTrack(:, [dofsToFit]));
for i = 1
    disp(['Unit ', num2str(i)])
    fit = cvglmnet(fitData, binned2(:,i), 'poisson');
    fitCellLen{i}= fit;
end
save([savePath, 'Lando20170223RWS1DoFFits.mat'], 'fitCellLen')


%% Do analysis (Muscle Length Changes)
fitData1 = zscore(diff(motionTrack(:,[musclesToFit])));

for i = 1:length(binned1(1,:))
    firing = binned1(2:end,i);
    disp(['Unit ', num2str(i), ' Velocity'])
    fit = cvglmnet(fitData1, firing, 'poisson');
    fitCellVel{i}= fit;
end
save([savePath, 'Lando20170223RWCuneateMuscleVelFits.mat'], 'fitCellVel')

%% Do analysis (Muscle Lengths and Vels
fitData2 =  [fitData(1:end-1,:), fitData1];

for i = 1:length(binned1(1,:))
    firing = binned1(2:end, i);
    disp(['Unit ', num2str(i), ' Both'])
    fit = cvglmnet(fitData2, firing, 'poisson');
    fitCellBoth{i} =  fit;
end
save([savePath, 'Lando20170223RWCuneateBothFits.mat'], 'fitCellBoth')

%% Print CV plots
for i = 1:14
    fit1 = fitCellVel{i};
    sparseLambda = fit1.lambda_1se;
    sparseInd = find([fit1.lambda] == sparseLambda);
    cvglmnetPlot(fit1)
    bestFit{i} = fitCellVel{i}.glmnet_fit;
    prediction{i} = glmnetPredict(bestFit{i}, fitData,[0.01,0.005]')
end