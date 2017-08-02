%% Data Prep
load('C:\Users\csv057\Documents\MATLAB\MonkeyData\CDS\Lando\20170511\TD\Lando_RW_20170511_TD.mat')
load('Lando_RW_20170511_2_CDS.mat')
savePath = 'C:\Users\csv057\Documents\MATLAB\GLMFits\20170511\';
td = binTD(td, 5);

binned1 = cat(1, td.RightCuneate_spikes);
binned2 = cat(1, td.LeftS1_spikes);
binned = [binned1, binned2];
motionTrack = cat(1, td.opensim);
handleKin = cat(1, td.pos);

vel = cat(1, td.vel);

musclesToFit = 1:39;
dofsToFit = 40:46;

fitData = [(motionTrack(:, [dofsToFit])), (gradient(motionTrack(:, [dofsToFit])))];
fitData1 = [(motionTrack(:, [musclesToFit])),(gradient(motionTrack(:,[musclesToFit])))];
fitData2 =  [fitData, fitData1];

[temp1, muscleNames1, temp2]= xlsread('C:\Users\csv057\Documents\MATLAB\MonkeyData\Motion Tracking\20170511\Processed\Lando_20170511_RW_LeftS1_002-sorted_MuscleAnalysis_Length.xlsx', 'B12:AN12');
muscleNames = [muscleNames1, strcat(muscleNames1, '_v')];
%% Stepwise GLM for Muscle Velocities
for i = 1:length(binned1(1,:))
    firing = smooth(binned1(:,i));
    disp(['Unit ', num2str(i), ' Velocity'])
    mdl= stepwiseglm(fitData1, firing, 'constant', 'upper', 'linear', 'Distribution', 'poisson');
    [~, nullDev, nullMdl] = glmfit(zeros(length(firing),1), firing,'poisson');
    mdlCellVel{i}= mdl;
    pseudoR2Muscle(i) = 1-(mdl.Deviance/nullDev);
end
save([savePath, 'Lando20170511RWCuneateStepwiseGLM.mat'], 'mdlCellVel');
%% asdf
for i = 1:length(binned2(1,:))
    firing = smooth(binned2(:,i));
    disp(['Unit ', num2str(i), ' Velocity'])
    mdlS1= stepwiseglm(fitData1, firing, 'constant', 'upper', 'linear', 'Distribution', 'poisson');
    mdlS1CellVel{i}= mdlS1;
    [~, nullDev, nullMdl] = glmfit(zeros(length(firing),1), firing,'poisson');
    pseudoR2S1Muscle(i) = 1-(mdlS1.Deviance/nullDev);
end
save([savePath, 'Lando2017511RWS1StepwiseGLM.mat'], 'mdlS1CellVel');

%% Simple Sensor Model
fitData3= fitData1;
fitData3(fitData3(:,40:end)<0) = 0;
for i = 1:length(binned1(1,:))
    firing = smooth(binned1(:,i));
    disp(['Unit ', num2str(i), ' Velocity'])
    mdl= stepwiseglm(fitData3, firing, 'constant', 'upper', 'linear', 'Distribution', 'poisson');
    [~, nullDev, nullMdl] = glmfit(zeros(length(firing),1), firing,'poisson');
    mdlSensorCellVel{i}= mdl;
    pseudoR2MuscleSensor(i) = 1-(mdl.Deviance/nullDev);
end
save([savePath, 'Lando20170511RWCuneateStepwiseGLMSensorModel.mat'], 'mdlSensorCellVel')

%% Opposite Sensor Model
%% Stepwise GLM for DoF Vels
for i = 1:length(binned1(1,:))
    firing = smooth(binned1(:,i));
    disp(['Unit ', num2str(i), ' DoF Velocity'])
    mdl= stepwiseglm(fitData, firing, 'constant', 'upper', 'linear', 'Distribution', 'poisson');
    [~, nullDev, nullMdl] = glmfit(zeros(length(firing),1), firing,'poisson');
    mdlCellDoFVel{i}= mdl;
    pseudoR2DoFs(i) = 1-(mdl.Deviance/nullDev);

