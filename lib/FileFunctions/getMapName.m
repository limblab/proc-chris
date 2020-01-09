function mapName = getMapName(td, elec)
    if isfield(td, 'cuneate_naming')
        mapping = td(1).cuneate_naming;
        ind = find(mapping(:,1) == elec);
        mapName = mapping(ind,2);
    else
        mapName = [];
    end
end