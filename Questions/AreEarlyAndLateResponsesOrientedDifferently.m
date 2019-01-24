clear all
close all

useActive = false;

monkey = 'Butter';
date = '20181218';
actWindowEarly = {{'idx_movement_on', -5}, {'idx_movement_on', 5}};
actWindowLate = {{'idx_movement_on', 10}, {'idx_movement_on', 20}};
pasWindowEarly = {{'idx_bumpTime', -1}, {'idx_bumpTime', 2}};
pasWindowLate = {{'idx_bumpTime', 8}, {'idx_bumpTime', 11}};

pasWindow = {{'idx_bumpTime', 0}, {'idx_bumpTime', 13}};

preWindow = {{'idx_goCueTime',-5}, {'idx_goCueTime',0}};
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO');
getSensoryMappings(monkey);

binSize = 10; % in ms


savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'EarlyLateWindows',filesep];
mkdir(savePath)

if useActive
    windowEarly= actWindowEarly;
    windowLate = actWindowLate;
else
    windowEarly = pasWindowEarly;
    windowLate = pasWindowLate;
end
%% Pre-process TD
td1 = removeBadTrials(td);
td1 = removeBadNeurons(td1);
td1 = removeGracileTD(td1);
td1 =  td1(~isnan([td1.target_direction]));
tdActEarly = trimTD(td1, windowEarly{1}, windowEarly{2});
tdActLate = trimTD(td1, windowLate{1}, windowLate{2});
tdPas = trimTD(td1, pasWindow{1}, pasWindow{2});
tdPre = trimTD(td1, preWindow{1}, preWindow{2});

tdActEarly = binTD(tdActEarly, binSize/10);
tdActLate = binTD(tdActLate, binSize/10);
tdPas = binTD(tdPas, binSize/10);
tdPre = binTD(tdPre, binSize/10);

%%
array = getTDfields(tdActEarly, 'arrays');
array = array{1};
params.monkey = tdActEarly(1).monkey;
params.array= array;
params.date = tdActEarly(1).date;
params.out_signals = [array, '_spikes'];
params.distribution = 'poisson';
params.out_signal_names =tdActEarly(1).([array, '_unit_guide']);
params.num_boots = 100;
tuningEarly = getTDPDs(tdActEarly, params);
tuningLate = getTDPDs(tdActLate, params);
%%
dirsAct = unique([tdActEarly.target_direction]);
dirsAct = dirsAct(~isnan(dirsAct));
dirsActStr = strtrim(cellstr(num2str(dirsAct'))');

dirsActStr = strcat('D',dirsActStr);

dirsPas = unique([tdPas.bumpDir]);
dirsPas = dirsPas(~isnan(dirsPas));
dirsPasStr = strtrim(cellstr(num2str(dirsPas'))');

dirsPasStr = strcat('D',dirsPasStr);
%%
unitGuide = tdActEarly.cuneate_unit_guide;
for i = 1:length(dirsAct)
    rawEarly{i}  = cat(3, tdActEarly([tdActEarly.target_direction] == dirsAct(i)).cuneate_spikes);
    rawEarly{i} = rawEarly{i};
    meanFirActEarly(i,:,:) = squeeze(mean(rawEarly{i},3)).*100;
    meanTrialFiringActEarly{i} = squeeze(mean(rawEarly{i}));
    meanFiringActEarly(i,:) = mean(meanTrialFiringActEarly{i}').*100;
    
    rawLate{i}  = cat(3, tdActLate([tdActLate.target_direction] == dirsAct(i)).cuneate_spikes);
    rawLate{i} = rawLate{i};
    meanFirActLate(i,:,:) = squeeze(mean(rawLate{i},3)).*100;
    meanTrialFiringActLate{i} = squeeze(mean(rawLate{i}));
    meanFiringActLate(i,:) = mean(meanTrialFiringActLate{i}').*100;
    
end

for i = 1:length(dirsPas)
    
    raw{i}  = cat(3, tdPas([tdPas.bumpDir] == dirsPas(i)).cuneate_spikes);
    meanFirPas(i,:,:) = squeeze(mean(raw{i},3)).*100;
    meanTrialFiringPas{i} = squeeze(mean(raw{i}));
    meanFiringPas(i,:) = mean(meanTrialFiringPas{i}').*100;


end
raw1 = cat(3, tdPre.cuneate_spikes);
meanFirPre = mean(squeeze(mean(raw1,3))*100);
meanTrialFiringPre = squeeze(mean(raw1));
tabPas = table(raw',meanFirPas, 'VariableNames', {'RawPas', 'MeanPas'}, 'RowNames', dirsPasStr);
%%
earlyPD = tuningEarly.velPD;
latePD = tuningLate.velPD;
earlyPDCI = tuningEarly.velPDCI;
latePDCI = tuningLate.velPDCI;

for i = 1:length(meanFiringActEarly(1,:))
    firEarly = [meanFiringActEarly(:,i); meanFiringActEarly(1,i)];
    firLate = [meanFiringActLate(:,i); meanFiringActLate(1,i)];
    
    theta = deg2rad(linspace(0, 360, 9));
    
    figure2()
    polarplot(theta, firEarly, 'b')
    hold on
    polarplot([earlyPD(i), earlyPD(i)], [0, max([max(firEarly), max(firLate)])],'b')
    polarplot(theta, firLate,'r')
    polarplot([latePD(i), latePD(i)], [0, max([max(firEarly), max(firLate)])],'r')
    polarplot([earlyPDCI(i,1), earlyPDCI(i, 2)], [max(firEarly), max(firEarly)]/2,'b');
    polarplot([latePDCI(i,1), latePDCI(i, 2)], [max(firLate), max(firLate)]/2,'r');
    legend('Early','EarlyPDCI', 'Late', 'LatePDCI')
    title(['NeuronLatevsEarly U', num2str(unitGuide(i,1)),' E',num2str(unitGuide(i,2))])
    saveas(gca, [savePath, 'NeuronLatevsEarlyPassive_U', num2str(unitGuide(i,1)),'E',num2str(unitGuide(i,2)), '.png'])
    saveas(gca, [savePath, 'NeuronLatevsEarlyPassive_U', num2str(unitGuide(i,1)),'E',num2str(unitGuide(i,2)), '.pdf'])

end
%%

figure
histogram(angleDiff(earlyPD, latePD, true, false),12);
