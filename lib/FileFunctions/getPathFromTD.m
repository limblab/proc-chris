function path = getPathFromTD(td)
    path = getBasicPath(td(1).monkey, dateToLabDate(td(1).date), td(1).task);
end