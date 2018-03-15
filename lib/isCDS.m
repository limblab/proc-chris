function cdsExists = isCDS(monkey, date, task, number)
outpath = getCdsSavePath(monkey, date, getTask(task));
cdsPath = [outpath,monkey, '_', task, '_', date,'_',num2str(number), '_CDS.mat'];
cdsExists = exist(cdsPath) == 2;
end