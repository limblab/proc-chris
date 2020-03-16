function td = addSensoryMappingToGuide(td)
    guide = td(1).cuneate_unit_guide;
    monkey = td(1).monkey;
    mappingFile = getSensoryMappings(monkey);
    mappingFile = findDistalArm(mappingFile);
    mappingFile = findHandCutaneousUnits(mappingFile);
    mappingFile = findProximalArm(mappingFile);
    mappingFile = findMiddleArm(mappingFile);
    mappingFile = findCutaneous(mappingFile);
    mapping = td(1).cuneate_naming;
    neurons = [];
    for i = 1:length(guide(:,1))
        neuron = [];
        neuron.date = td(1).date;
        neuron.monkey = monkey;
        neuron.chan = guide(i,1);
        neuron.unitNum = guide(i,2);
        neuron.mapName = mapping(find(mapping(:,1) == neuron.chan),2);
        neuron = struct2table(neuron);
        neuron = insertMappingIntoNeuron(neuron, mappingFile);
        neurons = [neurons; neuron];
        
        
    end
    for i = 1:length(td)
        td(i).cuneate_mapping_guide = neurons;
    end
end