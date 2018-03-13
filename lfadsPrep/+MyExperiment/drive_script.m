%% Generate synthetic Lorenz datasets, 

% build the dataset collection
load('/media/chris/HDD/Data/MonkeyData/Lando/CO/20170320/TD/Lando_COactpas_20170320_001_TD_noMotionTracking.mat')
params.monkey = 'Lando';
params.date = '20170320';
params.runName = 'MultiMonkey StitchingV2 S1 CoBump1';
datasetPath = saveLFADSdatasets(td, params);

load('/media/chris/HDD/Data/MonkeyData/Chips/CO/20171116/TD/Chips_COactpas_20171116_001_TD.mat')
params.monkey = 'Chips';
params.date = '20171116';
datasetPath = saveLFADSdatasets(td, params);
% generate demo datasets

load('/media/chris/HDD/Data/MonkeyData/Han/20160415/TD/Han_CObump_20160415_001_TD.mat')
params.monkey= 'Han';
params.date = '20160415';
datasetPath= saveLFADSdatasets(td, params);


%% Locate and specify the datasets
dc = MyExperiment.DatasetCollection(datasetPath);
dc.name = 'MultiMonkeyStitchingS1CoBumpCorrect1';

% add individual datasets
MyExperiment.Dataset(dc, 'Han_20160415_td_peak.mat');
MyExperiment.Dataset(dc, 'Chips_20171116_td_peak.mat');
MyExperiment.Dataset(dc, 'Lando_20170320_td_peak.mat');


dc.datasets(1,1).comment = 'Han data binned +/- 200 ms around peak';
dc.datasets(2,1).comment = 'Chips data binned +/- 200 ms around peak';
dc.datasets(3,1).comment = 'Lando data binned +/- 200 ms around peak';


%% Build RunCollection
% Run a single model for each dataset, and one stitched run with all datasets

runRoot = '~/Documents/MATLAB/';
rc = MyExperiment.RunCollection(runRoot, 'MultiArea2ModelV7', dc);

% replace this with the date this script was authored as YYYYMMDD ;
% This ensures that updates to lfads-run-manager won't invalidate older 
% runs already on disk and provides for backwards compatibility
rc.version = 20180309;

%% Set parameters for the entire run collection

par = MyExperiment.RunParams;
par.spikeBinMs = 10; % rebin the data at 2 ms
par.c_co_dim = 2; % no controller --> no inputs to generator
par.c_batch_size = 50; % must be < 1/5 of the min trial count
par.c_factors_dim = 8; % and manually set it for multisession stitched models
par.useAlignmentMatrix = true; % use alignment matrices initial guess for multisession stitching

par.c_gen_dim = 64; % number of units in generator RNN
par.c_ic_enc_dim = 64; % number of units in encoder RNN

par.c_learning_rate_stop = 1e-3; % we can stop really early for the demo

% add a single set of parameters to this run collection. Additional
% parameters can be added. LFADS.RunParams is a value class, unlike the other objects
% which are handle classes, so you can modify par freely.
rc.addParams(par);

%% Add RunSpecs

% Run a single model for each dataset, and one stitched run with all datasets

% add each individual run
% for iR = 2
%     runSpec = MyExperiment.RunSpec(dc.datasets(iR).getSingleRunName(), dc, dc.datasets(iR).name);
%     rc.addRunSpec(runSpec);
% end

% add the final stitching run with all datasets
rc.addRunSpec(MyExperiment.RunSpec('all', dc, 1:dc.nDatasets));
% adding a return here allows you to call this script to recreate all of
% the objects here for subsequent analysis after the actual LFADS models
% have been trained. The code below will setup the LFADS runs in the first
% place.


%% Prepare LFADS input

% generate all of the data files LFADS needs to run everything
rc.prepareForLFADS();

% write a python script that will train all of the LFADS runs using a
% load-balancer against the available CPUs and GPUs
rc.writeShellScriptRunQueue('display', 50, 'maxTasksSimultaneously', 4, 'gpuList', [0], 'virtualenv', 'tensorflow');

