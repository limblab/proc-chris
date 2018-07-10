function fh1 = processMovementBumps(td,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %   Detailed explanation
    cutoff = pi/4;
    arrays= {'LeftS1', 'RightCuneate'};
    windowAct= {'idx_movement_on', 0; 'idx_endTime',0};
    windowPas ={'idx_bumpTime',-2; 'idx_bumpTime',2};
    distribution = 'normal';
    train_new_model = true;
    cuneate_flag = true;
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    if(td(1).bin_size == .01)
        tdBin = binTD(td,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end
    
    tdBump = td(~isnan([td.bumpDir])); 
    
    tdAct = trimTD(tdBin, windowAct(1,:), windowAct(2,:));
    tdPas = trimTD(tdBump, windowPas(1,:), windowPas(2,:));
    
    plotRasters = 1;
savePlots = 1;
params.event_list = {'bumpTime'; 'bumpDir'};
params.extra_time = [.4,.6];
params.include_ts = true;
params.include_start = true;
td = parseFileByTrial(cds, params);
td = td(~isnan([td.target_direction]));
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getMoveOnsetAndPeak(td, params);

date = 03202017;
unitNames = 'RightCuneate';
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

w = gausswin(5);
w = w/sum(w);


numCount = 1:length(td(1).(unitSpikes)(1,:));
%% Data Preparation and sorting out trials

bumpTrials = td(~isnan([td.bumpDir])); 
upMove = td([td.target_direction] == pi/2 );
leftMove = td([td.target_direction] ==pi);
downMove = td([td.target_direction] ==3*pi/2);
rightMove = td([td.target_direction]==0);

upBump = bumpTrials([bumpTrials.bumpDir] == 90);
downBump = bumpTrials([bumpTrials.bumpDir] == 270);
leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
rightBump = bumpTrials([bumpTrials.bumpDir] == 0);


%% Creating the structure for my lower function
%The way this structure works is that it's a 4x4 cell array with the rows
%being the move directions while the cols are the bump direction.
% The order is rightUpLeftDown
rightUpLeftDown{1,1} = rightBump([td.target_direction] == 0);
rightUpLeftDown{1,2} = upBump([td.target_direction] == 0);
rightUpLeftDown{1,3} = leftBump([td.target_direction] == 0);
rightUpLeftDown{1,4} = downBump([td.target_direction] == 0);

rightUpLeftDown{2,1} = rightBump([td.target_direction] == pi/2);
rightUpLeftDown{2,2} =  upBump([td.target_direction] == pi/2);
rightUpLeftDown{2,3} = leftBump([td.target_direction] == pi/2);
rightUpLeftDown{2,4}=downBump([td.target_direction] == pi/2);

rightUpLeftDown{3,1}=rightBump([td.target_direction] == pi);
rightUpLeftDown{3,2}=upBump([td.target_direction] == pi);
rightUpLeftDown{3,3}=leftBump([td.target_direction] == pi);
rightUpLeftDown{3,4}=downBump([td.target_direction] == pi);

rightUpLeftDown{4,1}= rightBump([td.target_direction] == 3*pi/2);
rightUpLeftDown{4,2}= upBump([td.target_direction] == 3*pi/2);
rightUpLeftDown{4,3}=leftBump([td.target_direction] == 3*pi/2);
rightUpLeftDown{4,4}=downBump([td.target_direction] == 3*pi/2);

%% 
close all
for num1 = numCount
    params.neuron = num1;
    params.yMax = 40;
    params.align= 'bumpTime';
    params.xBound = [-.3, .3];
    params.array = unitNames;
    plotMoveBumps(rightUpLeftDown, params);
    
end

%% Short time


    
end

