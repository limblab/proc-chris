function neurons = fixCellArray(neurons)
    cellArr = {'actTuningCurve', 'pasTuningCurve', 'sensMove', 'sensBump', 'firingChangeMove'};
    neuronsTemp = table();
    fld = fieldnames(neurons);
    
    for i = 1:height(neurons)
        for j = 1:length(cellArr)
            if any(contains(fld(:), cellArr{j}))
                place = neurons.(cellArr{j})(i,:);
                if iscell(place)
                    while iscell(place{1,1})
                        place = place{1,1};
                    end
                    neurons.(cellArr{j})(i,:) = place;
                else
                    neuronsTemp.(cellArr{j})(i,:) = {place};
                end
        
            end
        end
    end
    tempFld = fieldnames(neuronsTemp);
    tempFld(end-2:end) = [];
    for i = 1:length(tempFld)
        neurons.(tempFld{i}) = neuronsTemp.(tempFld{i});
    end
    
end