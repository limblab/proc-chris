%clear all
close all
load('Lando20170314COactpasCDS.mat')

params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
td = parseFileByTrial(cds, params);
before = .2;
after = .25;
cuneateUnits= cds.units(strcmp({cds.units.array}, 'Cuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
unitsToPlot = [1:length(cuneateUnits)];
%% Data Preparation and sorting out trials
bumpTrials = td(~isnan([td.bumpDir])); 
upBump = bumpTrials([bumpTrials.bumpDir] == 90);
leftBump = bumpTrials([bumpTrials.bumpDir] ==180);
downBump = bumpTrials([bumpTrials.bumpDir] ==270);
rightBump = bumpTrials([bumpTrials.bumpDir]==0);

%% 
close all
upBumpKin = zeros(length(upBump), length(upBump(1).idx_bumpTime-(before*100):upBump(1).idx_bumpTime+(after*100)), 2);
for  i = 1:length(upBump)
    upBumpKin(i,:,:) = upBump(i).vel(upBump(i).idx_bumpTime-(before*100):upBump(i).idx_bumpTime+(after*100),:);
    
end
meanUpKin = squeeze(mean(upBumpKin));
speedUpKin = sqrt(meanUpKin(:,1).^2 + meanUpKin(:,2).^2);

downBumpKin = zeros(length(downBump), length(downBump(1).idx_bumpTime-(before*100):downBump(1).idx_bumpTime+(after*100)), 2);
for  i = 1:length(downBump)
    downBumpKin(i,:,:) = downBump(i).vel(downBump(i).idx_bumpTime-(before*100):downBump(i).idx_bumpTime+(after*100),:);
    
end
meanDownKin = squeeze(mean(downBumpKin));
speedDownKin = sqrt(meanDownKin(:,1).^2 + meanDownKin(:,2).^2);

leftBumpKin = zeros(length(leftBump), length(leftBump(1).idx_bumpTime-(before*100):leftBump(1).idx_bumpTime+(after*100)), 2);
for  i = 1:length(leftBump)
    leftBumpKin(i,:,:) = leftBump(i).vel(leftBump(i).idx_bumpTime-(before*100):leftBump(i).idx_bumpTime+(after*100),:);
    
end
meanleftKin = squeeze(mean(leftBumpKin));
speedleftKin = sqrt(meanleftKin(:,1).^2 + meanleftKin(:,2).^2);

rightBumpKin = zeros(length(rightBump), length(rightBump(1).idx_bumpTime-(before*100):rightBump(1).idx_bumpTime+(after*100)), 2);
for  i = 1:length(rightBump)
    rightBumpKin(i,:,:) = rightBump(i).vel(rightBump(i).idx_bumpTime-(before*100):rightBump(i).idx_bumpTime+(after*100),:);
end
meanrightKin = squeeze(mean(rightBumpKin));
speedrightKin = sqrt(meanrightKin(:,1).^2 + meanrightKin(:,2).^2);


%%
for num1 = unitsToPlot
    
    downBumpFiring = zeros(length(downBump), length(speedDownKin));
    upBumpFiring = zeros(length(upBump), length(speedDownKin));
    rightBumpFiring = zeros(length(rightBump), length(speedDownKin));
    leftBumpFiring = zeros(length(leftBump), length(speedDownKin));
    down = figure();
    subplot(2,1,1)
    plot(linspace(-1*before, after, length(speedDownKin(:,1))), speedDownKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'b--')
    ylim([0,40])
    title('Down Bump Kinematics')
    ylabel('Velocity (cm/s)')
    set(gca,'TickDir','out')
    %saveas(gca, 'DownBumpKinematics.pdf')

    up = figure();
    subplot(2,1,1);
    plot(linspace(-1*before, after, length(speedDownKin(:,1))), speedUpKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'r--')
    ylim([0,40])
    title('Up Bump Kinematics')
    ylabel('Velocity (cm/s)')
    set(gca,'TickDir','out')
    %saveas(gca, 'UpBumpKinematics.pdf')

    right= figure();
    subplot(2,1,1)
    plot(linspace(-1*before, after, length(speedDownKin(:,1))),speedrightKin(:,1), 'k')
    hold on
    plot([0, 0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'b--')
    ylim([0,40])
    title('Right Bump Kinematics')
    ylabel('Velocity (cm/s)')
    set(gca,'TickDir','out')
    %saveas(gca, 'RightBumpKinematics.pdf')

    left = figure();
    subplot(2,1,1)
    plot(linspace(-1*before, after, length(speedDownKin(:,1))),speedleftKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'b--')
    ylim([0,40])
    title('Left Bump Kinematics')
    ylabel('Velocity (cm/s)')
    set(gca,'TickDir','out')
    
    set(0, 'CurrentFigure', up)
    subplot(2,1,1)
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 90, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'Cuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([.125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];
        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1)-before, spikeList(spike)-trialWindow(1)-before];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    xlim([-1*before, after])
    title('Up Bump')
    xlabel('time (ms)')
    set(gca,'TickDir','out')
    for  i = 1:length(upBump)
        upBumpFiring(i,:) = upBump(i).Cuneate_spikes(upBump(i).idx_bumpTime-(before*100):upBump(i).idx_bumpTime+(after*100),num1);
    end
    meanupFiring = 100*mean(upBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meanupFiring)), meanupFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')
    xlim([-1*before, after])
    title('Up Bump')
    set(gca,'TickDir','out')
    xlabel('time (ms)')
    
    
    set(0, 'CurrentFigure', down)
    subplot(2,1,1)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 270, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([.125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];
        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1)-before, spikeList(spike)-trialWindow(1)-before];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    set(gca,'TickDir','out','box', 'off')
    xlim([-1*before, after])
    title('Down Bump')
    xlabel('time (ms)')
    for  i = 1:length(downBump)
        downBumpFiring(i,:) = downBump(i).Cuneate_spikes(downBump(i).idx_bumpTime-(before*100):downBump(i).idx_bumpTime+(after*100),num1);
    end
    meandownFiring = 100*mean(downBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meandownFiring)), meandownFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')
    xlim([-1*before, after])
    title('Down Bump')
    xlabel('time (ms)')
    set(gca,'TickDir','out')
    set(0, 'CurrentFigure', right)
    subplot(2,1,1)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 0, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([.125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        subplot(2,1,1)
        trialWindow = [window(trialNum,1), window(trialNum,2)];

        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1)-before, spikeList(spike)-trialWindow(1)-before];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end

    end
    xlim([-1*before, after])
    title('Right Bump')
    xlabel('time (ms)')
    set(gca,'TickDir','out','box', 'off')
    for  i = 1:length(rightBump)
        rightBumpFiring(i,:) = rightBump(i).Cuneate_spikes(rightBump(i).idx_bumpTime-(before*100):rightBump(i).idx_bumpTime+(after*100),num1);
    end
    meanrightFiring = 100*mean(rightBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meanrightFiring)), meanrightFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')
    xlim([-1*before, after])
    title('Right Bump')
    xlabel('time (ms)')
    set(gca,'TickDir','out')
    set(0, 'CurrentFigure', left)
    subplot(2,1,1)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 180, :);
    window = [[trialTable.bumpTime]-before, [trialTable.bumpTime]+after];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([ .125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];
        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1)-before, spikeList(spike)-trialWindow(1)-before];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
        
    end
    xlim([-1*before, after])
    title('Left Bump')
    xlabel('time (ms)')
    set(gca,'TickDir','out','box', 'off')
    for  i = 1:length(leftBump)
        leftBumpFiring(i,:) = leftBump(i).Cuneate_spikes(leftBump(i).idx_bumpTime-(before*100):leftBump(i).idx_bumpTime+(after*100),num1);
    end
    meanleftFiring = 100*mean(leftBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meanleftFiring)), meanleftFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')
    title('Left Bump')
    xlabel('time (ms)')
    xlim([-1*before, after])
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(num1,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(num1,2))];
    set(gca,'TickDir','out')
    maxFiringRate=  max([max(meanleftFiring),max(meanrightFiring), max(meanupFiring), max(meandownFiring)]);
    
    set(0, 'CurrentFigure', left)
    subplot(2,1,1)
    ylim([0,40])
    subplot(2,1,2)
    set(gca,'TickDir','out','box', 'off')
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'Left.pdf'])
    
    set(0, 'CurrentFigure', right)
    subplot(2,1,1)
    ylim([0,40])
    subplot(2,1,2)
    set(gca,'TickDir','out','box', 'off')
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'Right.pdf'])
    
    set(0, 'CurrentFigure', up)
    subplot(2,1,1)
    set(gca,'TickDir','out','box', 'off')
    subplot(2,1,2)
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'Up.pdf'])
    
    set(0, 'CurrentFigure', down)
    subplot(2,1,1)
    set(gca,'TickDir','out','box', 'off')
    subplot(2,1,2)
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'Down.pdf'])
end