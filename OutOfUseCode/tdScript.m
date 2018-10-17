clear all
close all
load('Lando3142017COactpasCDS.mat')

params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
  td = parseFileByTrial(cds, params);
%%
params1.trials = 37;
visData(td, params1)

%%

bumpTrials = td(~isnan([td.bumpDir])); 
upBump = bumpTrials([bumpTrials.bumpDir] == 90);
leftBump = bumpTrials([bumpTrials.bumpDir] ==180);
downBump = bumpTrials([bumpTrials.bumpDir] ==270);
rightBump = bumpTrials([bumpTrials.bumpDir]==0);

%%
for i = 1:length(upBump)
    upRaster(i,:,:) = upBump(i).Cuneate_spikes(upBump(i).idx_bumpTime-20:upBump(i).idx_bumpTime+100,:);
end
for i = 1:length(downBump)
    downRaster(i,:,:) = downBump(i).Cuneate_spikes(downBump(i).idx_bumpTime-20:downBump(i).idx_bumpTime+100,:);
end
for i = 1:length(rightBump)
    rightRaster(i,:,:) = rightBump(i).Cuneate_spikes(rightBump(i).idx_bumpTime-20:rightBump(i).idx_bumpTime+100,:);
end
for i = 1:length(leftBump)
    leftRaster(i,:,:) = leftBump(i).Cuneate_spikes(leftBump(i).idx_bumpTime-20:leftBump(i).idx_bumpTime+100,:);
end


%% up plot 2
close all

for num1 = [17,20]
%     fig = figure('Position', [100, 100, 1300, 700]);
    title(['Unit ', num1])
%     subplot(3,3,5)
%     figure
    plot([1,1],[1,2],':', 'LineWidth', 2)
    hold on
    plot([1,1],[1,3],'r:', 'LineWidth', 2)
    xlim([2,3])
    legend('Bump Onset', 'Bump End')
%     figure
    %subplot(3,3,2)
    hold on
    before = .2;
    after = .25;
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 90, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'Cuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    plot([before,before], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([before + .125,before+.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)

    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];
        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1), spikeList(spike)-trialWindow(1)];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    xlim([0, before+after+.125])
    title('Up Bump')
    xlabel('time (ms)')

%     subplot(3,3,8)
    figure
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 270, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    plot([before,before], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([before + .125,before+.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];

        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1), spikeList(spike)-trialWindow(1)];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    xlim([0, before+after+.125])
    title('Down Bump')
    xlabel('time (ms)')

%     subplot(3,3,6)
    figure
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 0, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    plot([before,before], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([before + .125,before+.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];

        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1), spikeList(spike)-trialWindow(1)];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    xlim([0, before+after+.125])
    title('Right Bump')
    xlabel('time (ms)')

%     subplot(3,3,4)
    figure
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 180, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    plot([before,before], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([before + .125,before+.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];

        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1), spikeList(spike)-trialWindow(1)];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    title('Left Bump')
    xlabel('time (ms)')
    xlim([0, before+after+.125])
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(num1,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(num1,2))];
%     suptitle(title1)
    str  = [title1, '.eps'];
%     saveas(fig, str);
end
%% Kinematics
close all
upBumpKin = zeros(length(upBump), length(upBump(i).idx_bumpTime-20:upBump(i).idx_bumpTime+37), 2);
for  i = 1:length(upBump)
    upBumpKin(i,:,:) = upBump(i).vel(upBump(i).idx_bumpTime-20:upBump(i).idx_bumpTime+37,:);
    
end
meanUpKin = squeeze(mean(upBumpKin));
speedUpKin = sqrt(meanUpKin(:,1).^2 + meanUpKin(:,2).^2);

downBumpKin = zeros(length(downBump), 58, 2);
for  i = 1:length(downBump)
    downBumpKin(i,:,:) = downBump(i).vel(downBump(i).idx_bumpTime-20:downBump(i).idx_bumpTime+37,:);
    
