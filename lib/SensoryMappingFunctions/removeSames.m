function mappings = removeSames(mappingLog)
    [~,index] = sortrows({mappingLog.date}.'); mappingLog = mappingLog(index); clear index
    removeInds = [];
    for i = 1:length(mappingLog)
        if contains(mappingLog(i).desc, 'same', 'IgnoreCase', true)
            mappingDate = mappingLog(mappingLog(i).chan == [mappingLog.chan] & mappingLog(i).id == [mappingLog.id]);
            mappingGD = find(str2double(string({mappingDate.date})) - str2double(mappingLog(i).date) <0,1, 'last');
            mappingLog(i).desc = replace(mappingLog(i).desc, 'same', mappingDate(mappingGD).desc);
            unitTemp = mappingDate(mappingGD);
            unitTemp.desc =replace(mappingLog(i).desc, 'same', mappingDate(mappingGD).desc);
            unitTemp.date = mappingLog(i).date;
            mappingLog(i) = unitTemp;
            
        elseif contains(mappingLog(i).desc, 'skip', 'IgnoreCase', true)
            removeInds = [removeInds, i];
        end
    end
    mappings= mappingLog;
    mappings(removeInds) = [];
end