function [ closeMap ] = getClosestMap( neuron, mapping )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    date= neuron.date;
    monkey = neuron.monkey;
    elec = neuron.chan;
    unit = neuron.unitNum;
    mapName = neuron.mapName;

    daysApart = 1000;
    bestRow = -1;
    
    for i = 1:length(mapping)
        if(mapping(i).chan == mapName)
            if contains(date, '-')
                if contains(mapping(i).date, '/')
                    daysTemp = abs(daysdif(datetime(date, 'InputFormat', 'MM-dd-yyyy'), datetime(mapping(i).date, 'InputFormat', 'MM/dd/yyyy')));
                else
                    daysTemp = abs(daysdif(datetime(date, 'InputFormat', 'MM-dd-yyyy'), datetime(mapping(i).date, 'InputFormat', 'yyyyMMdd')));
                end
            elseif contains(date, '/')
                if contains(mapping(i).date, '/')    
                    daysTemp = abs(daysdif(datetime(date, 'InputFormat', 'MM/dd/yyyy'), datetime(mapping(i).date, 'InputFormat', 'MM/dd/yyyy')));
                else
                end
                
            else
                if contains(mapping(i).date, '/')
                    daysTemp = abs(daysdif(datetime(date, 'InputFormat', 'yyyyMMdd'), datetime(mapping(i).date, 'InputFormat', 'MM/dd/yyyy')));
                else
                    daysTemp = abs(daysdif(datetime(date, 'InputFormat', 'yyyyMMdd'), datetime(mapping(i).date, 'InputFormat', 'yyyyMMdd')));
                end
            end
            if  daysTemp < daysApart
                daysApart = daysTemp;
                bestRow = i;
            end
        end
    end
    if bestRow ~= -1
        closeMap = mapping(bestRow);
        closeMap.daysDif = daysApart;
    else
        closeMap = 'No mapping';
end

