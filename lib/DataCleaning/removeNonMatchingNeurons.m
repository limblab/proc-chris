function td = removeNonMatchingNeurons(td)
    array = 'cuneate';
    guide = td(1).cuneate_unit_guide;
    
    rm1 = false(length(guide(:,1)),1);
    for i = 1:length(td)
        template = td(i).cuneate_unit_guide;
        guide = intersect(guide, template, 'rows');
    end
    for  i= 1:length(td)
        tmp = td(i).cuneate_unit_guide;
        
        [~,bad_units] = setdiff(tmp, guide, 'rows');

        if ~isempty(bad_units)
            temp = td(i).([array '_spikes']);
            temp(:,bad_units) = [];
            td(i).([array '_spikes']) = temp;
            temp = td(i).([array '_unit_guide']);
            temp(bad_units,:) = [];
            td(i).([array '_unit_guide']) = temp;
            if isfield(td(i), [array, '_ts'])
                temp = td(i).([array '_ts']);
                temp(bad_units) = [];
                td(i).([array '_ts'])= temp;
            end
        end
    end
end