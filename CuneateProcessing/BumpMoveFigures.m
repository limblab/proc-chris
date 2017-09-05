% clear all
close all
clearvars -except cds td
%load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 0;
params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
params.extra_time = [.4,.4];
td = parseFileByTrial(cds, params);
td = getMoveOnsetAndPeak(td);
beforeBump = .5;
afterBump = .6;
beforeMove = .5;
afterMove = .6;
trialCds = cds.trials([cds.trials.result] =='R', :);
startTimes = trialCds.startTime;
w = gausswin(10);
for i = 1:length(td)
    td(i).StartTime = startTimes(i);
end
unitsToPlot = [1]; %Bump Tuned
% unitsToPlot = [3,4,5,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,28,29,31,36,38]; % MoveTuned
 numCount = 1:length(td(1).RightCuneate_spikes(1,:));
% unitsToPlot = numCount;
numCount = unitsToPlot;
%% Data Preparation and sorting out trials

bumpTrials = td(~isnan([td.bumpDir])); 
upMove = td([td.target_direction] == pi/2 & isnan([td.bumpDir]));
leftMove = td([td.target_direction] ==pi& isnan([td.bumpDir]));
downMove = td([td.target_direction] ==3*pi/2& isnan([td.bumpDir]));
rightMove = td([td.target_direction]==0& isnan([td.bumpDir]));

