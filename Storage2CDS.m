dirList = dir('\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\data\Lando_13B2\Raw');
% dirList = dir('C:\Users\csv057\Documents\MATLAB\MonkeyData\RawData\Butter\20180314\Sorted')
fileList = {dirList(~[dirList.isdir]).name};
expr = '(\w*)_(\d*)_(\w*)_(\w*)_(\d*)-sorted(\w*)';
fileParts = regexp(fileList, expr, 'tokens');
fileParts = fileParts(~cellfun(@isempty,fileParts));
for i  = 1:length(fileParts)
    fileArray(i,:) = fileParts{i}{1:7};
end
while ~isempty(fileArray)
    c = fileArray(1,:);    
    monkey = c{1};
    date = c{2};
    task = c{3};
    array= c{4};
    number = c{5};
    matching = unique(fileArray(strcmp(fileArray(:,1), monkey) & strcmp(fileArray(:,2),...
        date) & strcmp(fileArray(:,3), task) ...
        & strcmp(fileArray(:,5), number), 4));
    if ~isCDS(monkey, date, task, number)
        cds = commonDataStructure();
        arrays = matching;
        for arrayNum = 1:length(arrays)
            rawPath = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\data\Lando_13B2\Raw\';
            nevName = [getNameNEV(monkey, date, task, arrays{arrayNum}, number, 0), '-sorted'];
            mapPath = ['mapFile', getArrayMap(monkey, arrays{arrayNum})];
            taskCDS = ['task', getTask(task)];
            monkeyCDS =['monkey',monkey];
            ranBy = ['ranByChris'];
            arrayCDS = ['array',arrays{arrayNum}];
            labCDS = 6;
            cds.file2cds([rawPath,nevName],labCDS,arrayCDS,monkeyCDS,taskCDS,ranBy,mapPath,'ignoreJumps')
        end
        cdsSave(cds, monkey, date, task,number);
        clear cds
    else
        if length(matching)>1
            disp(['Skipped ', strjoin(getNameNEV(monkey, date, task, matching(1),number, true), ''), ' because CDS already created'])

        else
            disp(['Skipped ', strjoin(getNameNEV(monkey, date, task, matching,number, true), ''), ' because CDS already created'])
    
        end
    end
    fileArray(strcmp(fileArray(:,1), monkey) & strcmp(fileArray(:,2),...
        date) & strcmp(fileArray(:,3), task) ...
        & strcmp(fileArray(:,5), number), :) = [];
end 