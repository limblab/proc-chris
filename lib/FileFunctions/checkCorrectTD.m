function isCorrect = checkCorrectTD(td,monkey, date)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
trial = td(1);
isCorrect = strcmp(trial.monkey, monkey)& datetime(trial.date, 'InputFormat', 'MM-dd-yyyy') == datetime(date, 'InputFormat', 'yyyyMMdd');
end

