function neurons = funcForDifTargets(neurons)
    fieldsToCell = {'actTuningCurve', 'pasTuningCurve', 'sensMove', 'sensBump', 'cpAvg', 'cpBumpAvg'};
    for j =1:length(fieldsToCell)
        for i =1:height(neurons)
            temp{i} = {neurons.(fieldsToCell{j})(i,:)};
        end
        neurons.(fieldsToCell{j}) =[];
        neurons.(fieldsToCell{j}) = temp';
    end
end