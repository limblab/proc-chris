function [ neuron ] = insertMappingIntoNeuron( neuron, mappingFile )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    date= neuron.date;
    monkey = neuron.monkey;
    isTableCol = @(t, thisCol) ismember(thisCol, t.Properties.VariableNames);
    if isTableCol(neuron, 'chan')
        elec = neuron.chan;
        if isTableCol(neuron, 'unitNum')
            unit = neuron.unitNum;
        else
            unit = neuron.ID;
        end
    else
        elec = neuron.signalID(1,1);
        unit = neuron.signalID(1,2);
    end
    mapName = neuron.mapName;
    neuron.isCuneate = ~getGracile(monkey, mapName);
    neuron.isGracile =  getGracile(monkey, mapName);
    closestMap = getClosestMap(neuron, mappingFile);
    if ~ischar(closestMap)
        if contains(date, '-')
            if contains(closestMap.date, '/')
                daysDiff = daysdif(datetime(closestMap.date, 'InputFormat', 'MM/dd/yyyy'), datetime(date, 'InputFormat', 'MM-dd-yyyy'));
            else
                daysDiff = daysdif(datetime(closestMap.date, 'InputFormat', 'yyyyMMdd'), datetime(date, 'InputFormat', 'MM-dd-yyyy'));
            end
        else
            if contains(closestMap.date, '/')
                daysDiff = daysdif(datetime(closestMap.date, 'InputFormat', 'MM/dd/yyyy'), datetime(date, 'InputFormat', 'yyyyMMdd'));
            else
                daysDiff = daysdif(datetime(closestMap.date, 'InputFormat', 'yyyyMMdd'), datetime(date, 'InputFormat', 'yyyyMMdd'));
            end
        end
        if daysDiff < Inf
            neuron.sameDayMap = daysDiff == 0;
            neuron.daysDiff = daysDiff;
            neuron.isProprioceptive = strcmp(closestMap.pc, 'p');
            neuron.isSpindle = closestMap.spindle;
            neuron.desc = {closestMap.desc};
            neuron.proximal = closestMap.proximal;
            neuron.midArm = closestMap.midArm;
            neuron.distal = closestMap.distal;
            neuron.handUnit = closestMap.handUnit;
            neuron.cutaneous = closestMap.cutaneous;
            neuron.proprio = closestMap.proprio;
        end
    else
        neuron.sameDayMap = false;
        neuron.daysDiff = Inf;
        neuron.isProprioceptive = false;
        neuron.isSpindle = false;
        neuron.proximal = false;
        neuron.midArm = false;
        neuron.distal = false;
        neuron.handUnit = false;
        neuron.cutaneous = false;
        neuron.proprio = false;
        neuron.desc = {'Not Mapped'};
    end
end

