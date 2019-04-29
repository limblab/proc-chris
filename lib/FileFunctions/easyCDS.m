function [ cds ] = easyCDS( monkey, task, date,  arrays, numbers, areSorted)
% easyCDS is the helper function called by CDSSaveScript. It generates
% the paths needed and loads the files into the CDS to pass back to
% CDSSaveScript
%     
% Inputs :
%    monkey: monkey name as a string
% 
%   task: task name in input file (whatever you call your nev) 
%
%   date: date that you ran it as a string
% 
%   arrays: either a string with your array name, or a cell array of
%   strings with you arrays
% 
%   numbers: either an int or a cell array of ints (one for each array)
% 
%   areSorted: either a boolean or a cell array of booleans(one for each
%   array)
% 
% Outputs:
%   cds: the compiled CDS
    % if you have only one array

    if ischar(arrays)
        %% Preprocessing
        % get the raw path to the file (assuming correct folder structure)
        rawPath = getRawPath(monkey, date, getGenericTask(task));
        % compose the name of the file (assuming correct naming convention)
        nevName = getNameNEV(monkey, date, task, arrays, numbers, areSorted);
        % Get the path the the array map (system dependent)
        mapPath = ['mapFile',getArrayMap(monkey, arrays)];
        % Get the correct task format based on the input task (eg. CoBump
        % to COBump)
        taskCDS = ['task', getTask(task)];
        monkeyCDS =['monkey',monkey];
        ranBy = ['ranByChris'];
        arrayCDS = ['array',arrays];
        if strcmp(taskCDS, 'taskWF')
            labCDS = 1;
        else
            labCDS = 6;
        end
        %% Get the cds
        cds = commonDataStructure();
        if ~strcmp(taskCDS, 'taskUnknown')
            cds.file2cds([rawPath,nevName],labCDS,arrayCDS,monkeyCDS,taskCDS,ranBy,mapPath,'ignoreJumps')
        else
            cds.file2cds([rawPath,nevName],labCDS,arrayCDS,monkeyCDS,taskCDS,ranBy,mapPath,'ignoreJumps', 'unsanitizedTimes')
        end
    elseif iscell(arrays) % if you have more than one array
        %% Preprocessing
        rawPath = getRawPath(monkey, date, getGenericTask(task));
        cds = commonDataStructure();
        %% iterate through arrays
        for arrayNum = 1:length(arrays)
            %% Array specific preprocessing
            rawPath = getRawPath(monkey, date, getGenericTask(task));
            nevName = getNameNEV(monkey, date, task, arrays{arrayNum}, numbers, areSorted(arrayNum));
            mapPath = ['mapFile', getArrayMap(monkey, arrays{arrayNum})];
            taskCDS = ['task', getTask(task)];
            monkeyCDS =['monkey',monkey];
            ranBy = ['ranByChris'];
            arrayCDS = ['array',arrays{arrayNum}];
            if strcmp(taskCDS, 'taskWFH') | strcmp(taskCDS, 'taskWF')
                labCDS = 1;
            else
                labCDS = 6;
            end
            %% Get the cds (or add next array)
            cds.file2cds([rawPath,nevName],labCDS,arrayCDS,monkeyCDS,taskCDS,ranBy,mapPath,'ignoreJumps')
        end
    else
        error('Does not make a cds')
    end

end

