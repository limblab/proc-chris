function [ neuron ] = insertMappingIntoNeuron( neuron, mappingFile )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    date= neuron.date;
    monkey = neuron.monkey;
    elec = neuron.chan;
    unit = neuron.unitNum;
    mapName = neuron.mapName;
    neuron.isCuneate = ~getGracile(monkey, elec);
    neuron.isGracile =  getGracile(monkey, elec);
    closestMap = getClosestMap(neuron, mappingFile);
    if ~ischar(closestMap)
        daysDiff = daysdif(datetime(closestMap.date, 'InputFormat', 'yyyyMMdd'), datetime(date, 'InputFormat', 'MM-dd-yyyy'));
        if daysDiff == 0 
            neuron.sameDayMap = daysDiff == 0;
            neuron.daysDiff = daysDiff;
            neuron.isProprioceptive = strcmp(closestMap.pc, 'p');
            neuron.isSpindle = closestMap.spindle;
            neuron.desc = closestMap.desc;
        end
    else
        neuron.sameDayMap = false;
        neuron.daysDiff = Inf;
        neuron.isProprioceptive = false;
        neuron.isSpindle = false;
        neuron.desc = 'Not Mapped';
    end
end

