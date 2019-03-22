% This is the script to save generic CDS based on the input information in
% the file header: Things that will have to change are:
%   monkey: 'Han', 'Lando', 'Butter' etc.
%   
%   task : Whatever the file name uses. The task for CDS loading is
%   automatically computed later
%   
%   array: The array that is being loaded. If there is more than a single
%   array, you can load all by making cell array of strings
%
%   number: the file # of the array 001, 002 etc.
%
%   date : in string format (yyyyMMdd)
%
% This function will save a cds with the appropriate name on the correct
% folder in your filepath
% Note: these functions will only work if you have your files saved in the
% correct folders with the correct names:
% The filename of the .nev should be monkey_date_task_array_number
%% All of the loading variables
clear all
close all
date = '20170917';
task = 'CO';
monkey = 'Lando';
array = 'cuneate';

number = 1;

sorted = true;
% suffix = 'resort';
makeFileStructure(monkey, date, getGenericTask(task));

%%
motionTrack = false;

if sorted(1)
    srtStr = 'sorted';
else
    srtStr = 'unsorted';
end


%% Generate CDS using easyCDS
cds = easyCDS(monkey, task, date, array, number, sorted);
% compute the outpath depending on what computer you are using and the task
outpath = getCdsSavePath(monkey, date, getGenericTask(task));
makeFileStructure(monkey, date, getGenericTask(task));
meta = cds.meta;

markersFilename = ['markers_', monkey, '_', date, '_', task,'.mat'];
opensimFilename = ['opensim_',monkey '_' date,'_',task, '.trc'];

%%

%%
if motionTrack
%     cds = easyCDS(monkey, task, date, array, number, sorted);

    first_time = true;
    motionTrackPath = [getBasicPath(monkey, date, getGenericTask(task)), 'MotionTracking', filesep];
    motionTrackName = getMotionTrackName(monkey, date, task, number);
    load([motionTrackPath, motionTrackName])
    color_tracker_4colors_script;
    affine_xform = cds.loadRawMarkerData(fullfile(getBasicPath(monkey, date, getGenericTask(task)),filesep,'MotionTracking',filesep,markersFilename));
    writeTRCfromCDS(cds,fullfile(getBasicPath(monkey, date, getGenericTask(task)),filesep,'MotionTracking',filesep, opensimFilename));
    writeHandleForceFromCDS(cds,fullfile('OpenSim',[monkey '_' date '_TRT_handleForce.mot']))

    % load joint information
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'joint_ang')

    % load joint velocities
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'joint_vel')

    % load joint moments
    % cds{fileIdx}.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'joint_dyn')

    % load muscle information
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'muscle_len')

    % load muscle velocities
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'muscle_vel')
    
    % load hand positions
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'hand_pos')
    
    % load hand velocities
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'hand_vel')
    
    % load hand accelerations
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'hand_acc')
        % load hand positions
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'elbow_pos')
    
    % load hand velocities
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'elbow_vel')
    
    % load hand accelerations
    cds.loadOpenSimData(fullfile(motionTrackPath,'OpenSim','Analysis'),'elbow_acc')

end


% compose the filename
cdsPath = [outpath,monkey, '_', task, '_', date,'_',num2str(number), '_CDS_.mat'];
%save the cds to the folder
save(cdsPath, 'cds', '-v7.3');
%%
td = easyTD(cdsPath, monkey, task, date);
tdPath = getTDSavePath(monkey, date, getGenericTask(task));
save([tdPath,monkey, '_', task, '_', date,'_TD_',sprintf('%03d',number),'.mat'], 'td','-v7.3');
disp('Done creating cds and saving TD');