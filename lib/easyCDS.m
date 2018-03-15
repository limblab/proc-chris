function [ cds ] = easyCDS( monkey, task, date,  arrays, numbers, areSorted)
    if ischar(arrays)
        rawPath = getRawPath(monkey, date, getTask(task));
        nevName = getNameNEV(monkey, date, task, arrays, numbers, areSorted);
        mapPath = ['mapFile',getArrayMap(monkey, arrays)];
        taskCDS = ['task', getTask(task)];
        monkeyCDS =['monkey',monkey];
        ranBy = ['ranByChris'];
        arrayCDS = ['array',arrays];
        labCDS = 6;
        cds = commonDataStructure();
        cds.file2cds([rawPath,nevName],labCDS,arrayCDS,monkeyCDS,taskCDS,ranBy,mapPath,'ignoreJumps')
    elseif iscell(arrays)
        rawPath = getRawPath(monkey, date);
        cds = commonDataStructure();
        for arrayNum = 1:length(arrays)
            rawPath = getRawPath(monkey, date, getTask(task));
            nevName = getNameNEV(monkey, date, task, arrays{arrayNum}, numbers, areSorted(arrayNum));
            mapPath = ['mapFile', getArrayMap(monkey, arrays{arrayNum})];
            taskCDS = ['task', getTask(task)];
            monkeyCDS =['monkey',monkey];
            ranBy = ['ranByChris'];
            arrayCDS = ['array',arrays{arrayNum}];
            labCDS = 6;
            cds.file2cds([rawPath,nevName],labCDS,arrayCDS,monkeyCDS,taskCDS,ranBy,mapPath,'ignoreJumps')
        end
    else
        error('Doesnt make a cds')
    end
end

