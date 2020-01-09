function td = getTD(monkey, date, task, number)
    if nargin <4
        numberStr = '';
    else
        numberStr = ['_', sprintf('%03d',number)];
    end
    path1 = getTDSavePath(monkey, date, getGenericTask(task));
    if isempty(numberStr)
        load([path1, monkey, '_', task, '_', date, '_TD.mat']);
        disp(['loaded',  [path1, monkey, '_', task, '_', date, '_TD.mat']])
    else
        load([path1, monkey, '_', task, '_', date, '_TD', numberStr, '.mat']);
        disp(['loaded',  [path1, monkey, '_', task, '_', date, '_TD', numberStr, '.mat']])
    end
    if exist('trial_data')
        td = trial_data;
    end

end