compName = getenv('computername');
if strcmp(compName, 'FSM8M1SMD2')
    addpath(genpath('C:\Users\csv057\Documents\Git\ClassyDataAnalysis\'));
    addpath(genpath('C:\Users\csv057\Documents\Git\proc-chris\'));
    addpath(genpath('C:\Users\csv057\Documents\Git\TrialData\'));
    addpath(genpath('C:\Users\csv057\Documents\MATLAB\glmnet_matlab\'));
    addpath(genpath('C:\Users\csv057\Documents\Git\KinectTracking\'));
elseif strcmp(compName, 'DESKTOP')
    addpath(genpath('C:\Users\wrest_000\Documents\Github\ClassyDataAnalysis\'));
    addpath(genpath('C:\Users\wrest_000\Documents\Github\proc-chris\'));
    addpath(genpath('C:\Users\wrest_000\Documents\Github\TrialData\'));
    addpath(genpath('C:\Users\wrest_000\Documents\Github\KinectTracking\'));
    addpath(genpath('C:\Users\wrest_000\Documents\Github\proc-raeed\'));
else
    error('This is not a supported computer');
end
