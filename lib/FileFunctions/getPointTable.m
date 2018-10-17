function tab = getPointTable(td, params)
tab = table();
markNames=  td(1).marker_names;
markers = cat(1, td.markers);
for j = 1:length(td(1).marker_names)
    tab.(markNames{j}) = markers(:,j);
end
end
