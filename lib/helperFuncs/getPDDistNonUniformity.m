function [madAct, madPas] = getPDDistNonUniformity(neuronStruct, params)
    suffix = [];
    tuningCondition = {'isSorted'};
    nBins = 18;
    fh1 = [];
    date1= [];
    array =[];
    edges = [];
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    if iscell(tuningCondition)
        for i = 1:length(tuningCondition)
            if strcmp(tuningCondition{i}(1), '~')
                neuronStruct = neuronStruct(find(~neuronStruct.(tuningCondition{i}(2:end))),:);
            else
                if contains(tuningCondition{i}, '|')
                    conds = split(tuningCondition{i}, '|');
                    flag1 = neuronStruct.(conds{1}) | neuronStruct.(conds{2});
                    neuronStruct = neuronStruct(find(flag1),:);
                    
                else
                    if length(tuningCondition{i}) >8 & strcmp(tuningCondition{i}(1:8), 'daysDiff')
                        dayCutoff = str2num(tuningCondition{i}(9:end));
                        flag1 = abs(neuronStruct.daysDiff)<dayCutoff;
                        neuronStruct =neuronStruct(find(flag1),:);
                    else
                        neuronStruct = neuronStruct(find(neuronStruct.(tuningCondition{i})),:);
                    end
                end
            end
            
        end
    else
        neuronStruct = neuronStruct(find(neuronStruct.(tuningCondition)),:);
    end
    neuronStruct1 = [];
   if iscell(date1)
       for i =1:length(date1)
            neuronStruct1 = [neuronStruct1; neuronStruct(find(strcmp(date1{i}, [neuronStruct.date1])),:)];
       end
       neuronStruct = neuronStruct1;
   elseif strcmp(date1, 'all')
       
   else 
       neuronStruct = neuronStruct(find(strcmp(date1, [neuronStruct.date1])),:);
   end
    cuneateNeurons = neuronStruct(~strcmp('LeftS1',[neuronStruct.array]) & ~strcmp('area2',[neuronStruct.array]),:);
    s1Neurons = neuronStruct(strcmp('S1',[neuronStruct.array]) |strcmp('LeftS1Area2', [neuronStruct.array]) | strcmp('area2',[neuronStruct.array]),:);
    
    if strcmp(array, 'cuneate') | strcmp(array, 'RightCuneate')
        neuron = cuneateNeurons;
    elseif strcmp(array, 'area2') | strcmp(array,'LeftS1') | strcmp(array, 'LeftS1Area2')| strcmp(array, 'S1')
        neuron = s1Neurons;
    else
        neuron = neuronStruct;
    end
    
    actPDs = neuron.actPD.velPD;
    pasPDs = neuron.pasPD.velPD;
    numBoots = 100;
    numUnits = 100;
    bootIndsAct = randi(length(actPDs), numUnits, numBoots);
    bootIndsPas = randi(length(pasPDs), numUnits, numBoots);
    for boot = 1:numBoots
        rhoAct= histcounts(actPDs(bootIndsAct(:,boot)), edges);
        rhoPas = histcounts(pasPDs(bootIndsPas(:,boot)), edges);
        madAct(boot) = norm((rhoAct-mean(rhoAct))/mean(rhoAct), 1);
        madPas(boot) = norm((rhoPas-mean(rhoPas))/mean(rhoPas), 1);
    end
end