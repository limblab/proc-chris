function mapName = elec2map(td, elec)
    mapping = td(1).cuneate_naming;
    ind = find(mapping(:,1) == elec);
    mapName = mapping(ind,2);
end