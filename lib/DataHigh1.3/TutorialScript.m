td = getPaperFiles(4);
td = removeUnsorted(td);
td = getSpeed(td);
td = getMoveOnsetAndPeak(td);
td = trimTD(td, {'idx_goCueTime',200}, {'idx_goCueTime', 500});
D1 = td2DataHigh(td);
DataHigh(D1', 'DimReduce');