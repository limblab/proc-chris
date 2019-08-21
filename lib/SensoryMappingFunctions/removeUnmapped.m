function td = removeUnmapped(td, params)
    flags = {};
    array = 'cuneate';
    if nargin > 1, assignParams(who,params); end % overwrite defaults
    date1 = td(1).date;
    monkey = td(1).monkey;
    mapping = getSensoryMappings(monkey);
    maps = mapping(datetime(vertcat(mapping.date), 'InputFormat', 'yyyyMMdd') == datetime(date1, 'InputFormat' ,'MM-dd-yyyy'),:); 
    for i = 1:length(flags)
        maps(~[maps.(flags{i})]) = [];
        if isempty(maps)
            error('No neurons matching required characteristics')
        end
    end
    elecs = [maps.elec];
    guide = td(1).([array, '_unit_guide']);
    
    all_spikes = cat(1,td.([array '_spikes']));

    bad_units = zeros(1,size(all_spikes,2));
    
    for i = 1:length(guide(:,1))
        bad_units(i) =  sum(guide(i,1) == elecs) == 0; 
    end
    bad_units = logical(bad_units);
    disp([array ': found ' num2str(sum(bad_units)) ' bad units.']);

    % now remove the bad cells
    if sum(bad_units) > 0
        for trial = 1:length(td)
            temp = td(trial).([array '_spikes']);
            temp(:,bad_units) = [];
            td(trial).([array '_spikes']) = temp;
            temp = td(trial).([array '_unit_guide']);
            temp(bad_units,:) = [];
            td(trial).([array '_unit_guide']) = temp;
            temp = td(trial).([array '_ts']);
            temp(bad_units) = [];
            td(trial).([array '_ts'])= temp;
        end
        bad_units = find(bad_units);
    else
        bad_units = [];
    end
end
    