% clear all
close all
% clearvars -except cds
% load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 1;
params.event_list = {'bumpTime'; 'bumpDir'};
params.extra_time = [.4,.6];
params.include_ts = true;
params.include_start = true;
params.include_naming = true;
td = parseFileByTrial(cds, params);
td = td(~isnan([td.target_direction]));
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getMoveOnsetAndPeak(td, params);

date = 03222018;
unitNames = 'cuneate';
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

w = gausswin(5);
w = w/sum(w);


numCount = 1:length(td(1).(unitSpikes)(1,:));
td([1,2,12]) = [];
%% Data Preparation and sorting out trials

bumpTrials = td(~isnan([td.bumpDir])); 
upMove = td([td.target_direction] == pi/2 );
leftMove = td([td.target_direction] ==pi);
downMove = td([td.target_direction] ==3*pi/2);
rightMove = td([td.target_direction]==0);


upBump = bumpTrials([bumpTrials.bumpDir] == 90 );
leftBump = bumpTrials([bumpTrials.bumpDir] ==180);
downBump = bumpTrials([bumpTrials.bumpDir] ==270);
rightBump = bumpTrials([bumpTrials.bumpDir]==0);

upMoveCut = trimTD(upMove, {'idx_movement_on',-5}, {'idx_movement_on', 15});
downMoveCut = trimTD(downMove, {'idx_movement_on',-5}, {'idx_movement_on', 15});
leftMoveCut = trimTD(leftMove, {'idx_movement_on',-5}, {'idx_movement_on', 15});
rightMoveCut = trimTD(rightMove, {'idx_movement_on',-5}, {'idx_movement_on', 15});

upBumpCut = trimTD(upBump, {'idx_bumpTime',-5}, {'idx_bumpTime', 15});
downBumpCut = trimTD(downBump, {'idx_bumpTime',-5}, {'idx_bumpTime', 15});
rightBumpCut = trimTD(rightBump, {'idx_bumpTime',-5}, {'idx_bumpTime', 15});
leftBumpCut = trimTD(leftBump, {'idx_bumpTime',-5}, {'idx_bumpTime', 15});

plotTrialKinematics(upMoveCut)
title('upMove')

plotTrialKinematics(downMoveCut)
title('downMove')

plotTrialKinematics(leftMoveCut)
title('leftMove')

plotTrialKinematics(rightMoveCut)
title('rightMove')

plotTrialKinematics(upBumpCut)
title('upBump')

plotTrialKinematics(downBumpCut)
title('downBump')

plotTrialKinematics(leftBumpCut)
title('leftBump')

plotTrialKinematics(rightBumpCut)
title('rightBump')



