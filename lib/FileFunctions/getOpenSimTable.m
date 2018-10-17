function tab = getOpenSimTable(td, params)
tab = table();
names = td(1).opensim_names;
opensim = cat(1, td.opensim);
for i = 1:length(td(1).opensim_names)
    tab.(names{i}) = opensim(:,i);
end
end