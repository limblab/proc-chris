function path = getPathFromTD(td, resort)
    if nargin<2 
        resort = false;
    end
    path = getBasicPath(td(1).monkey, dateToLabDate(td(1).date), getGenericTask(td(1).task), resort);
end