end
meanDownKin = squeeze(mean(downBumpKin));
speedDownKin = sqrt(meanDownKin(:,1).^2 + meanDownKin(:,2).^2);

leftBumpKin = zeros(length(leftBump), 58, 2);
for  i = 1:length(leftBump)
    leftBumpKin(i,:,:) = leftBump(i).vel(leftBump(i).idx_bumpTime-20:leftBump(i).idx_bumpTime+37,:);
    
end
meanleftKin = squeeze(mean(leftBumpKin));
speedleftKin = sqrt(meanleftKin(:,1).^2 + meanleftKin(:,2).^2);

rightBumpKin = zeros(length(rightBump), 58, 2);
for  i = 1:length(rightBump)
    rightBumpKin(i,:,:) = rightBump(i).vel(rightBump(i).idx_bumpTime-20:rightBump(i).idx_bumpTime+37,:);
    
end
meanrightKin = squeeze(mean(rightBumpKin));
speedrightKin = sqrt(meanrightKin(:,1).^2 + meanrightKin(:,2).^2);
%{
figure
plot(meanrightKin(:,1), 'r')
hold on
plot(meanrightKin(:,2), 'b')
ylim([-40,40])
title('Right Bump Kinematics')
legend('x velocity', 'y velocity')
ylabel('Velocity (cm/s)')
saveas(gca, 'RightBumpKinematics.pdf')

figure
plot(meanleftKin(:,1), 'r')
hold on
plot(meanleftKin(:,2), 'b')
ylim([-40,40])
title('Left Bump Kinematics')
legend('x velocity', 'y velocity')
ylabel('Velocity (cm/s)')
saveas(gca, 'LeftBumpKinematics.pdf')

figure
plot(meanUpKin(:,1), 'r')
hold on
plot(meanUpKin(:,2), 'b')
ylim([-40,40])
title('Up Bump Kinematics')
legend('x velocity', 'y velocity')
ylabel('Velocity (cm/s)')
saveas(gca, 'UpBumpKinematics.pdf')

figure
plot(meanDownKin(:,1), 'r')
hold on
plot(meanDownKin(:,2), 'b')
ylim([-40,40])
title('Down Bump Kinematics')
legend('x velocity', 'y velocity')
ylabel('Velocity (cm/s)')
saveas(gca, 'DownBumpKinematics.pdf')
%}

figure
plot(linspace(0, 10*length(speedDownKin(:,1)), length(speedDownKin(:,1))), speedDownKin(:,1), 'k')
hold on
plot([200,200],[0,40], 'b--')
plot([325,325],[0,40], 'b--')
ylim([0,40])
title('Down Bump Kinematics')
ylabel('Velocity (cm/s)')
%saveas(gca, 'DownBumpKinematics.pdf')

figure
plot(linspace(0, 10*length(speedDownKin(:,1)), length(speedDownKin(:,1))), speedUpKin(:,1), 'k')
hold on
plot([200,200],[0,40], 'b--')
plot([325,325],[0,40], 'b--')
ylim([0,40])
title('Up Bump Kinematics')
ylabel('Velocity (cm/s)')
%saveas(gca, 'UpBumpKinematics.pdf')

figure
plot(linspace(0, 10*length(speedDownKin(:,1)), length(speedDownKin(:,1))),speedrightKin(:,1), 'k')
hold on
plot([200,200],[0,40], 'b--')
plot([325,325],[0,40], 'b--')
ylim([0,40])
title('Right Bump Kinematics')
ylabel('Velocity (cm/s)')
%saveas(gca, 'RightBumpKinematics.pdf')

