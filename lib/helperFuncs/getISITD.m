function isiG = getISITD(td)
    array = getArrayName(td);
    spikes = {td.([array, '_ts'])};
    isi = cell(length(spikes{1}),1);
    guide = td(1).([array, '_unit_guide']);
    for i = 1:length(spikes)
    maxTime = length(td(i).pos(:,1))*td(1).bin_size;
        for j = 1:length(spikes{i})
            ts1 = spikes{i}{j};
            ts1(ts1<0 | ts1 > maxTime) = [];
            isi{j} = [isi{j}; diff(ts1)];
        end
    end
    isiG = table(guide, isi);
end