%% 
close all
for num1 = numCount
    title1 = ['Electrode' num2str(td(1).RightCuneate_unit_guide(num1,1)), ' Unit ', num2str(td(1).RightCuneate_unit_guide(num1,2))];

    %% Up Active
    upBump = bumpTrials([bumpTrials.bumpDir] == 90);
    upMoveKin = zeros(length(upMove), length(upMove(1).idx_movement_on-(beforeMove*100):upMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics
    for  i = 1:length(upMove)
        upMoveKin(i,:,:) = upMove(i).vel(upMove(i).idx_movement_on-(beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),:);
        upMoveForce(i,:,:) = upMove(i).force(upMove(i).idx_movement_on- (beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),:);
    end
    meanUpKin = squeeze(mean(upMoveKin));
    speedUpKin = sqrt(meanUpKin(:,1).^2 + meanUpKin(:,2).^2);
    meanupForce = squeeze(mean(upMoveForce));
    
    upMoveFiring = zeros(length(upMove), length(speedUpKin));
    up = figure();
    suptitle([title1, ' Up'])
    subplot(2,2,2);
    plot(linspace(-1*beforeMove, afterMove, length(speedUpKin(:,1))), speedUpKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    ylim([0,40])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off')  

    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 90 & isnan([cds.trials.bumpTime]) ,:);
    window = [[trialTable.startTime] + .01* [upMove.idx_movement_on]' - .01*[upMove.idx_startTime]'-beforeMove, [trialTable.startTime]+ .01*[upMove.idx_movement_on]'- .01*[upMove.idx_startTime]'+afterMove];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeMove, spikeList(spike)-trialWindow(1)-beforeMove];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,1), 'b')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,2), 'r')

    
    % Up Passive Kinematics
    upBumpKin = zeros(length(upBump), length(upBump(1).idx_bumpTime-(beforeBump*100):upBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(upBump)
        upBumpKin(i,:,:) = upBump(i).vel(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),:);
        upBumpForce(i,:,:)=upBump(i).force(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),:);
    end
    meanUpKin = squeeze(mean(upBumpKin));
    speedUpKin = sqrt(meanUpKin(:,1).^2 + meanUpKin(:,2).^2); 
    meanupForce = squeeze(mean(upBumpForce));
    
    subplot(2,2,1);
    plot(linspace(-1*beforeBump, afterBump, length(speedUpKin(:,1))), speedUpKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'r--')
    ylim([0,40])
    set(gca,'TickDir','out', 'box', 'off') 
    xlim([-1*beforeBump, afterBump])
    
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 90, :);
    window = [[trialTable.bumpTime]-beforeBump, [trialTable.bumpTime]+afterBump];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeBump, spikeList(spike)-trialWindow(1)-beforeBump];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,2), 'r')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,1), 'b')

    
    
    % Up Move Firing
    subplot(2,2,4)
    xlim([-1*beforeMove, afterMove])
    for  i = 1:length(upMove)
        upMoveFiring(i,:) = upMove(i).RightCuneate_spikes(upMove(i).idx_movement_on-(beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meanupMoveFiring = 100*mean(upMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meanupMoveFiring)), conv(meanupMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    xlim([-1*beforeMove, afterMove])
    %Up Bump Firing
    subplot(2,2,3)
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out')
    upBumpFiring = zeros(length(upBump), length(speedUpKin));
    for  i = 1:length(upBump)
        upBumpFiring(i,:) = upBump(i).RightCuneate_spikes(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meanupFiring = 100*mean(upBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meanupFiring)), conv(meanupFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)

    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
    

    %saveas(gca, 'UpBumpKinematics.pdf')
      
    %% down active
    downBump = bumpTrials([bumpTrials.bumpDir] == 270);
    downMoveKin = zeros(length(downMove), length(downMove(1).idx_movement_on-(beforeMove*100):downMove(1).idx_movement_on+(afterMove*100)), 2);
    downMoveForce = zeros(length(downMove), length(downMove(1).idx_movement_on-(beforeMove*100):downMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics
    for  i = 1:length(downMove)
        downMoveKin(i,:,:) = downMove(i).vel(downMove(i).idx_movement_on-(beforeMove*100):downMove(i).idx_movement_on+(afterMove*100),:);
        downMoveForce(i,:,:)= downMove(i).force(downMove(i).idx_movement_on -(beforeMove*100):downMove(i).idx_movement_on + (afterMove*100),:);
    end
    meandownKin = squeeze(mean(downMoveKin));
    speeddownKin = sqrt(meandownKin(:,1).^2 + meandownKin(:,2).^2);
    meandownForce1 = squeeze(mean(downMoveForce));
    
    downMoveFiring = zeros(length(downMove), length(speeddownKin));
    down = figure();
    suptitle([title1, ' down'])
    subplot(2,2,2);
    plot(linspace(-1*beforeMove, afterMove, length(speeddownKin(:,1))), speeddownKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    ylim([0,40])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off')

    % down Passive Kinematics
    downBumpKin = zeros(length(downBump), length(downBump(1).idx_bumpTime-(beforeBump*100):downBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(downBump)
        downBumpKin(i,:,:) = downBump(i).vel(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),:);
        downBumpForce(i,:,:)= downBump(i).force(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),:);
       
    end
    meandownKin = squeeze(mean(downBumpKin));
    speeddownKin = sqrt(meandownKin(:,1).^2 + meandownKin(:,2).^2);
    meandownForce = squeeze(mean(downBumpForce));
    
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 270 & isnan([cds.trials.bumpTime]) ,:);
    window = [[trialTable.startTime] + .01* [downMove.idx_movement_on]' - .01*[downMove.idx_startTime]'-beforeMove, [trialTable.startTime]+ .01*[downMove.idx_movement_on]'- .01*[downMove.idx_startTime]'+afterMove];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeMove, spikeList(spike)-trialWindow(1)-beforeMove];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(meandownForce1(:,1))), meandownForce1(:,2), 'b')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(meandownForce1(:,1))), meandownForce1(:,1), 'r')

    
    subplot(2,2,1);
    plot(linspace(-1*beforeBump, afterBump, length(speeddownKin(:,1))), speeddownKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'r--')
    ylim([0,40])
    set(gca,'TickDir','out', 'box', 'off') 
    xlim([-1*beforeBump, afterBump])
    
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 270, :);
    window = [[trialTable.bumpTime]-beforeBump, [trialTable.bumpTime]+afterBump];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeBump, spikeList(spike)-trialWindow(1)-beforeBump];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(meandownForce(:,1))), meandownForce(:,1), 'r')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(meandownForce(:,1))), meandownForce(:,2), 'b')

    
    % down Move Firing
    subplot(2,2,4)
    xlim([-1*beforeMove, afterMove])
    for  i = 1:length(downMove)
        downMoveFiring(i,:) = downMove(i).RightCuneate_spikes(downMove(i).idx_movement_on-(beforeMove*100):downMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meandownMoveFiring = 100*mean(downMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meandownMoveFiring)), conv(meandownMoveFiring,w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    xlim([-1*beforeMove, afterMove])
    
    %down Bump Firing
    subplot(2,2,3)
    xlim([-1*beforeBump, afterBump])
    set(gca,'TickDir','out')
    downBumpFiring = zeros(length(downBump), length(speeddownKin));
    for  i = 1:length(downBump)
        downBumpFiring(i,:) = downBump(i).RightCuneate_spikes(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meandownFiring = 100*mean(downBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meandownFiring)), conv(meandownFiring,w ,'same'), 'edgecolor', 'none', 'BarWidth', 1)

    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
        %saveas(gca, 'downBumpKinematics.pdf')
        
      
      %% left Passive
    leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
    leftMoveKin = zeros(length(leftMove), length(leftMove(1).idx_movement_on-(beforeMove*100):leftMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics

    for  i = 1:length(leftMove)
        leftMoveKin(i,:,:) = leftMove(i).vel(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),:);
        leftMoveForce(i,:,:)= leftMove(i).force(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),:);
    end
    meanleftKin = squeeze(mean(leftMoveKin));
    speedleftKin = sqrt(meanleftKin(:,1).^2 + meanleftKin(:,2).^2);
    leftBumpFiring = zeros(length(leftBump), length(speedleftKin));

    meanleftForce1 = squeeze(mean(leftMoveForce));

    leftMoveFiring = zeros(length(leftMove), length(speedleftKin));
    left = figure();
    suptitle([title1, ' left'])
    subplot(2,2,2);
    plot(linspace(-1*beforeMove, afterMove, length(speedleftKin(:,1))), speedleftKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    ylim([0,40])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off')

    % left Passive Kinematics
    leftBumpKin = zeros(length(leftBump), length(leftBump(1).idx_bumpTime-(beforeBump*100):leftBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(leftBump)
        leftBumpKin(i,:,:) = leftBump(i).vel(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),:);
        leftBumpForce(i,:,:)= leftBump(i).force(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),:);
    end
    meanleftKin = squeeze(mean(leftBumpKin));
    speedleftKin = sqrt(meanleftKin(:,1).^2 + meanleftKin(:,2).^2); 
    meanleftForce = squeeze(mean(leftBumpForce));
    
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 180 & isnan([cds.trials.bumpTime]) ,:);
    window = [[trialTable.startTime] + .01* [leftMove.idx_movement_on]' - .01*[leftMove.idx_startTime]'-beforeMove, [trialTable.startTime]+ .01*[leftMove.idx_movement_on]'- .01*[leftMove.idx_startTime]'+afterMove];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeMove, spikeList(spike)-trialWindow(1)-beforeMove];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(meanleftForce1(:,1))), meanleftForce1(:,1), 'r')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(meanleftForce1(:,1))), meanleftForce1(:,2), 'b')

    
    subplot(2,2,1);
    plot(linspace(-1*beforeBump, afterBump, length(speedleftKin(:,1))), speedleftKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'r--')
    ylim([0,40])
    set(gca,'TickDir','out', 'box', 'off') 
    xlim([-1*beforeBump, afterBump])
    trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 180, :);
    window = [[trialTable.bumpTime]-beforeBump, [trialTable.bumpTime]+afterBump];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeBump, spikeList(spike)-trialWindow(1)-beforeBump];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(speedleftKin(:,1))), meanleftForce(:,1), 'r')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(speedleftKin(:,1))), meanleftForce(:,2), 'b')
    
    % left Move Firing
    subplot(2,2,4)
    xlim([-1*beforeMove, afterMove])
    for  i = 1:length(leftMove)
        leftMoveFiring(i,:) = leftMove(i).RightCuneate_spikes(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meanleftMoveFiring = 100*mean(leftMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meanleftMoveFiring)), conv(meanleftMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    xlim([-1*beforeMove, afterMove])
    %left Bump Firing
    subplot(2,2,3)
    xlim([-1*beforeBump, afterBump])
    set(gca,'TickDir','out')
    leftBumpFiring = zeros(length(leftBump), length(speedleftKin));

    for  i = 1:length(leftBump)
        leftBumpFiring(i,:) = leftBump(i).RightCuneate_spikes(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meanleftFiring = 100*mean(leftBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meanleftFiring)), conv(meanleftFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)

    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
        %saveas(gca, 'leftBumpKinematics.pdf')
        
        
        
        
        
        
            %% right Passive
    rightBump = bumpTrials([bumpTrials.bumpDir] == 0);
    rightMoveKin = zeros(length(rightMove), length(rightMove(1).idx_movement_on-(beforeMove*100):rightMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics
    for  i = 1:length(rightMove)
        rightMoveKin(i,:,:) = rightMove(i).vel(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),:);
        rightMoveForce(i,:,:)= rightMove(i).force(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),:);
    end
    meanrightKin = squeeze(mean(rightMoveKin));
    speedrightKin = sqrt(meanrightKin(:,1).^2 + meanrightKin(:,2).^2);
    meanrightForce1= squeeze(mean(rightMoveForce));

    rightMoveFiring = zeros(length(rightMove), length(speedrightKin));
    right = figure();
    suptitle([title1, ' right'])
    subplot(2,2,2);
    plot(linspace(-1*beforeMove, afterMove, length(speedrightKin(:,1))), speedrightKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    ylim([0,40])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off')

    % right Passive Kinematics
    rightBumpKin = zeros(length(rightBump), length(rightBump(1).idx_bumpTime-(beforeBump*100):rightBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(rightBump)
        rightBumpKin(i,:,:) = rightBump(i).vel(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),:);
        rightBumpForce(i,:,:)= rightBump(i).force(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),:);
    end
    meanrightKin = squeeze(mean(rightBumpKin));
    meanrightForce = squeeze(mean(rightBumpForce));
    speedrightKin = sqrt(meanrightKin(:,1).^2 + meanrightKin(:,2).^2); 
    
        trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.tgtDir] == 0 & isnan([cds.trials.bumpTime]) ,:);
    window = [[trialTable.startTime] + .01* [rightMove.idx_movement_on]' - .01*[rightMove.idx_startTime]'-beforeMove, [trialTable.startTime]+ .01*[rightMove.idx_movement_on]'- .01*[rightMove.idx_startTime]'+afterMove];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeMove, spikeList(spike)-trialWindow(1)-beforeMove];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce1(:,1), 'r')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce1(:,2), 'b')
    
    subplot(2,2,1);
    plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), speedrightKin(:,1), 'k')
    hold on
    plot([0,0],[0,40], 'b--')
    plot([.125,.125],[0,40], 'r--')
    ylim([0,40])
    set(gca,'TickDir','out', 'box', 'off')
    xlim([-1*beforeBump, afterBump])
        trialTable = cds.trials([cds.trials.result] =='R' & [cds.trials.bumpDir] == 0, :);
    window = [[trialTable.bumpTime]-beforeBump, [trialTable.bumpTime]+afterBump];
    cuneateUnits= cds.units(strcmp({cds.units.array}, 'RightCuneate') & [cds.units.ID] >0 & [cds.units.ID]<255);
    unit = cuneateUnits(num1);
    spikeList = [unit.spikes.ts];
    if plotRasters
        for trialNum = 1:height(trialTable)
            trialWindow = [window(trialNum,1), window(trialNum,2)];
            first = find(spikeList>trialWindow(1),1);
            last = find(spikeList >trialWindow(2),1)-1;
            for spike = first:last
                x = [spikeList(spike)-trialWindow(1)-beforeBump, spikeList(spike)-trialWindow(1)-beforeBump];
                y = [trialNum*40/height(trialTable), trialNum*40/height(trialTable)+.5*40/height(trialTable)];
                plot(x,y,'k')
                hold on
            end
        end
    end
    yyaxis right
    plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce(:,1), 'r')
    hold on
    plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce(:,2), 'b')

    
    % right Move Firing
    subplot(2,2,4)
    xlim([-1*beforeBump, afterBump])
    for  i = 1:length(rightMove)
        rightMoveFiring(i,:) = rightMove(i).RightCuneate_spikes(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meanrightMoveFiring = 100*mean(rightMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meanrightMoveFiring)), conv(meanrightMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    xlim([-1*beforeMove, afterMove])
    %right Bump Firing
    subplot(2,2,3)
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out')
    rightBumpFiring = zeros(length(rightBump), length(speedrightKin));

    for  i = 1:length(rightBump)
        rightBumpFiring(i,:) = rightBump(i).RightCuneate_spikes(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meanrightFiring = 100*mean(rightBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meanrightFiring)), conv(meanrightFiring,w ,'same'), 'edgecolor', 'none', 'BarWidth', 1)

    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
        %saveas(gca, 'rightBumpKinematics.pdf')
        
        
    maxFiring = max([conv(meanupMoveFiring, w), conv(meanupFiring, w), conv(meandownMoveFiring,w), conv(meandownFiring,w),...
        conv(meanleftMoveFiring,w), conv(meanleftFiring,w),...
        conv(meanrightMoveFiring,w), conv(meanrightFiring,w)]);
    set(0,'CurrentFigure', up)
    subplot(2,2,3)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(2,2,4)
    ylim([0, max(1,1.1*maxFiring)])
    set(0,'CurrentFigure', down)
    subplot(2,2,3)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(2,2,4)
    ylim([0, max(1,1.1*maxFiring)])
    set(0,'CurrentFigure', left)
    subplot(2,2,3)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(2,2,4)
    ylim([0, max(1,1.1*maxFiring)])
    set(0,'CurrentFigure', right)
    subplot(2,2,3)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(2,2,4)
    ylim([0, max(1,1.1*maxFiring)])
    
    if savePlots
        saveas(up, [title1, 'Up.png'])
        saveas(down, [title1, 'Down.png'])
        saveas(left, [title1, 'Left.png'])
        saveas(right, [title1, 'Right.png'])
    end
        
        
        
        
        
        
        
   shortRightBumpFiring{num1} = rightBumpFiring(:, beforeBump*100:beforeBump*100+15);
   shortLeftBumpFiring{num1} = leftBumpFiring(:, beforeBump*100:beforeBump*100+15);
   shortUpBumpFiring{num1} = upBumpFiring(:, beforeBump*100:beforeBump*100+15);
   shortDownBumpFiring{num1} = downBumpFiring(:, beforeBump*100:beforeBump*100+15);
   
   shortRightMoveFiring{num1} = rightMoveFiring(:, beforeMove*100:beforeMove*100+15);
   shortLeftMoveFiring{num1} = leftMoveFiring(:, beforeMove*100:beforeMove*100+15);
   shortUpMoveFiring{num1} = upMoveFiring(:, beforeMove*100:beforeMove*100+15);
   shortDownMoveFiring{num1} = downMoveFiring(:, beforeMove*100:beforeMove*100+15);
   
   
end
   %% Short time
