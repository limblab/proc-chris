for i =12
    [td, ~, num] = getPaperFiles(i);
    monkey = td(1).monkey;
    date = dateToLabDate(td(1).date);
    task = td(1).task;
    tdPath = getTDSavePath(monkey, date, getGenericTask(task));
    td = tdToBinSize(td, 10);
    save([getBasePath(), getGenericTask(task), filesep, monkey, filesep, date, filesep, 'TD', filesep, monkey, '_', getGenericTask(task), '_', date, '_TD_',sprintf('%03d',num),'10ms.mat'], 'td');

end