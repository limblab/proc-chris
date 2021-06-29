function newDate = dateToLabDate(date1)
    if contains(date1, '-')
        newDate = datestr(datetime(date1, 'InputFormat', 'MM-dd-yyyy'), 'yyyymmdd');
    elseif ~strcmp(date1(1:2), '20')
        newDate = datestr(datetime(date1,'InputFormat','MMddyyyy'), 'yyyymmdd');
    elseif contains(date1, '/')
        newDate = datestr(datetime(date1, 'InputFormat', 'yyyy/MM/dd'), 'yyyymmdd');
    else
        newDate = date1;
    end
    
end