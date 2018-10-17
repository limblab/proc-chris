%% Get the data from the TD
td= getTD('Butter', '20180522', 'TRT');
% td = getMoveOnsetAndPeak(td);
numPCs = 6;
td = binTD(td,5);
muscleTable= getOpenSimTable(td);
pointTable= getPointTable(td);
kinTable = getKinTable(td);
neuronTable = cat(1, td.cuneate_spikes);
numUnits = length(neuronTable(1,:));

muscleArr = table2array(muscleTable);
pointArr = table2array(pointTable);
kinArr = table2array(kinTable);

[~, musclePCs] = pca(muscleArr);
[~, kinPCs] = pca(kinArr);
[~, pointPCs] = pca(pointArr);

neuronNaming = td(1).cuneate_unit_guide;

fits= struct();
%% Fit the Lasso Model with muscle lengths/velocities
for i = 1:numUnits
    
    model = glm_gaussian(sqrt(neuronTable(:,i)),muscleArr);
    muscleLassoFit = cv_penalized(model, @p_lasso, 'folds', 5);
    muscleFullFit = fitglm(muscleArr, sqrt(neuronTable(:,i)));
    
    model = glm_gaussian(sqrt(neuronTable(:,i)),kinArr);
    kinLassoFit = cv_penalized(model, @p_lasso, 'folds', 5);
    kinFullFit = fitglm(kinArr, sqrt(neuronTable(:,i)));
    
    model = glm_gaussian(sqrt(neuronTable(:,i)),pointArr);
    pointLassoFit = cv_penalized(model, @p_lasso, 'folds', 5);
    pointFullFit = fitglm(pointArr, sqrt(neuronTable(:,i)));
    
    musclePCFit = fitglm(musclePCs, sqrt(neuronTable(:,i)));
    
    kinPCFit = fitglm(kinPCs, sqrt(neuronTable(:,i)));
    
    pointPCFit = fitglm(pointPCs, sqrt(neuronTable(:,i)));
    %%
    fits(i).chan = neuronNaming(i,1);
    fits(i).ID = neuronNaming(i,2);
    fits(i).muscleLasso = muscleLassoFit;
    fits(i).muscleFull = muscleFullFit;
    fits(i).kinLasso = kinLassoFit;
    fits(i).kinFull = kinFullFit;
    fits(i).pointLasso = pointLassoFit;
    fits(i).pointFull = pointFullFit;
    fits(i).musclePC = musclePCFit;
    
    fits(i).kinPC = kinPCFit;
    fits(i).pointPC = pointPCFit;
    
    disp(['Done with ',num2str(i), ' of ', num2str(numUnits)])
end

%%
fitVals = evaluateLassoTable(fits);
figure
histogram([fitVals.muscleFull])
hold on
histogram([fitVals.kinFull])
histogram([fitVals.pointFull]);
legend('Muscles', 'Kin', 'Point')
muscleGain = [fitVals.muscleFull] - [fitVals.kinFull];
figure
histogram(muscleGain)