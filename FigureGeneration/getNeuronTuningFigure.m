function figureTable = getNeuronTuningFigure(neurons1)
    sortedNeurons = neurons1(logical([neurons1.isSorted]),:);
    tunedNeurons = neurons1(logical(checkIsTuned(sortedNeurons, pi/4)), :);
    
    disp('% of sorted neurons tuned @ pi/4 confidence')
    disp(height(tunedNeurons)/height(sortedNeurons));
    
    plotRWNeuronsModDepth(tunedNeurons);
    plotRWNeuronsPD(tunedNeurons);
    plotRWNeuronsTuningCurve(tunedNeurons,'r');
end