%% Load the TD
close all
clearvars -except td1 td2 td3
savePlots = true;
savePlots1 = true;
plotSurf = true;
plotPDs = true;
unitNums = false;
task = 'OOR';
normalize1 = true;

if ~exist('td1')
for mon = 1:4
    switch mon
        case 1
            monkey = 'Snap';
            date = '20190924';
            sDate = date;
            array = 'cuneate';
            td1 = getTD(monkey, date, task,1);
            td1 = tdToBinSize(td1, 100);

        case 2
            
            monkey ='Butter';
            date = '20190117';
            cDate = date;
            array = 'cuneate';
            td2 = getTD(monkey,date, task,1);
            td22 =getTD(monkey,date, task,3);
            td2 = [td2, td22];
            td2 = removeNonMatchingNeurons(td2);
            td2 = tdToBinSize(td2, 100);
        case 3
            
            monkey = 'Han';
            date = '20170203';
            hDate = date;
            array = 'S1';
            td3 = getTD(monkey, date, task,1);
            td3 = splitTD(td3);
            td3 = tdToBinSize(td3, 100);
        case 4
            monkey = 'Duncan';
            date = '20191113';
            array = 'LeftS1';
            task = 'OOR';
            td4 = getTD(monkey, date, task,1);
% %             td4 = splitTD(td4);
            td4 = tdToBinSize(td4,100);

    end
end
end
for mon = 1:4
    switch mon
        case 1
            monkey = 'Snap';
            date = '20190924';
            array = 'cuneate';
            td = td1;
            array = 'cuneate';
        case 2
            monkey ='Butter';
            date = '20190117';
            array = 'cuneate';
            td = td2;
            array = 'cuneate';

        case 3
            monkey = 'Han';
            date = '20170203';
            array = 'S1';
            td = td3;
            array = 'S1';
        case 4
            monkey = 'Duncan';
            date = '20191113';
            array = 'LeftS1';
            td = td4;

    end
    params.start_idx        =  'idx_goCueTime';
    params.end_idx          =  'idx_endTargHoldTime';

td = smoothSignals(td, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .1));
for i= 1:length(td)
    if td(i).forceDir == 360
        td(i).forceDir = 0;
    end
end
mappingLog = getSensoryMappings(monkey);

td = removeUnsorted(td);
td = getSpeed(td);
if ~strcmp(monkey, 'Han')& ~strcmp(monkey, 'Duncan')
td = removeGracileTD(td);
elseif strcmp(monkey,'Han')
td = normalizeTDLabels(td);
end    
td = removeBadNeurons(td, struct('min_fr', 1));    

td = getMoveOnsetAndPeak(td, params);
guide = td(1).([array, '_unit_guide']);
spikes = [array, '_spikes'];

td = removeBadTrials(td);
[~, td] = getTDidx(td, 'result','R');
td(isnan([td.idx_movement_on])) = [];
td = trimTD(td, 'idx_movement_on', 'idx_endTargHoldTime');
dirsM = unique([td.target_direction]);
dirsM(isnan(dirsM)) = [];
if any(dirsM>7)
    dirsM(mod(dirsM, 45)~=0) = [];
else
    dirsM(mod(dirsM, pi/4)~=0) =[];
end
dirsF = unique([td.forceDir]);
dirsF(isnan(dirsF)) = [];
if any(dirsF>7)
    dirsF(mod(dirsF, 45)~=0) = [];
else
    dirsF(mod(dirsF, pi/4)~=0) =[];
end
% close all
clear meanFiring
for i = 1:length(dirsM)
    for j = 1:length(dirsF)
        tdMF = td([td.forceDir] == dirsF(j) & [td.target_direction] == dirsM(i));
        if ~isempty(tdMF)
        tdMF(isnan([tdMF.idx_peak_speed]))=[];
        tdMF = trimTD(tdMF, {'idx_peak_speed', -10}, {'idx_peak_speed', 10});
        meanFiring(i,j,:) = getMeanTD(tdMF, struct('signal', spikes));
        else
            meanFiring(i,j,:) = zeros(1,1,length(meanFiring(1,1,:)));
        end
    end
