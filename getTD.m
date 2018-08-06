function td = getTD(monkey, date, task)
    path1 = getTDSavePath(monkey, date, getGenericTask(task));
    load([path1, monkey, '_', task, '_', date, '_TD.mat']);
end