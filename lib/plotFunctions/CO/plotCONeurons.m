function plotCONeurons(monkey)
    files = dir([getBasePath(), 'CO', filesep, 'Neurons' filesep]);
    files = files(3:end);
    names= {files.name};
    neurons1 = [];
    for i = 1:length(names(1,:))
        splitNames = strsplit(names{i}, '_');
        splitMonkey = splitNames{1};
        if strcmp(monkey, splitMonkey)
            load([files(1).folder,filesep, names{i}]);
            neurons1 = vertcat(neurons1, neurons);
        end
    end
    
    params.plotModDepth = false;
    params.plotActVsPasPD = false;
    params.plotAvgFiring = true;
    params.plotAngleDif = false;
    params.plotPDDists= true;
    params.savePlots = true;
    params.monkey = monkey;
    params.tuningCondition = {'isSorted'};
    neuronStructPlot(neurons1, params);
end