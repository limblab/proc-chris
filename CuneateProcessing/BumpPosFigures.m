clear all
close all
load('LandoCODelay12162016CDS.mat')
plotRasters = 0;
params.extra_time = [.4,.4];
td = parseFileByTrial(cds, params);
before = .2;
after = .6;
before1 = .2;
after1 = .6;
unitsToPlot = [13];
params1.trials = 1:59;
visData(td, params1)

%% Data Preparation and sorting out trials

bumpTrials = td(~isnan([td.bumpDir])); 
upMove = td([td.target_direction] == pi/2);
leftMove = td([td.target_direction] ==pi);
downMove = td([td.target_direction] ==3*pi/2);
rightMove = td([td.target_direction]==0);

%% 
close all
for num1 = unitsToPlot
upBumpKin = zeros(length(upMove), length(upMove(1).idx_movement_on-(before*100):upMove(1).idx_movement_on+(after*100)), 2);
for  i = 1:length(upMove)
    upBumpKin(i,:,:) = upMove(i).pos(upMove(i).idx_movement_on-(before*100):upMove(i).idx_movement_on+(after*100),:);
    
end
meanUpKin = squeeze(mean(upBumpKin));
posUpKin = meanUpKin(:,2) - mean(meanUpKin(:,2));

downBumpKin = zeros(length(upMove), length(upMove(1).idx_movement_on-(before*100):upMove(1).idx_movement_on+(after*100)), 2);
for  i = 1:length(downMove)
    downBumpKin(i,:,:) = downMove(i).pos(downMove(i).idx_movement_on-(before*100):downMove(i).idx_movement_on+(after*100),:);
    
end
meanDownKin = squeeze(mean(downBumpKin));
posDownKin = meanDownKin(:,2)- mean(meanDownKin(:,2));

leftBumpKin = zeros(length(upMove), length(upMove(1).idx_movement_on-(before*100):upMove(1).idx_movement_on+(after*100)), 2);
for  i = 1:length(leftMove)
    leftBumpKin(i,:,:) = leftMove(i).pos(leftMove(i).idx_movement_on-(before*100):leftMove(i).idx_movement_on+(after*100),:);
    
end
meanleftKin = squeeze(mean(leftBumpKin));
posleftKin = meanleftKin(:,1);

rightBumpKin = zeros(length(upMove), length(upMove(1).idx_movement_on-(before*100):upMove(1).idx_movement_on+(after*100)), 2);
for  i = 1:length(rightMove)
    rightBumpKin(i,:,:) = rightMove(i).pos(rightMove(i).idx_movement_on-(before*100):rightMove(i).idx_movement_on+(after*100),:);
end
meanrightKin = squeeze(mean(rightBumpKin));
posrightKin = meanrightKin(:,1);


