function [ output_args ] = cdsSave( cds, monkey, date, task, number)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
outpath = getCdsSavePath(monkey, date, getTask(task));
cdsPath = [outpath,monkey, '_', task, '_', date,'_',num2str(number), '_CDS.mat'];
mkdir(outpath);
save(cdsPath, 'cds', '-v7.3');

end