end

    
guide1 = td(1).([array, '_unit_guide']);
mkdir([getBasePath(),  'OOR', filesep, monkey, filesep, date '\plotting\ForceSurfaces2\']);
clear fVar vVar fDepth vDepth fMax vMax
mTuned = true(length(meanFiring(1,1,:)),1);
fTuned = true(length(meanFiring(1,1,:)), 1);
for i =1 :length(meanFiring(1,1,:))
    temp = meanFiring(:,:,i);
    totVar = std(temp(:));
    totVarCI = bootci(1000, {@std, temp(:)}, 'alpha', .0001);
    totRange = range(temp(:));
    totMax = max(temp(:));
    for j = 1:length(dirsM)
        if std(meanFiring(j,:,i)')>totVarCI(2)
            fTuned(i) = true;
        end
        fVar(i,j) = std(meanFiring(j,:,i)');
        fDepth(i,j) = range(meanFiring(j,:,i)');
        fMax(i,j) = max(meanFiring(j,:,i)');
    end
    if normalize1
        fVar(i,:) = fVar(i,:)./totVar;
        fDepth(i,:) = fDepth(i,:)./totRange;
        fMax(i,:) = fMax(i,:)./totMax;
    end
    
    for j = 1:length(dirsF)
        if std(meanFiring(:,j,i)')>totVarCI(2)
            mTuned(i) = true;
        end
        vVar(i,j) = std(meanFiring(:,j,i)');
        vDepth(i,j) = range(meanFiring(:,j,i)');
        vMax(i,j) = max(meanFiring(:,j,i)');
    end
    if normalize1
       vVar(i,:) = vVar(i,:)./totVar;
       vDepth(i,:) = vDepth(i,:)./totRange;
       vMax(i,:) = vMax(i,:)./totMax;
    end
    
    title1 = [monkey '_LoadVelInteractionElec' ,num2str(guide1(i,1)), 'U', num2str(guide1(i,2)),'.png'];
    if ~isempty(mappingLog)
    if ~contains(mappingLog(1).date, '/')
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'yyyyMMdd')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    else
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'MM/dd/yyyy')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    end
    end
    if plotSurf
    meanVDepth1 = mean(vDepth(i,:));
    meanFDepth1 = mean(fDepth(i,:));
    figure;
    surf(meanFiring(:,:,i))
    title([monkey, 'Load/Velocity interaction Elec: ' ,num2str(guide1(i,1)), ' unit: ', num2str(guide1(i,2)), ' moveDepth ', num2str(meanVDepth1), ' force Depth ', num2str(meanFDepth1)])
    ylabel('Movement direction')
    xlabel('Force direction')
    zlabel('Firing rate')
    if savePlots
        saveas(gca, [getBasePath(),  'OOR', filesep, monkey, filesep, date '\plotting\ForceSurfaces2\',title1])
    end
    end
end
tunedM(mon) = sum(mTuned);
tunedF(mon) = sum(fTuned);

meanFVar = mean(fVar');
meanVVar = mean(vVar');

meanFDepth = mean(vDepth(mTuned|fTuned,:)');
meanVDepth = mean(fDepth(fTuned|fTuned,:)');

meanFMax = mean(fMax');
meanVMax = mean(vMax');

vfVarRat{mon} = meanVVar./meanFVar;
vfDepthRat{mon} = meanVDepth./meanFDepth;
vfMaxRat{mon} = meanVMax./meanFMax;

guide = guide(mTuned| fTuned,:);


for j = 1:3
    switch j
        case 1
            dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
            figure
            hold on
            v = meanVVar;
            f = meanFVar;
%             title([monkey, ' Variance in force vs variance in velocity tuning'])
            xlabel('Mean Variance Force')
            ylabel('Mean Variance Velocity')
            set(gca,'TickDir','out', 'box', 'off')

        case 2
            dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points

            figure
            hold on
            v = meanVDepth;
            f = meanFDepth;
            title([monkey, 'Mean Velocity mod depth vs. Force Mod Depth (Normalized)'])
            xlabel('Mean Depth Force')
            ylabel('Mean Depth Velocity')
            meanV(mon,1) = mean(v);
            meanF(mon,1) = mean(f);
            meanV(mon,2:3) = abs(bootci(1000, @mean, v) - meanV(mon,1));
            meanF(mon,2:3) = abs(bootci(1000, @mean, f) - meanF(mon,1));
            errorbar(meanF(mon,1), meanV(mon,1), meanV(mon,2),meanV(mon,3), meanF(mon,2), meanF(mon,3))
            set(gca,'TickDir','out', 'box', 'off')

            
        case 3
            figure
            hold on
            dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
            title([monkey, ' Max FR in force vs velocity dims (Normalized)'])
            xlabel('Max FR across force dimension')
            ylabel('Max FR across Velocity dimension')
            v = meanVMax;
            f = meanFMax;
            set(gca,'TickDir','out', 'box', 'off')

    end 
    f = f(mTuned| fTuned);
    v = v(mTuned |fTuned);
    lm{j, mon} = fitlm(f, v);

    
    scatter(f, v, 'filled');
    colors = {'k', 'r', 'b', 'g', 'y'};
    if unitNums
    for i = 1:length(f(1,:))
        text(f(i)+ dx, v(i) +dy, num2str(guide(i,1)), 'Color', colors{guide(i,2)});
    end
    end
%     plot(lm{j,mon})
    max1 = max(max(f,v));
    linX = [0, max1];
    linY = [lm{j,mon}.Coefficients.Estimate(1), lm{j,mon}.Coefficients.Estimate(2)*max1 + lm{j,mon}.Coefficients.Estimate(1)];
    plot(linX, linY, 'r')
    xlim([0, max(max(f,v))])
    ylim([0, max(max(f,v))])
    if j == 2
            xlim([0,.8])
            ylim([0,.8])
    end
    slopes{j,mon} = lm{j,mon}.Coefficients.Estimate;
    tmp = coefCI(lm{j,mon});
    cCI(j,mon,:) = tmp(2,:);
end
    figure
    scatter(meanVVar, meanFDepth)
    title('Vel Variance vs V Depth')
    figure
    scatter(meanFVar, meanVDepth)
    title('F Variance vs F Depth')
end
%%
figure

histogram(vfVarRat{1})
hold on
histogram(vfVarRat{2})
histogram(vfVarRat{3})
histogram(vfVarRat{4})
legend('Snap', 'Butter', 'Han', 'Duncan')

figure
x = 1:length(meanV);
bar(x, meanV(:,1))
hold on
er = errorbar(x, meanV(:,1), meanV(:,2), meanV(:,3));
er.Color = [0,0,0];
er.LineStyle = 'none';
title('Mean Force Tuning Depth')
xticklabels({'Sn', 'Bu', 'Ha'})
set(gca,'TickDir','out', 'box', 'off')
xlabel('Monkey')
ylabel('Normalized Mean Tuning Depth')

figure
bar(x, meanF(:,1))
hold on
er = errorbar(x, meanF(:,1), meanF(:,2), meanF(:,3));
er.Color = [0,0,0];
er.LineStyle = 'none';
title('Mean Direction Tuning Depth')
xticklabels({'Sn', 'Bu', 'Ha'})
set(gca,'TickDir','out', 'box', 'off')
xlabel('Monkey')
ylabel('Normalized Mean Tuning Depth')

%%
tmp = [.775, 1.0, 1.225, 1.775, 2, 2.225];

figure
bar([meanV(:,1),meanF(:,1)]')
hold on
% er = errorbar(tmp, [meanV(:,1);meanF(:,1)], [meanV(:,2); meanF(:,2)], [meanV(:,3);meanF(:,3)]);

er.Color = [0,0,0];
er.LineStyle = 'none';
title('Mean Direction Tuning Depth')
xticklabels({'Force', 'Dir'})
set(gca,'TickDir','out', 'box', 'off')
xlabel('Dim')
ylabel('Normalized Mean Tuning Depth')
leg = legend('Sn', 'Bu', 'Ha (area 2)');
title(leg, 'Monkey')

%%
figure
histogram(vfDepthRat{1},10)
hold on
histogram(vfDepthRat{2},10)
histogram(vfDepthRat{3},10)

histogram(vfDepthRat{4},10)

figure
boxplot([vfDepthRat{1}';vfDepthRat{2}';vfDepthRat{3}';vfDepthRat{4}'], [ones(length(vfDepthRat{1}),1);2*ones(length(vfDepthRat{2}),1); 3*ones(length(vfDepthRat{3}),1); 4*ones(length(vfDepthRat{4}),1)]);
mean(vfDepthRat{1})
bootci(1000, @mean, vfDepthRat{1})
mean(vfDepthRat{2})
bootci(1000, @mean, vfDepthRat{2})
mean(vfDepthRat{3})
bootci(1000, @mean, vfDepthRat{3})
mean(vfDepthRat{4})
bootci(1000, @mean, vfDepthRat{4})

%%
for i = 1:4
    switch i
        case 1
            td = td1;
        case 2
            td = td2;
        case 3
            td = td3;
        case 4
            td = td4;
    end
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td, params);
    lengths{i} = [td.idx_endTargHoldTime] - [td.idx_movement_on];
    mLen(i) = mean(lengths{i});

end