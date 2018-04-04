function [neuronStruct1 ] = insertMappingsIntoNeuronStruct( neuronStruct, mappingFile )
% insertMappingsIntoNeuronStruct
%   The function takes the fit neuron struct and inserts the results of
%   sensory mappings into the structure, and returns it. The method of
%   matching the units is based on the date of the sensory mapping. There
%   is a boolean flag which denotes if the mapping was done on the same day
%   as the neuron fit was made. Second, there is a flag if it is from
%   gracile or cuneate nucleus. Third, there is a flag if it is from a
%   proprioceptive of cutaneous unit. Fourth, there is a flag as to whether
%   it is from a identified muscle spindle. I also plug in the descriptions
%   of the mappings into the structure
neuronStruct1 =[];
    for i = 1:height(neuronStruct)
        neuron = insertMappingIntoNeuron(neuronStruct(i,:), mappingFile);
        neuronStruct1 = [neuronStruct1;neuron];
    end


end