%%

    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(num1,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(num1,2))];

    downBumpFiring = zeros(length(downMove), length(posDownKin));
    upBumpFiring = zeros(length(upMove), length(posDownKin));
    rightBumpFiring = zeros(length(rightMove), length(posDownKin));
    leftBumpFiring = zeros(length(leftMove), length(posDownKin));
    down = figure();
    suptitle([title1, ' Down'])
    subplot(2,2,2)
    plot(linspace(-1*before, after, length(posDownKin(:,1))), posDownKin(:,1), 'k')
    hold on
    plot([0,0],[-20,20], 'b--')
    ylim([-20,20])
    xlim([-1*before, after])
    %saveas(gca, 'DownBumpKinematics.pdf')

    up = figure();
    suptitle([title1, ' Up'])
    subplot(2,2,2);
    plot(linspace(-1*before, after, length(posDownKin(:,1))), posUpKin(:,1), 'k')
    hold on
    plot([0,0],[-20,20], 'b--')
    ylim([-20,20])
    xlim([-1*before, after])

    %saveas(gca, 'UpBumpKinematics.pdf')

    right= figure();
    suptitle([title1, ' Right'])
    subplot(2,2,2)
    plot(linspace(-1*before, after, length(posDownKin(:,1))),posrightKin(:,1), 'k')
    hold on
    plot([0, 0],[-20,20], 'b--')
    ylim([-20,20])
    xlim([-1*before, after])
    %saveas(gca, 'RightBumpKinematics.pdf')

    left = figure();
    suptitle([title1, ' Left'])
    subplot(2,2,2)
    plot(linspace(-1*before, after, length(posDownKin(:,1))),posleftKin(:,1), 'k')
    hold on
    plot([0,0],[-20,20], 'b--')
    ylim([-20,20])
    xlim([-1*before, after])
    
    set(0, 'CurrentFigure', up)
    if plotRasters
        subplot(2,2,2)
        trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 90, :);
        window = [[trialTable.goCueTime]-before, [trialTable.goCueTime]+after];
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
    end
    xlim([-1*before, after])
    for  i = 1:length(upMove)
        upBumpFiring(i,:) = upMove(i).Cuneate_spikes(upMove(i).idx_movement_on-(before*100):upMove(i).idx_movement_on+(after*100),num1);
    end
    meanupFiring = 100*mean(upBumpFiring);
    subplot(2,2,4)
    bar(linspace(-1*before, after, length(meanupFiring)), meanupFiring, 'edgecolor', 'none')
    xlim([-1*before, after])
    set(gca, 'TickDir', 'out', 'box', 'off')
    
    
    set(0, 'CurrentFigure', down)
    subplot(2,2,2)
    if plotRasters
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 270, :);
    window = [[trialTable.goCueTime]-before, [trialTable.goCueTime]+after];
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
    end
    for  i = 1:length(downMove)
        downBumpFiring(i,:) = downMove(i).Cuneate_spikes(downMove(i).idx_movement_on-(before*100):downMove(i).idx_movement_on+(after*100),num1);
    end
    meandownFiring = 100*mean(downBumpFiring);
    subplot(2,2,4)
    bar(linspace(-1*before, after, length(meandownFiring)), meandownFiring, 'edgecolor', 'none')
    xlim([-1*before, after])

    set(0, 'CurrentFigure', right)
    if plotRasters
    subplot(2,2,2)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 0, :);
    window = [[trialTable.goCueTime]-before, [trialTable.goCueTime]+after];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([.125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        subplot(2,2,1)
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

    end
    for  i = 1:length(rightMove)
        rightBumpFiring(i,:) = rightMove(i).Cuneate_spikes(rightMove(i).idx_movement_on-(before*100):rightMove(i).idx_movement_on+(after*100),num1);
    end
    meanrightFiring = 100*mean(rightBumpFiring);
    subplot(2,2,4)
    bar(linspace(-1*before, after, length(meanrightFiring)), meanrightFiring, 'edgecolor', 'none')
    xlim([-1*before, after])


    set(0, 'CurrentFigure', left)
    if plotRasters
    subplot(2,2,2)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 180, :);
    window = [[trialTable.goCueTime]-before, [trialTable.goCueTime]+after];
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
    end
    for  i = 1:length(leftMove)
        leftBumpFiring(i,:) = leftMove(i).Cuneate_spikes(leftMove(i).idx_movement_on-(before*100):leftMove(i).idx_movement_on+(after*100),num1);
    end
    meanleftFiring = 100*mean(leftBumpFiring);
    subplot(2,2,4)
    bar(linspace(-1*before, after, length(meanleftFiring)), meanleftFiring, 'edgecolor', 'none')
    xlim([-1*before, after])
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(num1,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(num1,2))];
    
    maxFiringRate=  max([max(meanleftFiring),max(meanrightFiring), max(meanupFiring), max(meandownFiring)]);
   
    set(0, 'CurrentFigure', left)
    subplot(2,2,2)
    ylim([-20,20])
    set(gca,'TickDir','out','box', 'off')
    subplot(2,2,4)
    set(gca,'TickDir','out','box', 'off')
    ylim([0, maxFiringRate+.1*maxFiringRate]);


    
    set(0, 'CurrentFigure', right)
    subplot(2,2,2)
    ylim([-20,20])
    set(gca,'TickDir','out','box', 'off')

    subplot(2,2,4)
    set(gca,'TickDir','out','box', 'off')
    ylim([0, maxFiringRate+.1*maxFiringRate]);
%     saveas(gca, [title1, 'MoveRight.pdf'])
    
    set(0, 'CurrentFigure', up)
    subplot(2,2,2)
    set(gca,'TickDir','out','box', 'off')
    ylim([-20,20])
    subplot(2,2,4)
    ylim([0, maxFiringRate+.1*maxFiringRate]);
%     saveas(gca, [title1, 'MoveUp.pdf'])
    
    set(0, 'CurrentFigure', down)
    subplot(2,2,2)
    set(gca,'TickDir','out','box', 'off')
    ylim([-20,20])
    subplot(2,2,4)
    ylim([0, maxFiringRate+.1*maxFiringRate]);
%     saveas(gca, [title1, 'MoveDown.pdf'])
    


