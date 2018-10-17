clear all
close all
load('Lando3142017COactpasCDS.mat')

params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
td = parseFileByTrial(cds, params);
before = .2;
after = .7;
unitsToPlot = [1:39];
%% Data Preparation and sorting out trials

bumpTrials = td(~isnan([td.bumpDir])); 
upMove = td([td.target_direction] == pi/2);
leftMove = td([td.target_direction] ==pi);
downMove = td([td.target_direction] ==3*pi/2);
rightMove = td([td.target_direction]==0);

%% 
close all
upBumpKin = zeros(length(upMove), length(upMove(1).idx_goCueTime-(before*100):upMove(1).idx_goCueTime+(after*100)), 2);
for  i = 1:length(upMove)
    upBumpKin(i,:,:) = upMove(i).vel(upMove(i).idx_goCueTime-(before*100):upMove(i).idx_goCueTime+(after*100),:);
    
end
meanUpKin = squeeze(mean(upBumpKin));
speedUpKin = sqrt(meanUpKin(:,1).^2 + meanUpKin(:,2).^2);

downBumpKin = zeros(length(upMove), length(upMove(1).idx_goCueTime-(before*100):upMove(1).idx_goCueTime+(after*100)), 2);
for  i = 1:length(downMove)
    downBumpKin(i,:,:) = downMove(i).vel(downMove(i).idx_goCueTime-(before*100):downMove(i).idx_goCueTime+(after*100),:);
    
end
meanDownKin = squeeze(mean(downBumpKin));
speedDownKin = sqrt(meanDownKin(:,1).^2 + meanDownKin(:,2).^2);

leftBumpKin = zeros(length(upMove), length(upMove(1).idx_goCueTime-(before*100):upMove(1).idx_goCueTime+(after*100)), 2);
for  i = 1:length(leftMove)
    leftBumpKin(i,:,:) = leftMove(i).vel(leftMove(i).idx_goCueTime-(before*100):leftMove(i).idx_goCueTime+(after*100),:);
    
end
meanleftKin = squeeze(mean(leftBumpKin));
speedleftKin = sqrt(meanleftKin(:,1).^2 + meanleftKin(:,2).^2);

rightBumpKin = zeros(length(upMove), length(upMove(1).idx_goCueTime-(before*100):upMove(1).idx_goCueTime+(after*100)), 2);
for  i = 1:length(rightMove)
    rightBumpKin(i,:,:) = rightMove(i).vel(rightMove(i).idx_goCueTime-(before*100):rightMove(i).idx_goCueTime+(after*100),:);
end
meanrightKin = squeeze(mean(rightBumpKin));
speedrightKin = sqrt(meanrightKin(:,1).^2 + meanrightKin(:,2).^2);


