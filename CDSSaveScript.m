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
%   date : in string format
%
% This function will save a cds with the appropriate name on the correct
% folder in your filepath
% Note: these functions will only work if you have your files saved in the
% correct folders with the correct names:
% The filename of the .nev should be monkey_date_task_array_number
%% All of the loading variables

date = '20170917';
task = 'COactpas';
monkey = 'Lando';
array = {'area2', 'cuneate'};

number = 1;

sorted = [false,true];
suffix = 'resort';
makeFileStructure(monkey, date, getGenericTask(task));

%%
motionTrack = false;

if sorted(1)
    srtStr = 'sorted-resort';
else
    srtStr = 'unsorted';
end

if motionTrack
    first_time = true;
        motionTrackPath = [getBasicPath(monkey, date, getGenericTask(task)), 'MotionTracking', filesep];
        motionTrackName = getMotionTrackName(monkey, date, getGenericTask(task), number);
        load([motionTrackPath, motionTrackName])
        color_tracker_4colors_script;
end

%% Generate CDS using easyCDS
cds = easyCDS(monkey, task, date, array, number, sorted);
% compute the outpath depending on what computer you are using and the task
outpath = getCdsSavePath(monkey, date, getGenericTask(task));
makeFileStructure(monkey, date, getGenericTask(task));

% compose the filename
cdsPath = [outpath,monkey, '_', task, '_', date,'_',num2str(number), '_CDS_',suffix '.mat'];
%save the cds to the folder
save(cdsPath, 'cds', '-v7.3');
%%
td = easyTD(cdsPath, monkey, task, date);
tdPath = getTDSavePath(monkey, date, getGenericTask(task));
save([tdPath,monkey, '_', task, '_', date,'_',num2str(number), '_TD_','_',suffix, '.mat'], 'td');
