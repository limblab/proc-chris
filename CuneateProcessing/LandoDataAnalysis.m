  dataFileName = '/home/chris/Documents/Cuneate Data/Sorted/LandoData/Sorted/Lando_20161120_RightCuneate_002';
  datafile = get_nev_mat_data(dataFileName, 6);
%% Get sorted units from file
units = datafile.units;
cellNum =1;
for i = 1:length(units)
    if units(i).id(2) >0 && units(i).id(2) < 100
        sortedUnits(cellNum) = units(i);
        cellNum = cellNum+1;
    end
end
%% Get kinematic data
position = datafile.pos;
velocity = datafile.vel;
accel = datafile.acc;
movingFlag = abs(velocity(:,2) >1) | abs(velocity(:,3) >1);

%% Bin unit firing into .05s bins
binSize = .05;
binStart = 1;
for j = 1: length(sortedUnits)  
    bin =0;
    for k = binStart:binSize:velocity(end,1)
        bin = bin +1;
        binnedSortedUnits{j}(bin) = sum(sortedUnits(j).ts > k & sortedUnits(j).ts <k+binSize);
    end
    sortedUnits(j).binned = binnedSortedUnits{j};
    smoothBinSortUnits{j} = smooth(binnedSortedUnits{j});
end

%% Downsample Velocity to .05 s bins 
downsampledPosition = downsample(position, 50);
downsampledVelocity = downsample(velocity, 50);
downsampledAcc = downsample(accel, 50);
%% Fit GLM on endpoint velocity
for i = 1:length(sortedUnits)
    [params, dev, stats] = glmfit(downsampledVelocity(:,2:3), smoothBinSortUnits{i}, 'poisson');
    fitParams{i} = params;
    fitDeviance{i} = dev;
    fitStats{i} = stats;
    if sum(stats.p <.05) > 1
        significant(i) = sum(stats.p <.05);
    else
        significant(i) = 0;
    end
    percentSigVel = sum(significant>0)/length(sortedUnits);
end

%% Fit GLM on endpoint position
for i = 1:length(sortedUnits)
    [params, dev, stats] = glmfit(downsampledPosition(:,2:3), smoothBinSortUnits{i}, 'poisson');
    fitParamsPos{i} = params;
    fitDeviancePos{i} = dev;
    fitStatsPos{i} = stats;
    if sum(stats.p <.05) > 1
        significantPos(i) = sum(stats.p <.05);
    else
        significantPos(i) = 0;
    end
    percentSigPos = sum(significantPos>0)/length(sortedUnits);
end
sharedSig = significant == significantPos;
%% Investigate neurons that have significant endpoint velocity model fits
sortedUnitswBins = sortedUnits;

%% Get Trial table
trialWords = datafile.words;
trialNum = 1;
for wordnum = 1:length(trialWords)
    if trialWords(wordnum,2) == 33
        trialStart(trialNum) = trialWords(wordnum,1);
        trialNum = trialNum+1;
    end
end
%% Investigate neurons that have significant position model fits
