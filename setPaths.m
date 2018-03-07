compName = getenv('computername');
arch = computer('arch');
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
elseif strcmp(compName, 'LAPTOP-DK2LKBEH')
    addpath(genpath('C:\Users\wrest\Documents\Github\ClassyDataAnalysis\'));
    addpath(genpath('C:\Users\wrest\Documents\Github\proc-chris\'));
    addpath(genpath('C:\Users\wrest\Documents\Github\TrialData\'));
    addpath(genpath('C:\Users\wrest\Documents\Github\KinectTracking\'));
    addpath(genpath('C:\Users\wrest\Documents\Github\proc-raeed\'));
    addpath(genpath('C:\Users\wrest\Documents\MATLAB\MonkeyData\'));
elseif strcmp(arch, 'glnxa64')
    addpath(genpath('/home/chris/Documents/git/proc-chris/'));
    addpath(genpath('/home/chris/Documents/git/ClassyDataAnalysis/'));
    addpath(genpath('/home/chris/Documents/git/KinectTracking/'));
    addpath(genpath('/home/chris/Documents/git/lfads-run-manager/'));
    addpath(genpath('/home/chris/Documents/git/models/research/lfads/'));
    addpath(genpath('/home/chris/Documents/git/trialdata/'))
    addpath(genpath('/home/chris/Documents/git/proc-raeed/'))
    disp('Desktop paths loaded')
else
    error('This is not a supported computer');
end
