function td = getTD(monkey, date, task, number, tenMs)
    if nargin <4
        numberStr = '';
    else
        numberStr = ['_', sprintf('%03d',number)];
    end
    if nargin <5
        binStr = '';
    elseif isempty(tenMs)
        binStr = '';
    else
        binStr = [num2str(tenMs), 'ms'];
    end
    path1 = getTDSavePath(monkey, date, getGenericTask(task));
    if isempty(numberStr)
        load([path1, monkey, '_', task, '_', date, '_TD', binstr,'.mat']);
        disp(['loaded',  [path1, monkey, '_', task, '_', date, '_TD', binStr, '.mat']])
    else
        load([path1, monkey, '_', task, '_', date, '_TD', numberStr,binStr, '.mat']);
        disp(['loaded',  [path1, monkey, '_', task, '_', date, '_TD', numberStr,binStr, '.mat']])
    end
    if exist('trial_data')
        td = trial_data;
    end

end