figure
plot(linspace(0, 10*length(speedDownKin(:,1)), length(speedDownKin(:,1))),speedleftKin(:,1), 'k')
hold on
plot([200,200],[0,40], 'b--')
plot([325,325],[0,40], 'b--')
ylim([0,40])
title('Left Bump Kinematics')
ylabel('Velocity (cm/s)')
%saveas(gca, 'LeftBumpKinematics.pdf')
%% Unit Histograms
close all
before = 20;
after = 30;
unitsToPlot = 1:39;
upSpikes = zeros(length(upBump(1).Cuneate_spikes(1,:)), length([upBump(1).idx_bumpTime-before:upBump(1).idx_bumpTime+after]));
for unitNum= 1:length(upBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(upBump)
        upSpikes(unitNum, :) = upSpikes(unitNum,:) + [upBump(trialNum).Cuneate_spikes(upBump(trialNum).idx_bumpTime-before:upBump(trialNum).idx_bumpTime+after,unitNum)]';
    end
end
upSpikes = upSpikes.*100./length(upBump);

for i = unitsToPlot
    figure
    area(smooth(upSpikes(i,:),3))
    hold on
    plot([before,before], [0, max(upSpikes(i,:))],':', 'LineWidth', 2)
    plot([before + 12.5,before+12.5], [0, max(upSpikes(i,:))] ,'r:', 'LineWidth', 2)
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(i,2)), ' Up Bump'];
    title(title1)
    if i ==17
        ylim([0,140])
    else
        ylim([0, 80])
    end
%     saveas(gca, [title1, '.pdf'])
end

before = 20;
after = 30;
downSpikes = zeros(length(downBump(1).Cuneate_spikes(1,:)), length([downBump(1).idx_bumpTime-before:downBump(1).idx_bumpTime+after]));
for unitNum= 1:length(downBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(downBump)
        downSpikes(unitNum, :) = downSpikes(unitNum,:) + [downBump(trialNum).Cuneate_spikes(downBump(trialNum).idx_bumpTime-before:downBump(trialNum).idx_bumpTime+after,unitNum)]';
    end
end
downSpikes = downSpikes.*100./length(downBump);

for i = unitsToPlot
    figure
    area(smooth(downSpikes(i,:),3))
    hold on
    plot([before,before], [0, max(downSpikes(i,:))],':', 'LineWidth', 2)
    plot([before + 12.5,before+12.5], [0, max(downSpikes(i,:))] ,'r:', 'LineWidth', 2)
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(i,2)), ' Down Bump'];
    title(title1)
    if i ==17
        ylim([0,140])
    else
        ylim([0, 80])
    end
%     saveas(gca, [title1, '.pdf'])
end

before = 20;
after = 30;
rightSpikes = zeros(length(rightBump(1).Cuneate_spikes(1,:)), length([rightBump(1).idx_bumpTime-before:rightBump(1).idx_bumpTime+after]));
for unitNum= 1:length(rightBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(rightBump)
        rightSpikes(unitNum, :) = rightSpikes(unitNum,:) + [rightBump(trialNum).Cuneate_spikes(rightBump(trialNum).idx_bumpTime-before:rightBump(trialNum).idx_bumpTime+after,unitNum)]';
    end
end
rightSpikes = rightSpikes.*100./length(rightBump);

for i = unitsToPlot
    figure
    area(smooth(rightSpikes(i,:),3))
    hold on
    plot([before,before], [0, max(rightSpikes(i,:))],':', 'LineWidth', 2)
    plot([before + 12.5,before+12.5], [0, max(rightSpikes(i,:))] ,'r:', 'LineWidth', 2)
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(i,2)), ' Right Bump'];
    title(title1)
    if i ==17
        ylim([0,140])
    else
        ylim([0, 80])
    end