%% Data Preparation and sorting out trials
bumpTrials = td(~isnan([td.bumpDir])); 
upBump = bumpTrials([bumpTrials.bumpDir] == 90);
leftBump = bumpTrials([bumpTrials.bumpDir] ==180);
downBump = bumpTrials([bumpTrials.bumpDir] ==270);
rightBump = bumpTrials([bumpTrials.bumpDir]==0);

%% 
upBumpKin = zeros(length(upBump), length(upBump(1).idx_bumpTime-(before1*100):upBump(1).idx_bumpTime+(after1*100)), 2);
for  i = 1:length(upBump)
    upBumpKin(i,:,:) = upBump(i).pos(upBump(i).idx_bumpTime-(before1*100):upBump(i).idx_bumpTime+(after1*100),:);
    
end
meanUpKin = squeeze(mean(upBumpKin));
posUpKin = meanUpKin(:,2)- mean(meanUpKin(:,2));

downBumpKin = zeros(length(downBump), length(downBump(1).idx_bumpTime-(before1*100):downBump(1).idx_bumpTime+(after1*100)), 2);
for  i = 1:length(downBump)
    downBumpKin(i,:,:) = downBump(i).pos(downBump(i).idx_bumpTime-(before1*100):downBump(i).idx_bumpTime+(after1*100),:);
end
meanDownKin = squeeze(mean(downBumpKin));
posDownKin = meanDownKin(:,2) - mean(meanDownKin(:,2));

leftBumpKin = zeros(length(leftBump), length(leftBump(1).idx_bumpTime-(before1*100):leftBump(1).idx_bumpTime+(after1*100)), 2);
for  i = 1:length(leftBump)
    leftBumpKin(i,:,:) = leftBump(i).pos(leftBump(i).idx_bumpTime-(before1*100):leftBump(i).idx_bumpTime+(after1*100),:);
    
end
meanleftKin = squeeze(mean(leftBumpKin));
posleftKin = meanleftKin(:,1);

rightBumpKin = zeros(length(rightBump), length(rightBump(1).idx_bumpTime-(before1*100):rightBump(1).idx_bumpTime+(after1*100)), 2);
for  i = 1:length(rightBump)
    rightBumpKin(i,:,:) = rightBump(i).pos(rightBump(i).idx_bumpTime-(before1*100):rightBump(i).idx_bumpTime+(after1*100),:);
end
meanrightKin = squeeze(mean(rightBumpKin));
posrightKin = meanrightKin;


