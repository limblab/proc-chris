function td = addNaming(td, cds)
    arrays = {'cuneate','area2'};
    for array = 1:length(arrays)
    chanNames = cds.units(~cellfun(@isempty,([strfind({cds.units.array},arrays{array})])));
    sortedUnits = chanNames(find( strcmpi({chanNames.array},arrays{array})));
    elecNames = unique([sortedUnits.chan], 'stable');
    screenNames = {sortedUnits.label};
    labelNames = zeros(length(sortedUnits),1);
    for i= 1:length(sortedUnits)
       labelNames(i) = str2num(screenNames{i}(5:end)); 
    end
    labels = unique(labelNames,'stable');

    conversion{array} = [elecNames', labels];
    for i = 1:length(td)
        td(i).([arrays{array},'_naming']) = conversion{array};
    end

    end
end