%%
for num1 = unitsToPlot
    
    downBumpFiring = zeros(length(downMove), length(speedDownKin));
    upBumpFiring = zeros(length(upMove), length(speedDownKin));
    rightBumpFiring = zeros(length(rightMove), length(speedDownKin));
    leftBumpFiring = zeros(length(leftMove), length(speedDownKin));
    down = figure();
    subplot(2,1,1)
    plot(linspace(-1*before, after, length(speedDownKin(:,1))), speedDownKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    ylim([0,40])
    title('Down Bump Kinematics')
    ylabel('Velocity (cm/s)')
    %saveas(gca, 'DownBumpKinematics.pdf')

    up = figure();
    subplot(2,1,1);
    plot(linspace(-1*before, after, length(speedDownKin(:,1))), speedUpKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    ylim([0,40])
    title('Up Bump Kinematics')
    ylabel('Velocity (cm/s)')
    %saveas(gca, 'UpBumpKinematics.pdf')

    right= figure();
    subplot(2,1,1)
    plot(linspace(-1*before, after, length(speedDownKin(:,1))),speedrightKin(:,1), 'k')
    hold on
    plot([0, 0],[0,40], 'b--')
    ylim([0,40])
    title('Right Bump Kinematics')
    ylabel('Velocity (cm/s)')
    %saveas(gca, 'RightBumpKinematics.pdf')

    left = figure();
    subplot(2,1,1)
    plot(linspace(-1*before, after, length(speedDownKin(:,1))),speedleftKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    ylim([0,40])
    title('Left Bump Kinematics')
    ylabel('Velocity (cm/s)')
    
    set(0, 'CurrentFigure', up)
    subplot(2,1,1)
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
    xlim([-1*before, after])
    title('Up Bump')
    xlabel('time (ms)')
    for  i = 1:length(upMove)
        upBumpFiring(i,:) = upMove(i).Cuneate_spikes(upMove(i).idx_goCueTime-(before*100):upMove(i).idx_goCueTime+(after*100),num1);
    end
    meanupFiring = 100*mean(upBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meanupFiring)), meanupFiring)
    xlim([-1*before, after])
    title('Up Bump')
    xlabel('time (ms)')
    
    
    set(0, 'CurrentFigure', down)
    subplot(2,1,1)
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
    title('Down Bump')
    xlabel('time (ms)')
    for  i = 1:length(downMove)
        downBumpFiring(i,:) = downMove(i).Cuneate_spikes(downMove(i).idx_goCueTime-(before*100):downMove(i).idx_goCueTime+(after*100),num1);
    end
    meandownFiring = 100*mean(downBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meandownFiring)), meandownFiring)
    xlim([-1*before, after])
    title('Down Bump')
    xlabel('time (ms)')

    set(0, 'CurrentFigure', right)
    subplot(2,1,1)
    hold on
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 0, :);
    window = [[trialTable.goCueTime]-before, [trialTable.goCueTime]+after];
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
    for  i = 1:length(rightMove)
        rightBumpFiring(i,:) = rightMove(i).Cuneate_spikes(rightMove(i).idx_goCueTime-(before*100):rightMove(i).idx_goCueTime+(after*100),num1);
    end
    meanrightFiring = 100*mean(rightBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meanrightFiring)), meanrightFiring)
    xlim([-1*before, after])
    title('Right Bump')
    xlabel('time (ms)')

    set(0, 'CurrentFigure', left)
    subplot(2,1,1)
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
    title('Left Bump')
    xlabel('time (ms)')
    for  i = 1:length(leftMove)
        leftBumpFiring(i,:) = leftMove(i).Cuneate_spikes(leftMove(i).idx_goCueTime-(before*100):leftMove(i).idx_goCueTime+(after*100),num1);
    end
    meanleftFiring = 100*mean(leftBumpFiring);
    subplot(2,1,2)
    bar(linspace(-1*before, after, length(meanleftFiring)), meanleftFiring)
    title('Left Bump')
    xlabel('time (ms)')
    xlim([-1*before, after])
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(num1,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(num1,2))];
    
    maxFiringRate=  max([max(meanleftFiring),max(meanrightFiring), max(meanupFiring), max(meandownFiring)]);
    title1 = ['Electrode' num2str(td(1).Cuneate_unit_guide(num1,1)), ' Unit ', num2str(td(1).Cuneate_unit_guide(num1,2))];
    
    set(0, 'CurrentFigure', left)
    subplot(2,1,1)
    ylim([0,40])
    subplot(2,1,2)
    set(gca,'TickDir','out','box', 'off')
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'MoveLeft.pdf'])
    
    set(0, 'CurrentFigure', right)
    subplot(2,1,1)
    ylim([0,40])
    subplot(2,1,2)
    set(gca,'TickDir','out','box', 'off')
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'MoveRight.pdf'])
    
    set(0, 'CurrentFigure', up)
    subplot(2,1,1)
    set(gca,'TickDir','out','box', 'off')
    subplot(2,1,2)
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'MoveUp.pdf'])
    
    set(0, 'CurrentFigure', down)
    subplot(2,1,1)
    set(gca,'TickDir','out','box', 'off')
    subplot(2,1,2)
    ylim([0, maxFiringRate+.1*maxFiringRate]);
    suptitle(title1)
%     saveas(gca, [title1, 'MoveDown.pdf'])
    
end