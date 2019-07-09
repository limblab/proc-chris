% clear all
close all
clear all
plotRasters = 1;
savePlots = 1;
savePDF = true;
% 
% date = '20190129';
% monkey = 'Butter';
% unitNames = 'cuneate';

date = '20180530';
monkey = 'Butter';
unitNames= 'cuneate';

% mappingLog = getSensoryMappings(monkey);

before = .3;
after = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'COmoveBump',1);
td = getNorm(td,struct('signals','vel','field_extra','speed'));
startInd = 'idx_bumpTime';

target_direction = 'target_direction';
if length(td) == 1
    disp('Splitting')
    td = splitTD(td, struct('split_idx_name', 'idx_startTime', 'linked_fields', {{'bumpDir', 'ctrHold', 'ctrHoldBump', 'result', 'tgtDir', 'trialID'}} ));
    target_direction = 'tgtDir';
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    [~, td] = getTDidx(td, 'result' ,'R');
    td = getMoveOnsetAndPeak(td, params);
    td = removeBadTrials(td);
else
end
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getMoveOnsetAndPeak(td,params);

if td(1).bin_size ==.001
    td = binTD(td, 10);
end
td = td(~isnan([td.idx_movement_on]));
td = removeBadNeurons(td, struct('remove_unsorted', false));
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];

w = gausswin(5);
w = w/sum(w);


numCount = 1:length(td(1).(unitSpikes)(1,:));
%% Data Preparation and sorting out trials

dirsM = unique([td.(target_direction)]);
dirsM = dirsM(~isnan(dirsM));
bumpTrials = td(~isnan([td.bumpDir])); 
dirsBump = unique([td.bumpDir]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));

for i = 1:length(dirsM)
    for j= 1:length(dirsBump)
        tdDir{i,j} = td([td.(target_direction)] == dirsM(i)& [td.bumpDir] == dirsBump(j));
        tdPre{i,j} = trimTD(tdDir{i,j}, {'idx_bumpTime', -10}, {'idx_bumpTime', 0});
        tdDir{i,j} = trimTd({tdDir{i,j}, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
    end
end
maxSpeed = 60;
%% Iterate through neurons
for i = 1:numCount
    %% Calculate FR in reach direction before bump
    
    %% Calulate FR after an assitive bump
    
    %% Calculate FR after a resistive bump
    
    %% Calulate FR after a perpendicular bump
    
    %% Calulate difference for each neuron (resistive, assistive, perpendicular)
    
    %% Look only at preferred direction of active reaches
    
end