%     saveas(gca, [title1, '.pdf'])
end
before = 20;
after = 30;
leftSpikes = zeros(length(leftBump(1).Cuneate_spikes(1,:)), length([leftBump(1).idx_bumpTime-before:leftBump(1).idx_bumpTime+after]));
for unitNum= 1:length(leftBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(leftBump)
        leftSpikes(unitNum, :) = leftSpikes(unitNum,:) + [leftBump(trialNum).Cuneate_spikes(leftBump(trialNum).idx_bumpTime-before:leftBump(trialNum).idx_bumpTime+after,unitNum)]';
    end
end
leftSpikes = leftSpikes.*100./length(leftBump);

for i = 1:[length(leftBump(1).Cuneate_spikes(1,:))]
    figure
    area(smooth(leftSpikes(i,:),3))
    hold on
    plot([before,before], [0, max(leftSpikes(i,:))],':', 'LineWidth', 2)
    plot([before + 12.5,before+12.5], [0, max(leftSpikes(i,:))] ,'r:', 'LineWidth', 2)
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(i,2)), ' Left Bump'];
    title(title1)
    if i ==17
        ylim([0,140])
    else
        ylim([0, 80])
    end
    %saveas(gca, [title1, '.pdf'])
end
%% Waveshapes
close all
figure
unit77 = cds.units(234).spikes.wave;
waveTime = linspace(0, 1600, 48);
plot(waveTime, unit77(1:100:end,:)', 'k')
title('Electrode 77 Unit 1')
xlabel('Time (microseconds)')
ylabel('Voltage (microvolts')

figure
unit84 = cds.units(245).spikes.wave;
waveTime = linspace(0, 1600, 48);
plot(waveTime, unit84(1:100:end,:)', 'k')
title('Electrode 84 Unit 1')
xlabel('Time (microseconds)')
ylabel('Voltage (microvolts')

%% Tuning Curves
close all
upSpikesSumBump = zeros(length(upBump(1).Cuneate_spikes(1,:)),length(upBump));
upSpikesSumNoBump = zeros(length(upBump(1).Cuneate_spikes(1,:)),length(upBump));
for unitNum= 1:length(upBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(upBump)
        upSpikesSumBump(unitNum, trialNum) = mean([upBump(trialNum).Cuneate_spikes(upBump(trialNum).idx_bumpTime+1:upBump(trialNum).idx_bumpTime+6,unitNum)]').*100;
        upSpikesSumNoBump(unitNum, trialNum) =  mean([upBump(trialNum).Cuneate_spikes(upBump(trialNum).idx_bumpTime+13:upBump(trialNum).idx_bumpTime+18,unitNum)]').*100;
    end
end
meanUpBump = mean(upSpikesSumBump');
sDevupBump = std(upSpikesSumBump');
meanUpNoBump = mean(upSpikesSumNoBump');
sDevupNoBump = std(upSpikesSumNoBump');


downSpikesSumBump = zeros(length(downBump(1).Cuneate_spikes(1,:)),length(downBump));
downSpikesSumNoBump = zeros(length(downBump(1).Cuneate_spikes(1,:)),length(downBump));
for unitNum= 1:length(downBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(downBump)
        downSpikesSumBump(unitNum, trialNum) = mean([downBump(trialNum).Cuneate_spikes(downBump(trialNum).idx_bumpTime+1:downBump(trialNum).idx_bumpTime+6,unitNum)]').*100;
        downSpikesSumNoBump(unitNum, trialNum) =  mean([downBump(trialNum).Cuneate_spikes(downBump(trialNum).idx_bumpTime+13:downBump(trialNum).idx_bumpTime+18,unitNum)]').*100;
    end
end
meandownBump = mean(downSpikesSumBump');
sDevdownBump = std(downSpikesSumBump');
meandownNoBump = mean(downSpikesSumNoBump');
sDevdownNoBump = std(downSpikesSumNoBump');


rightSpikesSumBump = zeros(length(rightBump(1).Cuneate_spikes(1,:)),length(rightBump));
rightSpikesSumNoBump = zeros(length(rightBump(1).Cuneate_spikes(1,:)),length(rightBump));
for unitNum= 1:length(rightBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(rightBump)
        rightSpikesSumBump(unitNum, trialNum) = mean([rightBump(trialNum).Cuneate_spikes(rightBump(trialNum).idx_bumpTime+1:rightBump(trialNum).idx_bumpTime+6,unitNum)]').*100;
        rightSpikesSumNoBump(unitNum, trialNum) =  mean([rightBump(trialNum).Cuneate_spikes(rightBump(trialNum).idx_bumpTime+13:rightBump(trialNum).idx_bumpTime+18,unitNum)]').*100;
    end
end
meanrightBump = mean(rightSpikesSumBump');
sDevrightBump = std(rightSpikesSumBump');
meanrightNoBump = mean(rightSpikesSumNoBump');
sDevrightNoBump = std(rightSpikesSumNoBump');


leftSpikesSumBump = zeros(length(leftBump(1).Cuneate_spikes(1,:)),length(leftBump));
leftSpikesSumNoBump = zeros(length(leftBump(1).Cuneate_spikes(1,:)),length(leftBump));
for unitNum= 1:length(leftBump(1).Cuneate_spikes(1,:))
    for trialNum= 1:length(leftBump)
        leftSpikesSumBump(unitNum, trialNum) = mean([leftBump(trialNum).Cuneate_spikes(leftBump(trialNum).idx_bumpTime+1:leftBump(trialNum).idx_bumpTime+6,unitNum)]').*100;
        leftSpikesSumNoBump(unitNum, trialNum) =  mean([leftBump(trialNum).Cuneate_spikes(leftBump(trialNum).idx_bumpTime+13:leftBump(trialNum).idx_bumpTime+18,unitNum)]').*100;
    end
end
meanleftBump = mean(leftSpikesSumBump');
sDevleftBump = std(leftSpikesSumBump');
meanleftNoBump = mean(leftSpikesSumNoBump');
sDevleftNoBump = std(leftSpikesSumNoBump');
%%
close all
for i = [17,20]
    tuningRho = [meanrightBump(i), meanUpBump(i), meanleftBump(i), meandownBump(i), meanrightBump(i)];
    highSDRho = [tuningRho(1) + sDevrightBump(i), tuningRho(2) + sDevupBump(i), tuningRho(3) + sDevleftBump(i), tuningRho(4) + sDevdownBump(i), tuningRho(5) + sDevrightBump(i)];
    lowSDRho = [tuningRho(1) - sDevrightBump(i), tuningRho(2) - sDevupBump(i), tuningRho(3) - sDevleftBump(i), tuningRho(4) - sDevdownBump(i), tuningRho(5) - sDevrightBump(i)];
    tuningTheta= deg2rad([0, 90, 180, 270, 0]);
    figure    
    polar(0,90)
    hold on
    polar(tuningTheta, highSDRho, 'r')
    polar(tuningTheta, tuningRho, 'k')
    polar(tuningTheta, lowSDRho, 'r')
    
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(i,2)), ' Bump'];
    title(title1)
end
for i = [17,20]
    tuningRho = [meanrightNoBump(i), meanUpNoBump(i), meanleftNoBump(i), meandownNoBump(i), meanrightNoBump(i)];
    highSDRho = [tuningRho(1) + sDevrightNoBump(i), tuningRho(2) + sDevupNoBump(i), tuningRho(3) + sDevleftNoBump(i), tuningRho(4) + sDevdownNoBump(i), tuningRho(5) + sDevrightNoBump(i)];
    lowSDRho = [tuningRho(1) - sDevrightNoBump(i), tuningRho(2) - sDevupNoBump(i), tuningRho(3) - sDevleftNoBump(i), tuningRho(4) - sDevdownNoBump(i), tuningRho(5) - sDevrightNoBump(i)];
    tuningTheta= deg2rad([0, 90, 180, 270, 0]);
    figure   
    polar(0,90)
    hold on
    polar(tuningTheta, highSDRho, 'r')
    polar(tuningTheta, tuningRho, 'k')
    polar(tuningTheta, lowSDRho, 'r')
    
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(i,2)), ' NoBump'];
    title(title1)
end

%% PCA
% for i = 1:length(td)
%     firing(i,:) = td.Cuneate_spikes(i,td.idx_goCueTime:td.idx_goCueTime+40);
% end