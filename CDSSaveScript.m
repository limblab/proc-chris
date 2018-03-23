date = '20180322';
task = 'CO';
monkey = 'Butter';
array = 'cuneate';
number = 1;
sorted = false;

if sorted
    srtStr = 'sorted';
else
    srtStr = 'unsorted';
end

cds = easyCDS(monkey, task, date, array, number, sorted);
outpath = getCdsSavePath(monkey, date, getTask(task));
cdsPath = [outpath,monkey, '_', task, '_', date,'_',num2str(number), '_CDS_', srtStr, '.mat'];
mkdir(outpath);
save(cdsPath, 'cds', '-v7.3');