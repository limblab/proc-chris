function array = getArrayName(td)
    flds = fieldnames(td);
    temp = contains(flds, '_spikes');
    array = flds(temp);
    if length(array) ==1
        array = array{1}(1:end-7);
    end
        
end