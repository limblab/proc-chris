%% This script 
clear all

monkey = 'Butter';
date = '20190129';
array = 'cuneate';
doZscore = false;

array_spikes = [array, '_spikes'];
unit_guide = [array, '_unit_guide'];

actWindow = {{'idx_movement_on', 0}, {'idx_movement_on', 13}};
pasWindow = {{'idx_bumpTime', 0}, {'idx_bumpTime', 13}};
preWindow = {{'idx_movement_on',-20}, {'idx_movement_on',-10}};



mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO', 2);
%%
td = binTD(td, 10);
td = removeGracileTD(td);
td = removeBadNeurons(td, struct('min_fr', 0));
numUnits = length(td(1).(array_spikes)(1,:));
useGuideRep = td(1).(unit_guide);
getSensoryMappings(monkey);
td = smoothSignals(td, struct('signals', 'cuneate_spikes'));

tdAct = trimTD(td, actWindow{1}, actWindow{2});
tdPas = trimTD(td, pasWindow{1}, pasWindow{2});
tdPre = trimTD(td, preWindow{1}, preWindow{2});

preFiring = cat(1, tdPre.(array_spikes))*100;
meanFiring = mean(preFiring);

dirsAct = unique([tdAct.target_direction]);
dirsAct = dirsAct(~isnan(dirsAct));
dirsActStr = strtrim(cellstr(num2str(dirsAct'))');

dirsActStr = strcat('D',dirsActStr);

dirsPas = unique([tdPas.bumpDir]);
dirsPas = dirsPas(~isnan(dirsPas));
dirsPas = dirsPas(mod(dirsPas, 45) ==0);
dirsPasStr = strtrim(cellstr(num2str(dirsPas'))');

dirsPasStr = strcat('D',dirsPasStr);
%%
for i = 1:length(dirsAct)
    tdActDir{i} = tdAct([tdAct.target_direction] == dirsAct(i)); 
    numRows = length(cat(1,tdActDir{i}.pos));
    tdPasDir{i} = tdPas([tdPas.bumpDir] == dirsPas(i)); 
    numRows1 = length(cat(1,tdPasDir{i}.pos));
    if doZscore
        tdActDirFiring{i} = (cat(1,tdActDir{i}.(array_spikes)).*100 - repmat(meanFiring, numRows,1));
        tdPasDirFiring{i} = (cat(1,tdPasDir{i}.(array_spikes)).*100 - repmat(meanFiring, numRows1,1))./repmat(meanFiring, numRows, 1);

    else
        tdActDirFiring{i} = (cat(1,tdActDir{i}.(array_spikes)).*100 - repmat(meanFiring, numRows,1));
        tdPasDirFiring{i} = (cat(1,tdPasDir{i}.(array_spikes)).*100 - repmat(meanFiring, numRows1,1));
    end
    tdActDirSpeed{i} = rownorm(cat(1, tdActDir{i}.vel))';
    speedMat = repmat(tdActDirSpeed{i}, 1, numUnits);
    sensitivity{i} = tdActDirFiring{i}./speedMat;
    meanSensitivity(i,:) = mean(sensitivity{i});
    
    

    tdPasDirSpeed{i} = rownorm(cat(1, tdPasDir{i}.vel))';
    speedMat = repmat(tdPasDirSpeed{i}, 1, numUnits);
    sensitivityPas{i} = tdPasDirFiring{i}./speedMat;
    meanSensitivityPas(i,:) = mean(sensitivityPas{i});
end
%%
% for i = 1:numUnits
%     figure2();
%     plot(0:45:315, meanSensitivity(:,i))
%     hold on
%     plot(0:45:315, meanSensitivityPas(:,i))
%     pause
%     
% end
%%

%  xlim([0, 20])
%  ylim([0, 20])
if doZscore
 maxAbsSensitivity = max(abs(meanSensitivity))*100;
 maxAbsSensitivityPas = max(abs(meanSensitivityPas))*100;
 figure2();
 scatter(maxAbsSensitivity, maxAbsSensitivityPas, 'k', 'Filled')
 hold on
 title('Sensitivies in most sensitive direction Zscored')
 xlabel('Active sensitivity (% change from baseline/(cm/s))')
 ylabel('Passive sensitivty (% change from baseline/(cm/s))')
 plot([0, 20],[0,20], '-r', 'LineWidth', 2)
 set(gca,'TickDir','out', 'box', 'off')
 for i = 1:numUnits
    text(maxAbsSensitivity(i)+.1, maxAbsSensitivityPas(i), ['E', num2str(useGuideRep(i,1)),'U',num2str(useGuideRep(i,2))])
 end
else
 maxAbsSensitivity = max(abs(meanSensitivity));
 maxAbsSensitivityPas = max(abs(meanSensitivityPas));
 figure2();
 scatter(maxAbsSensitivity, maxAbsSensitivityPas, 'k', 'Filled')
 hold on
 title('Sensitivies in most sensitive direction, raw spikes')
 xlabel('Active sensitivity (spikes/(cm/s))')
 ylabel('Passive sensitivty (spikes/(cm/s))')
 plot([0, 20],[0,20], '-r', 'LineWidth', 2)
 set(gca,'TickDir','out', 'box', 'off')
 for i = 1:numUnits
    text(maxAbsSensitivity(i)+.1, maxAbsSensitivityPas(i), ['E', num2str(useGuideRep(i,1)),'U',num2str(useGuideRep(i,2))])
 end
end

 %%
 sensitivityAll = sensitivity{:};
 sensitivityAllPas = sensitivityPas{:};
 
 figure2();
 histogram(sensitivityAll)
 hold on
 histogram(sensitivityAllPas)