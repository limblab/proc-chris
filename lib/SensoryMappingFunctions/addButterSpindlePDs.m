function [neurons, angDif1, spinPD, actPD] = addCrackleSpindlePDs(neurons, pd, mNameM, useAct)
    pdMean = mean(pd);
    neurons.spindlePD  = zeros(height(neurons), 1);

    unitList = [74,1;72,1;71,1;38,1;36,1;27,2;2,1;1,1];
    muscList = [37,8,29,37,24,25,5,3];
    
    unitTab = table(unitList);
    actPD = zeros(length(unitList(:,1)),1);
    spinPD = zeros(length(unitList(:,1)),1);
    elecList = zeros(length(unitList(:,1)),1);
    unitList1 = zeros(length(unitList(:,1)),1);
    for i = 1:length(unitList(:,1))
        elec = unitList(i,1);
        unit = unitList(i,2);
        neuron = neurons([neurons.chan] == elec & [neurons.ID] == unit,:);
        if ~isempty(neuron)
            desc = neuron.desc
            if useAct
                actPD(i) = neuron.actPD.velPD;
            else
                actPD(i) = neuron.pasPD.velPD;
            end
            rand1 = randi(length(pd(:,1)),1);
            spinPD(i) =  pd(rand1, muscList(i));
            elecList(i) = elec;
            unitList1(i) =unit;
        end
        
    end
    elecList(actPD ==0) =[];
    unitList1(actPD ==0) =[];
    actPD(actPD==0) =[];
    spinPD(spinPD==0) =[];
    
    
    figure
    scatter(actPD, spinPD)
    hold on
    plot([-pi, pi], [-pi, pi])
    for i = 1:length(elecList)           
        dx = -.1; dy = 0.1; % displacement so the text does not overlay the data points
        text(actPD(i)+ dx, spinPD(i) +dy, num2str(elecList(i)));
    end
    angDif1 = angleDiff(spinPD, actPD, true, false);
end