end
save([savePath, 'Lando20170511RWDoFVelCuneateStepwiseGLM.mat'], 'mdlCellDoFVel');
for i = 1:length(binned2(1,:))
    firing = smooth(binned2(:,i));
    disp(['Unit ', num2str(i), ' DoF Velocity'])
    mdlS1= stepwiseglm(fitData, firing, 'constant', 'upper', 'linear', 'Distribution', 'poisson');
    mdlS1CellDoFVel{i}= mdlS1;
    [~, nullDev, nullMdl] = glmfit(zeros(length(firing),1), firing,'poisson');
    pseudoR2S1DoFs(i) = 1-(mdlS1.Deviance/nullDev);
end
save([savePath, 'Lando20170511RWDoFVelS1StepwiseGLM.mat'], 'mdlS1CellDoFVel');


%% Analysis (Muscles)
close all
for i = 1:length(mdlS1CellVel)
    numS1VelParams(i) = mdlS1CellVel{i}.NumCoefficients;
    r2S1VelParams(i) = mdlS1CellVel{i}.Rsquared.Ordinary;
end
for i = 1:length(mdlCellVel)
    numCuneateVelParams(i) = mdlCellVel{i}.NumCoefficients;
    r2CuneateVelParams(i) = mdlCellVel{i}.Rsquared.Ordinary;
end
figure
histogram(numS1VelParams, 7, 'Normalization', 'Probability')
hold on
histogram(numCuneateVelParams, 7, 'Normalization', 'Probability');
title('Number of Significant Muscle Parameters Retained in Stepwise Regression')
xlabel('Number of Parameters')
ylabel('# of Units')
legend('S1 Muscles', 'Cuneate Muscles')
hold off

figure
histogram(pseudoR2S1Muscle, 7, 'Normalization', 'Probability')
hold on
histogram(pseudoR2Muscle,7, 'Normalization', 'Probability');
title('R2 of Prediction using Muscle Params')
xlabel('Adjusted R2 Values')
ylabel('# of Units')
legend('S1 PseudoR2', 'Cuneate Pseudo R2')
hold off

for i = 1:length(mdlS1CellDoFVel)

    numS1DoFVelParams(i) = mdlS1CellDoFVel{i}.NumCoefficients;
    r2S1DoFVelParams(i) = mdlS1CellDoFVel{i}.Rsquared.Adjusted;
end
for i = 1:length(mdlCellDoFVel)
    numCuneateDoFVelParams(i) = mdlCellDoFVel{i}.NumCoefficients;
    r2CuneateDoFVelParams(i) = mdlCellDoFVel{i}.Rsquared.Adjusted;
end
figure
histogram(numS1DoFVelParams, 'Normalization', 'Probability')
hold on
histogram(numCuneateDoFVelParams, 'Normalization', 'Probability');
title('Number of Significant DoF Parameters Retained in Stepwise Regression')
xlabel('Number of Parameters')
ylabel('# of Units')
legend('S1 DoF Prediction', 'Cuneate DoF Prediction')
hold off

figure
histogram(pseudoR2S1DoFs, 7, 'Normalization', 'Probability')
hold on
histogram(pseudoR2DoFs,7, 'Normalization', 'Probability');
title('R2 of Prediction using DoF Params')
xlabel('Adjusted R2 Values')
ylabel('# of Units')
legend('S1 PseudoR2', 'Cuneate PseudoR2')
hold off

for i= 1:length(mdlS1CellVel)
    musclesS1{i} = muscleNames(mdlS1CellVel{i}.VariableInfo.InModel);
end
for i = 1:length(mdlCellVel)
    musclesCuneate{i} = muscleNames(mdlSensorCellVel{i}.VariableInfo.InModel);
end
 
for i =1:length(mdlCellVel)
    numCuneateModelVelParams(i) = mdlSensorCellVel{i}.NumCoefficients;
    r2CuneateModelVelParams(i) = mdlSensorCellVel{i}.Rsquared.Adjusted;
end

figure
histogram(numCuneateModelVelParams, 7, 'Normalization', 'Probability')
hold on
histogram(numCuneateVelParams,7, 'Normalization', 'Probability');
title('Effect of Simple Sensor Model on # Significant Params')
xlabel('Number of Parameters')
ylabel('# of Units')
legend('Cuneate With Sensor Model', 'Cuneate No Sensor Model')
hold off

figure
histogram(pseudoR2MuscleSensor,7, 'Normalization', 'Probability')

hold on
histogram(pseudoR2Muscle,7, 'Normalization', 'Probability')
title('Effect on R2 of Prediction using Sensor Model')
xlabel('Adjusted R2 Values')
ylabel('# of Units')
legend('Cuneate With Sensor Model', 'Cuneate No Sensor Model')
hold off
