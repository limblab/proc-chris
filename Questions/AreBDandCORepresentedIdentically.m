clearvars -except tdCO1 tdBD1
close all
array = 'cuneate';
monkey = 'Snap';
date = '20191009';
plotPos = true;
plotSpeeds = true;
plotResponses =true;


if ~exist('tdCO1') | ~exist('tdBD1')
    tdCO1 = getTD(monkey, date, 'CO',2);
    tdBD1 = getTD(monkey, date, 'BD',1);
end
tdCO = tdToBinSize(tdCO1,10);
tdBD = tdToBinSize(tdBD1,10);

tdCO = getSpeed(tdCO);
tdBD = getSpeed(tdBD);
% 
tdCO = removeUnsorted(tdCO);
tdBD = removeUnsorted(tdBD);

tdCO = removeGracileTD(tdCO);
tdBD = removeGracileTD(tdBD);

tdCO = removeNeuronsBySensoryMap(tdCO, struct('rfFilter', {{'spindle', false}}));
tdBD = removeNeuronsBySensoryMap(tdBD, struct('rfFilter', {{'spindle', false}}));

guide = tdCO(1).cuneate_unit_guide;
guide2 = tdBD(1).cuneate_unit_guide;

tdCO = smoothSignals(tdCO, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .02));
tdBD = smoothSignals(tdBD, struct('signals', [array, '_spikes'], 'calc_rate', true, 'width', .02));

before = -10;
after = 20;

dirsBCO = unique([tdCO.bumpDir]);
dirsBBD = floor(rad2deg(unique([tdBD.correctAngle])));

dirsBCO(isnan(dirsBCO)) = [];
dirsBBD(isnan(dirsBBD)) = [];

tdCO(isnan([tdCO.bumpDir])) =[];
tdBD(isnan([tdBD.bumpDir])) =[];

tdCO = trimTD(tdCO, {'idx_bumpTime',before}, {'idx_bumpTime', after});
tdBD = trimTD(tdBD, {'idx_bumpTime',before}, {'idx_bumpTime', after});

velCO= cat(1, tdCO.vel);
velBD = cat(1,tdBD.vel);
fCO = cat(1, tdCO.cuneate_spikes);
fBD = cat(1, tdBD.cuneate_spikes);
%%
coX = fitlm(fCO, velCO(:,1))
coY = fitlm(fCO, velCO(:,2))

bdX = fitlm(fBD, velBD(:,1))
bdY = fitlm(fBD, velBD(:,2))

