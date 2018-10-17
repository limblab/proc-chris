
sortedUnits = cds.units([cds.units.ID]>0 & [cds.units.ID]<255);
times = cds.analog{1,1}.t(1:10:end);
times = times(1:end-1);
for i = 1:length(sortedUnits)
    binned(:,i) = histcounts(sortedUnits(i).spikes.ts, cds.analog{1,1}.t(1:10:end));
end
binned= [times, binned];
cutBinned = binned(5990:end,:);
