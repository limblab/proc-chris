function newDate = dateToLabDate(date1)
    newDate = datestr(datetime(date1,'InputFormat','MMddyyyy'), 'yyyymmdd');
end