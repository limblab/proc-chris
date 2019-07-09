function cds = getCDS(monkey, task, date)
    path = [getBasicPath(monkey,date, task), filesep, 'CDS', filesep];
    files = dir(path);
    files = files(3:end);
    file = files(contains(files.name, '_CDS.mat'));
    load([path, file.name]);
end