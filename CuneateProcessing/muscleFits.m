ex=experiment();
%configure the parameters we want to load into the experiment:
ex.meta.hasLfp=false;
ex.meta.hasKinematics=true;
ex.meta.hasForce=true;
ex.meta.hasUnits=true;
ex.meta.hasTrials=true;
%load data from cds to experiment
ex.addSession(cds)
%% change the units if you want to:
%ex.units.deleteInvalid
%ex.units.removeSorting
%% set configuration parameters for computing firing rate:
ex.firingRateConfig.cropType='tightCrop';
ex.firingRateConfig.offset=-0;
%ex.firingRateConfig.lags=[-2 3];
%firing rate may be computed directely by using ex.calcFR, or will be
%computed on the fly when ex.binData is called

%% configure bin parameters:
% set binConfig parameters:
ex.binConfig.include(1).field='units';
ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
ex.binConfig.include(2).field='kin';
    ex.binConfig.include(2).which={};%empty gets you all columns, a cell array of strings only pulls the columns with the specified labels
ex.binConfig.include(3).field='force';
    ex.binConfig.include(3).which={};

%% bin the data:
    ex.binData()
%% Do analysis

motionTrack = cds.analog{1,2};
binned = ex.bin.data;
units = table2array(binned(:,16:end));
downMotion = downsample(motionTrack, 5);

cols = downMotion.Properties.VariableNames;


dofsToFit = {'shoulder_adduction', 'shoulder_rotation', 'shoulder_flexion',...
    'elbow_flexion','radial_pronation', 'wrist_flexion', 'wrist_abduction'};

musclesToFit = cols(9:end);

fitData = zscore(downMotion{1:end-1, [musclesToFit]});
for i = 1:length(units(1,:))
    disp(['Unit ', i])
    fit = cvglmnet(fitData, units(:,i), 'poisson');
    fitCell{i}= fit;
end

%%
for i = 1:length(units(1,:))
    fit1 = fitCell{i};
    sparseLambda = fit1.lambda_1se;
    sparseInd = find([fit1.lambda] == sparseLambda);
    figure
    cvglmnetPlot(fit1)
end