function neurons1 = loadAnalysis(td, type)
    path = getPathFromTD(td);
    nPath = [path, filesep, 'neuronStruct', filesep, type, filesep];
    name = [td(1).monkey, '_', td(1).date, '_', td(1).task, '_',type,'.mat'];
    if exist([nPath,name])~=2
        neurons1 =[];
    else
        load([nPath, name])
    end
end