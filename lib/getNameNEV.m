function [ nevName ] = getNameNEV( monkey, date, task, array, number, isSorted)
    if isSorted
        nevName = ['Sorted\',monkey, '_', date, '_', task, '_', array, '_', num2str(number, '%03i'), '-sorted'];
    else
        nevName = [monkey, '_', date, '_', task, '_', array, '_', num2str(number, '%03i')];
    end
end

