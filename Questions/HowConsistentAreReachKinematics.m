%% Load all files for comparison
clear all
monkey = 'Butter';
date = '20180607';
mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, 'CO');
