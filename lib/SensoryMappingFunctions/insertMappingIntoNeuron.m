function [ neuron ] = insertMappingIntoNeuron( neuron, mappingFile )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    date= neuron.date;
    monkey = neuron.monkey;
    elec = neuron.chan;
    unit = neuron.unitNum;
    mapName = neuron.mapName;
    
    closestMap = getClosestMap(neuron, mappingFile);
    if ~ischar(closestMap)
        daysDiff = daysdif(datetime(closestMap.date, 'InputFormat', 'yyyyMMdd'), datetime(date, 'InputFormat', 'MM-dd-yyyy'));
        neuron.sameDayMap = daysDiff == 0;
        neuron.daysDiff = daysDiff;
        neuron.isCuneate = ~contains(closestMap.desc, {'leg', 'foot', 'heel', 'tail', 'butt'}, 'IgnoreCase', true); 
        neuron.isGracile = contains(closestMap.desc, {'leg', 'foot', 'heel', 'tail', 'butt'}, 'IgnoreCase', true); 
        neuron.isProprioceptive = strcmp(closestMap.pc, 'p');
        neuron.isSpindle = closestMap.spindle;
        neuron.desc = closestMap.desc;
    else
        neuron.sameDayMap = false;
        neuron.isCuneate = false;
        neuron.isGracile = false;
        neuron.daysDiff = Inf;
        neuron.isProprioceptive = false;
        neuron.isSpindle = false;
        neuron.desc = 'Not Mapped';
    end
end

