function neurons1 = getBestMuscle(td1, neurons1)
    temp = [];
    opensim_names = td1(1).opensim_names;
    count = 0;
    for i = 1:length(opensim_names)
        if strcmp(opensim_names{i}(end-3:end), '_len')
            count = count+1;
            singMuscVar{count} = opensim_names{i}(1:end-4);
            temp = [temp, mean(neurons1.(singMuscVar{count})')'];
        end
    end
    
    neurons1.bestMuscle = max(temp')';
end