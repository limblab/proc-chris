function [neurons1, bestMuscles] = getBestTwoMuscles(td1, neurons1)
    temp = [];
    opensim_names = td1(1).opensim_names;
    count = 0;
    lastKin = 15;
    fields1 = fields(neurons1);
    for i = 1:length(fields1)
        if contains(fields1{i}, 'X')
            count = count+1;
            temp = [temp, mean(neurons1.(fields1{i})')'];
        end
    end
    
    [bestMuscle] = max(temp');
    [~, bestName] = max(temp');
    bestMuscles = fields1(lastKin+bestName);
    neurons1.bestTwoMuscles = bestMuscle';
end