%%

    downBumpFiring = zeros(length(downBump), length(posDownKin));
    upBumpFiring = zeros(length(upBump), length(posDownKin));
    rightBumpFiring = zeros(length(rightBump), length(posDownKin));
    leftBumpFiring = zeros(length(leftBump), length(posDownKin));
    set(0, 'CurrentFigure', down)
    subplot(2,2,1)
    plot(linspace(-1*before1, after1, length(posDownKin(:,1))), posDownKin(:,1), 'k')
    hold on
    plot([0,0],[-20,20], 'b--')
    plot([.125,.125],[-20,20], 'b--')
    ylim([-20,20])
    set(gca,'TickDir','out')
    %saveas(gca, 'DownBumpKinematics.pdf')

    set(0, 'CurrentFigure', up)
    subplot(2,2,1);
    plot(linspace(-1*before1, after1, length(posDownKin(:,1))), posUpKin(:,1), 'k')
    hold on
    plot([0,0],[-20,20], 'b--')
    plot([.125,.125],[-20,20], 'r--')
    ylim([-20,20])
    set(gca,'TickDir','out')
    %saveas(gca, 'UpBumpKinematics.pdf')

    set(0, 'CurrentFigure', right)
    subplot(2,2,1)
    plot(linspace(-1*before1, after1, length(posDownKin(:,1))),posrightKin(:,1), 'k')
    hold on
    plot([0, 0],[-20,20], 'b--')
    plot([.125,.125],[-20,20], 'b--')
    ylim([-20,20])
    set(gca,'TickDir','out')
    %saveas(gca, 'RightBumpKinematics.pdf')

    set(0, 'CurrentFigure', left)
    subplot(2,2,1)
    plot(linspace(-1*before1, after1, length(posDownKin(:,1))),posleftKin(:,1), 'k')
    hold on
    plot([0,0],[-20,20], 'b--')
    plot([.125,.125],[-20,20], 'b--')
    ylim([-20,20])

    set(gca,'TickDir','out')
    
    set(0, 'CurrentFigure', up)
    subplot(2,2,1)
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 90, :);
    window = [[trialTable.bumpTime]-before1, [trialTable.bumpTime]+after1];
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
            x = [spikeList(spike)-trialWindow(1)-before1, spikeList(spike)-trialWindow(1)-before1];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    xlim([-1*before1, after1])
    set(gca,'TickDir','out')
    for  i = 1:length(upBump)
        upBumpFiring(i,:) = upBump(i).Cuneate_spikes(upBump(i).idx_bumpTime-(before1*100):upBump(i).idx_bumpTime+(after1*100),num1);
    end
    meanupFiring = 100*mean(upBumpFiring);
    subplot(2,2,3)
    bar(linspace(-1*before1, after1, length(meanupFiring)), meanupFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')
    xlim([-1*before1, after1])
    set(gca,'TickDir','out')
    
    
    set(0, 'CurrentFigure', down)
    subplot(2,2,1)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 270, :);
    window = [[trialTable.bumpTime]-before1, [trialTable.bumpTime]+after1];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([.125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];
        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1)-before1, spikeList(spike)-trialWindow(1)-before1];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
    end
    set(gca,'TickDir','out','box', 'off')
    xlim([-1*before1, after1])
    for  i = 1:length(downBump)
        downBumpFiring(i,:) = downBump(i).Cuneate_spikes(downBump(i).idx_bumpTime-(before1*100):downBump(i).idx_bumpTime+(after1*100),num1);
    end
    meandownFiring = 100*mean(downBumpFiring);
    subplot(2,2,3)
    bar(linspace(-1*before1, after1, length(meandownFiring)), meandownFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')
    xlim([-1*before1, after1])

    set(gca,'TickDir','out')
    set(0, 'CurrentFigure', right)
    subplot(2,2,1)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 0, :);
    window = [[trialTable.bumpTime]-before1, [trialTable.bumpTime]+after1];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([.125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        subplot(2,2,1)
        trialWindow = [window(trialNum,1), window(trialNum,2)];

        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1)-before1, spikeList(spike)-trialWindow(1)-before1];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end

    end
    xlim([-1*before1, after1])

    set(gca,'TickDir','out','box', 'off')
    for  i = 1:length(rightBump)
        rightBumpFiring(i,:) = rightBump(i).Cuneate_spikes(rightBump(i).idx_bumpTime-(before1*100):rightBump(i).idx_bumpTime+(after1*100),num1);
    end
    meanrightFiring = 100*mean(rightBumpFiring);
    subplot(2,2,3)
    bar(linspace(-1*before1, after1, length(meanrightFiring)), meanrightFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')
    xlim([-1*before1, after1])
    set(gca,'TickDir','out')
    set(0, 'CurrentFigure', left)
    subplot(2,2,1)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 180, :);
    window = [[trialTable.bumpTime]-before1, [trialTable.bumpTime]+after1];
    plot([0,0], [0, height(trialTable)+2],':', 'LineWidth', 2)
    plot([ .125,.125], [0, height(trialTable)+2],'r:', 'LineWidth', 2)
    for trialNum = 1:height(trialTable)
        trialWindow = [window(trialNum,1), window(trialNum,2)];
        first = find(spikeList>trialWindow(1),1);
        last = find(spikeList >trialWindow(2),1)-1;
        for spike = first:last
            x = [spikeList(spike)-trialWindow(1)-before1, spikeList(spike)-trialWindow(1)-before1];
            y = [trialNum, trialNum+.5];
            plot(x,y,'k')
            hold on
        end
        
    end
    xlim([-1*before1, after1])

    set(gca,'TickDir','out','box', 'off')
    for  i = 1:length(leftBump)
        leftBumpFiring(i,:) = leftBump(i).Cuneate_spikes(leftBump(i).idx_bumpTime-(before1*100):leftBump(i).idx_bumpTime+(after1*100),num1);
    end
    meanleftFiring = 100*mean(leftBumpFiring);
    subplot(2,2,3)
    bar(linspace(-1*before1, after1, length(meanleftFiring)), meanleftFiring, 'edgecolor', 'none')
    set(gca, 'box', 'off')

    xlim([-1*before1, after1])
    set(gca,'TickDir','out')
    maxFiringRate=  max([max(meanleftFiring),max(meanrightFiring), max(meanupFiring), max(meandownFiring)]);   


saveas(right, [title1, 'Right.png'])
saveas(left, [title1, 'Left.png'])
saveas(up, [title1, 'Up.png'])
saveas(down, [title1, 'Down.png'])


end