%%
timesInc2 = 1:13;
for timesInc1 = 1:length(timesInc2)
classCO = [];
classBD = [];
inputCO =[];
inputBD = [];
timesInc = timesInc2(timesInc1);
for i = 1:length(dirsBCO)
    fCO{i} = cat(3, tdCO([tdCO.bumpDir]== dirsBCO(i)).cuneate_spikes);
    meanFCO(:,:,i) =  mean(fCO{i},3);
    meanFCOCI{i}(:,:,:) = permute(squeeze(bootci(100, @mean, permute(fCO{i}, [3,1,2]))),[2,3,1]);
    
    inputCO = [inputCO; reshape(fCO{i}(timesInc,:,:), sum([tdCO.bumpDir] == dirsBCO(i)), length(timesInc)* length(fCO{i}(1,:,1)))];
    classCO = [classCO;  i*ones(sum([tdCO.bumpDir] == dirsBCO(i)),1)];
    
    spCO{i} = cat(2, tdCO([tdCO.bumpDir]== dirsBCO(i)).speed);
    meanSpCO(:,i) = mean(spCO{i},2);
    meanSpCOCI(:,:,i) = bootci(100, @mean, spCO{i}');
    posCO{i} = cat(1, tdCO([tdCO.bumpDir]== dirsBCO(i)).pos);

    fBD{i} = cat(3, tdBD(floor(rad2deg([tdBD.correctAngle]))== dirsBBD(i)).cuneate_spikes);
    meanFBD(:,:,i) = mean(fBD{i},3);
    meanFBDCI{i}(:,:,:) = permute(squeeze(bootci(100, @mean, permute(fBD{i}, [3,1,2]))),[2,3,1]);

    inputBD = [inputBD; reshape(fBD{i}(timesInc,:,:), sum(floor(rad2deg([tdBD.correctAngle])) == dirsBBD(i)), length(timesInc)* length(fBD{i}(1,:,1)))];

    classBD = [classBD; i*ones(sum(floor(rad2deg([tdBD.correctAngle])) == dirsBCO(i)),1)];
    
    spBD{i} = cat(2, tdBD(floor(rad2deg([tdBD.correctAngle]))== dirsBBD(i)).speed);
    meanSpBD(:,i) = mean(spBD{i},2);
    meanSpBDCI(:,:,i) = bootci(100, @mean, spBD{i}');
    posBD{i} = cat(1, tdBD(floor(rad2deg([tdBD.correctAngle]))== dirsBCO(i)).pos);
end

ldaBD = fitcdiscr(inputBD, classBD, 'discrimType', 'pseudoLinear');
ldaCO = fitcdiscr(inputCO, classCO, 'discrimType', 'pseudoLinear');

cvBD = crossval(ldaBD);
cvCO = crossval(ldaCO);

predBD = kfoldPredict(cvBD);
predCO= kfoldPredict(cvCO);

accBD(timesInc1) = sum(predBD == classBD)/length(classBD);
accCO(timesInc1) = sum(predCO == classCO)/length(classCO);

end
%%
figure
plot(accBD)
hold on
plot(accCO)
legend('BD', 'CO')
xlabel('Time of bump prediction')
ylabel('Prediction Accuracy')
%%
bin_size = tdCO(1).bin_size;
timeVec = before*tdCO(1).bin_size:bin_size:after*tdCO(1).bin_size;

colors = linspecer(8);

    figure
if plotSpeeds
for i=1:length(dirsBCO)
%     subplot(5,1,i)
%     hold on
    x_axis = timeVec;
    
    x_plot =[x_axis, fliplr(x_axis)];
    y_plotBD=[meanSpBDCI(1,:,i), fliplr(meanSpBDCI(2,:,i))];
    y_plotCO=[meanSpCOCI(1,:,i), fliplr(meanSpCOCI(2,:,i))];

    switch i
        case 1
            subplot(3,3,6)
        case 2
            subplot(3,3,2)
        case 3
            subplot(3,3,4)
        case 4
            subplot(3,3,8)
    end
    plot(timeVec, meanSpBD(:,i), 'Color', colors(i,:),'LineStyle', '--', 'LineWidth', 1)
    hold on
%     plot(timeVec, spBD{i}, 'Color', colors(i,:), 'LineWidth', .2)
    plot(timeVec, meanSpCO(:,i), 'Color', colors(i+4,:), 'LineWidth', 1)
%     plot(timeVec, spCO{i}, 'Color', colors(i+4,:), 'LineWidth', .2)

    fill(x_plot, y_plotCO, 1,'facecolor', colors(i,:), 'edgecolor', 'none', 'facealpha', 0.4);
    fill(x_plot, y_plotBD, 1,'facecolor', colors(i+4,:), 'edgecolor', 'none', 'facealpha', 0.6);
    ylim([0, 75])
    xlabel('Time (sec)')
    ylabel('Speed (cm/s)')
end
subplot(3,3,9)
plot([0,0], [1,1], 'Color','k', 'LineStyle', '--')
hold on
plot([0,0], [1,1], 'Color','k', 'LineStyle', '-')
legend('Bump Report', 'CO')

end
%%
if plotPos
figure
for i=1:length(dirsBCO)
%     subplot(5,1,i)
%     hold on
    x_axis = timeVec;
    
    x_plot =[x_axis, fliplr(x_axis)];
    y_plotBD=[meanSpBDCI(1,:,i), fliplr(meanSpBDCI(2,:,i))];
    y_plotCO=[meanSpCOCI(1,:,i), fliplr(meanSpCOCI(2,:,i))];

    switch i
        case 1
            subplot(3,3,6)
        case 2
            subplot(3,3,2)
        case 3
            subplot(3,3,4)
        case 4
            subplot(3,3,8)
    end
    scatter(posBD{i}(:,1), posBD{i}(:,2),16, colors(i,:))
    hold on
    scatter(posCO{i}(:,1), posCO{i}(:,2),16, colors(i+4,:))
    xlim([-15, 15])
    ylim([-45, -25])
    xlabel('Xpos')
    ylabel('Ypos')
end 
end
%%
mappingLog = getSensoryMappings(monkey);
% keyboard
colors = linspecer(4);

x_axis = timeVec;

x_plot =[x_axis, fliplr(x_axis)];
if plotResponses
for i = 1:length(guide(:,1))
    i2 = find(guide2(:,1) == guide(i,1) & guide2(:,2) == guide(i,2));
    if ~isempty(i2)
    figure
    maxFir = max(max([squeeze(meanFCO(:,i,:)), squeeze(meanFBD(:,i2,:))]));
    for j=1:length(dirsBCO)
        switch j
            case 1
                subplot(4,3,6)

            case 2
                subplot(4,3,2)

            case 3
                subplot(4,3,4)

            case 4
                subplot(4,3,8)

        end
        
        y_plotFCO{i,j}=[meanFCOCI{j}(:,i,1)', fliplr(meanFCOCI{j}(:,i,2)')];
        y_plotFBD{i,j}=[meanFBDCI{j}(:,i2,1)', fliplr(meanFBDCI{j}(:,i2,2)')];

        plot(timeVec, meanFCO(:,i,j), 'Color', colors(j,:))
        hold on
        plot(timeVec, meanFBD(:,i2,j), 'Color', colors(j,:),'LineStyle', '--')

        fill(x_plot, y_plotFCO{i,j}, 1,'facecolor', colors(j,:), 'edgecolor', 'none', 'facealpha', 0.4);
        fill(x_plot, y_plotFBD{i,j}, 1,'facecolor', colors(j,:), 'edgecolor', 'none', 'facealpha', 0.6);

        
        xlabel('Time (sec)')
        ylabel('FR (hz)')
        ylim([0,max(maxFir,.0001)])
        xlim([timeVec(1), timeVec(end)])
    end 
    suptitle(['Electrode ', num2str(guide(i,1)), ' Unit ', num2str(guide(i,2)), ' E', num2str(guide2(i2,1)), 'U', num2str(guide2(i2,2))])
    
    subplot(4,3,10:12)
    
    neuron.monkey = monkey;
    neuron.date = date;
    neuron.chan = guide(i,1);
    neuron.unitNum  = guide(i,2);
    neuron.mapName = getMapName(tdCO, neuron.chan);
    mapping = getClosestMap(neuron, mappingLog);
    if ischar(mapping)
        txt = 'No Mapping';
        txt = [txt, ' NA'];
    else
        txt = mapping.desc;
        daysDif = mapping.daysDif;
        txt = [txt, ' Days: ', num2str(daysDif)];
    end
    tx = text(0,0,txt);
    
    extent = tx.Extent;

    xlim([extent(1), extent(1) + extent(3)])
    ylim([extent(2), extent(2) + extent(4)])
    set(gca,'ycolor','w')
    set(gca,'xcolor','w')

    subplot(4,3,9)
    plot([0,0], [1,1], 'Color','k', 'LineStyle', '--')
    hold on
    plot([0,0], [1,1], 'Color','k', 'LineStyle', '-')
    legend('Bump Report', 'CO')

    pause
    end
end
end
