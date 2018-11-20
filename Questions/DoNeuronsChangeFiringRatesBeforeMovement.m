%% Load all files for comparison
clear
close all
% monkey = 'Lando';
% date = '20170223';
% array = 'LeftS1';
% task = 'RW';
% params.doCuneate = false;
% 
monkey = 'Butter';
date = '20180607';
array = 'cuneate';
task = 'CO';
params.doCuneate = true;

mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, task);
tdButter = smoothSignals(tdButter, struct('signals', 'cuneate_spikes'));

%%

tdCP = changePointAnalysisTD(tdButter, struct('array', 'cuneate'));