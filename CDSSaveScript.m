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

date = '20180326';
task = 'CO';
monkey = 'Butter';
array = 'cuneate';
number = 1;
sorted = true;

makeFileStructure(monkey, date, getGenericTask(task));

if sorted
    srtStr = 'sorted';
else
    srtStr = 'unsorted';
end


%% Generate CDS using easyCDS
cds = easyCDS(monkey, task, date, array, number, sorted);
% compute the outpath depending on what computer you are using and the task
outpath = getCdsSavePath(monkey, date, getTask(task));
% compose the filename
cdsPath = [outpath,monkey, '_', task, '_', date,'_',num2str(number), '_CDS_', srtStr, '.mat'];
% make the directory (if it doesnt exist)
makeFileStructure(monkey, date, task);
%save the cds to the folder
save(cdsPath, 'cds', '-v7.3');