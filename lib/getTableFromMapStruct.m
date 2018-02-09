function mapTable = getTableFromMapStruct(mapping)
    fields = fieldnames(mapping);
    for i = 1:numel(fieldnames(mapping))
        dateTemp = fields{i};
        date = dateTemp(8:end);
        mapStruct = struct2table(mapping.(dateTemp));
        mapTable = [repmat(date, height(mapStruct)), mapStruct];
    end
end