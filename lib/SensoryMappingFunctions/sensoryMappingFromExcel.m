function mapping =  sensoryMappingFromExcel(path, array)
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
    mapping = struct('date', [], 'chan', [], 'id',  [], 'pc', [], 'desc', [], 'spindle', []); 
    count = 1;
    for i = 1:length(dates)
        for j = 1:length(channels)
            if ~isnan(raw{j+1, i+1})
                unit.date = dates{i};
                unit.chan = channels(j);
                unit.id = 1;
                disp(raw{j+1, i+1})
                unit.pc = input('P or C?', 's');
                unit.spindle = strcmp(input('Spindle? y for yes', 's'), 'y');
                unit.desc = raw{j+1, i+1};
                mapping = [mapping, unit];
            end
            
        end
    end
        
end