function [fh1, neuronISI] = constructISIHistFromTD(td, params)
array = 'cuneate';
plotFlag= false;
if nargin > 1, assignParams(who,params); end % overwrite defaults
neurons = find(td(1).([array, '_unit_guide'])(:,2) ~= 0 & td(1).([array, '_unit_guide'])(:,2) ~=255);
if nargin > 1, assignParams(who,params); end % overwrite defaults
fh1 = figure;
tsArr = cat(2, td.([array, '_ts']));
for i = 1:length(neurons)

    neuronISI{i} = [];
    for j = 1:length(tsArr(1,:))
        neuronISI{i} = [neuronISI{i}; diff(tsArr{neurons(i),j})];
    end
    
    if plotFlag;fh1 =figure;histogram(neuronISI{i},'Normalization', 'probability');end;
end

end