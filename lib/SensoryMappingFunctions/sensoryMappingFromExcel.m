function mapping =  sensoryMappingFromExcel(path, array, monkey)

    mapping = getSensoryMappings(monkey);
    prevMappedDates = unique({mapping.date});
    [num, txt, raw] = xlsread(path, ['sensoryMappings', array]);
    colsToRemove = [];
    for i = 2:length(raw(1, :))
        if isnan(raw{1, i})
            colsToRemove = [colsToRemove, i];
        end
    end
    raw(:, colsToRemove) = [];
    channels =  [raw{2:end,1}];
    dates = raw(1, 2:end);
    mappingNew = struct('date', [], 'chan', [], 'id',  [], 'pc', [], 'desc', [], 'spindle', []); 
    prevInds = [];
    for i = 1:length(dates)
        for j = 1:length(prevMappedDates)
            if strcmp(dates{i}, prevMappedDates{j})
                prevInds = [prevInds,i];
            end
        end
    end
    dates(prevInds) = [];
    count = length(prevInds);
    for i = 1:length(dates)
        for j = 1:length(channels)
            if ~isnan(raw{j+1, i+1+count})
                unit.date = dates{i};
                unit.chan = channels(j);
                unit.id = 1;
                disp(raw{j+1, i+1+count})
                unit.pc = input('P or C?', 's');
                unit.spindle = strcmp(input('Spindle? y for yes:\n ', 's'), 'y');
                unit.desc = raw{j+1, i+1+count};
                mappingNew = [mappingNew, unit];
            end
            
        end
    end
    mappingNew(1) = [];
    mappingNew = findHandCutaneousUnits(mappingNew);
    mappingNew = findProximalArm(mappingNew);
    mappingNew = findMiddleArm(mappingNew);
    mappingNew = findDistalArm(mappingNew);
    mapping = [mapping; mappingNew];
end