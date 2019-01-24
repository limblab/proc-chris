function neuronStruct = makeNeuronStructFromPDTable(pdTable, array)
        
        arrName.array = repmat({array}, [height(pdTable), 1]);
        neuronStruct = [struct2table(arrName), pdTable];
end