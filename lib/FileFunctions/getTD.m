function [td, path2] = getTD(monkey, date1, task, number, tenMs, resort)
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
    if nargin >5
        if isempty(resort)
            resort = '';
        else
            resort = 'resort';
        end
    else
        resort = '';
    end
    
    path1 = getTDSavePath(monkey, date1, getGenericTask(task));
    if isempty(numberStr)
        load([path1, monkey, '_', task, '_', date1, '_TD', binstr, resort,'.mat']);
        disp(['loaded',  [path1, monkey, '_', task, '_', date1, '_TD', binStr, '.mat']])
        path2 = [path1, monkey, '_', task, '_', date1, '_TD', binStr];
    else
        load([path1, monkey, '_', task, '_', date1, '_TD', numberStr,binStr,resort, '.mat']);
        disp(['loaded',  [path1, monkey, '_', task, '_', date1, '_TD', numberStr,binStr,resort, '.mat']])
        path2 = [path1, monkey, '_', task, '_', date1, '_TD', numberStr,binStr];
    end
    if exist('trial_data')
        td = trial_data;
    end

end