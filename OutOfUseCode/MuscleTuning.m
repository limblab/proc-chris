[timesLength, numCols] = size(Lando03202017Muscles);
temp = table2array(Lando03202017Muscles);
neuralTimeStart = 12.884;
muscleMat = temp(:,2:end);
timeMat = temp(:,1);
numMuscles = length(muscleMat(1,:));
numTimes = length(muscleMat(:,1));
muscleDiff = diff(muscleMat);
units = cds.units;
arrayCell = {units.array};
for i = 1:length(arrayCell)
    arrayEntry = arrayCell{i};
    cuneateMask(i) = strcmp('Cuneate', arrayEntry);
end
cuneateUnits = units(cuneateMask & [units.ID] ~= 0 & [units.ID] ~=255);
for j = 1:length(cuneateUnits)
    spikeAligned{j}= cds.units(j).spikes.ts - neuralTimeStart;
    for i = 1:numTimes-1
        startTime = timeMat(i);
        endTime = timeMat(i+1);
        spikes(i,j) = sum(spikeAligned{j} > startTime & spikeAligned{j}< endTime); 
    end
end
%% Plotting
close all
timeVector = 1400:1600;
wrists = [1, 12, 13,14, 15,16,17,18,19,20,21];
for muscleNum = wrists
    for cellNum = [11]
        figure 
        yyaxis left
        plot(timeMat(timeVector), spikes(timeVector, cellNum))
        yyaxis right
        plot(timeMat(timeVector), muscleMat(timeVector, muscleNum))
        titleString = ['Unit ', num2str(cellNum), ' Muscle ', num2str(muscleNum)];
        title(titleString)
    end
end
%% 
close all
psthWindow = 20;
psth = zeros(length(spikes(1,:)), psthWindow);
for muscleNum = [3,4,6,8,10,24,28,38]
    for cellNum = 1:length(spikes(1,:))
        for i = psthWindow:length(spikes(:,1))
            psth(cellNum,:) = psth(cellNum,:) + spikes(i,cellNum)*muscleDiff(i-psthWindow+1:i,muscleNum)';
        end
    end
    for i = 1:length(spikes(1,:))
        figure
        plot(psth(i,end:-1:1))
    end
end


%%
close all
for muscleNum = [6,8,10,24,28,38];
    for cellNum = 1:length(spikes(1,:))
        figure
        scatter(muscleDiff(1:end,muscleNum), spikes(:,cellNum))
    end
end