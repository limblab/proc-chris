function [ closeMap ] = getClosestMap( neuron, mapping )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    date= neuron.date;
    monkey = neuron.monkey;
    elec = neuron.mapName;
    unit = neuron.unitNum;
    mapName = neuron.chan;

    daysApart = 100;
    bestRow = -1;
    
    for i = 1:length(mapping)
        if(mapping(i).chan == mapName)
            daysTemp = abs(daysdif(datetime(date, 'InputFormat', 'MM-dd-yyyy'), datetime(mapping(i).date,'InputFormat',  'yyyyMMdd')));
            if  daysTemp == 0
                daysApart = daysTemp;
                bestRow = i;
            end
        end
    end
    if bestRow ~= -1
        closeMap = mapping(bestRow);
    else
        closeMap = 'No mapping';
end

