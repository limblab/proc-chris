function elec = map2elec(td, map)
    mapping = td(1).cuneate_naming;
    ind = find(mapping(:,2) == map);
    elec = mapping(ind,1);
end