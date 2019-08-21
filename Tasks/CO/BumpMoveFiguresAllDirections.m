% clear all
close all
clear all
% clearvars -except cds
% load('Lando3202017COactpasCDS.mat')
plotRasters = 1;
savePlots = 1;
savePDF = true;
% params.event_list = {'bumpTime'; 'bumpDir'};
% params.extra_time = [.4,.6];
% params.include_ts = true;
% params.include_start = true;
% params.include_naming = true;
% td = parseFileByTrial(cds, params);
% td = td(~isnan([td.target_direction]));
% params.start_idx =  'idx_goCueTime';
% params.end_idx = 'idx_endTime';
% td = getMoveOnsetAndPeak(td, params);

date = '20190730';
monkey = 'Snap';
unitNames = 'cuneate';

% mappingLog = getSensoryMappings(monkey);

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
params.start_idx        =  'idx_goCueTime';
params.end_idx          =  'idx_endTime';
td =getTD(monkey, date, 'CO',2);
td = removeBadNeurons(td);
td = getSpeed(td);
td = getMoveOnsetAndPeak(td, params);
td = tdToBinSize(td, 10);
td(isnan([td.idx_movement_on])) =[];
unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'rawAlignedPlots',filesep];
mkdir([savePath, 'Cuneate']);
mkdir([savePath, 'Gracile']);


elec2MapName = td(1).cuneate_naming;
for i = 1:length(td(1).(unitSpikes)(1,:))
    gracileFlag(i) = getGracile('Butter', elec2MapName(elec2MapName(:,1) == td(1).cuneate_unit_guide(i,1),2));
end

w = gausswin(5);
w = w/sum(w);


numCount = 1:length(td(1).(unitSpikes)(1,:));
%% Data Preparation and sorting out trials

bumpTrials = td(~isnan([td.bumpDir])); 
upMove = td([td.target_direction] == pi/2 );
leftMove = td([td.target_direction] ==pi);
downMove = td([td.target_direction] ==3*pi/2);
rightMove = td([td.target_direction]==0);


%% 
close all
for num1 = numCount
    close all
    title1 = [monkey, ' ', unitNames, ' Electrode' num2str(td(1).(unitGuide)(num1,1)), ' Unit ', num2str(td(1).(unitGuide)(num1,2))];
    paramsMove.neuron = num1;
    paramsMove.yMax = 60;
    paramsMove.align= 'movement_on';
    paramsMove.xBound = [-.3, .3];
    paramsMove.array =unitNames;
    
    paramsBump.neuron = num1;
    paramsBump.yMax = 60;
    paramsBump.align= 'bumpTime';
    paramsBump.xBound = [-.3, .3];
    paramsBump.array = unitNames;
    %% Up Active
    upBump = bumpTrials([bumpTrials.bumpDir] == 90);
    upMoveKin = zeros(length(upMove), length(upMove(1).idx_movement_on-(beforeMove*100):upMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics
    for  i = 1:length(upMove)
        upMoveKin(i,:,:) = upMove(i).vel(upMove(i).idx_movement_on-(beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),:);
%         upMoveForce(i,:,:) = upMove(i).force(upMove(i).idx_movement_on- (beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),:);
%         upMoveEMG(i,:,:) = upMove(i).emg(upMove(i).idx_movement_on- (beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),:);
    end
    meanUpKin = squeeze(mean(upMoveKin));
    speedUpKin = sqrt(meanUpKin(:,1).^2 + meanUpKin(:,2).^2);
%     meanupForce = squeeze(mean(upMoveForce));
%     meanUpEMG = squeeze(mean(upMoveEMG));
    
    upMoveFiring = zeros(length(upMove), length(speedUpKin));
    
    bump = figure2();
    move = figure2();
    
    suptitle([title1, ' Active'])
    if gracileFlag(num1)
        suptitle([title1, ' Active GRACILE'])
    end
    subplot(4,3,2);
    plot(linspace(-1*beforeMove, afterMove, length(speedUpKin(:,1))), speedUpKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    ylim([0,paramsBump.yMax])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off') 
    set(gca,'xtick',[],'ytick',[])


    if plotRasters
        unitRaster(upMove, paramsMove);
    end
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,1), 'b')
%     hold on
%     plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,2), 'r')
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(meanUpEMG(:,19))), meanUpEMG(:,19), 'b');
%     
    % Up Passive Kinematics
    upBumpKin = zeros(length(upBump), length(upBump(1).idx_bumpTime-(beforeBump*100):upBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(upBump)
        upBumpKin(i,:,:) = upBump(i).vel(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),:);
%         upBumpForce(i,:,:)=upBump(i).force(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),:);
%         upBumpEMG(i,:,:)=upBump(i).emg(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),:);
    end
    meanUpKin = squeeze(mean(upBumpKin));
    speedUpKin = sqrt(meanUpKin(:,1).^2 + meanUpKin(:,2).^2); 
% %     meanupForce = squeeze(mean(upBumpForce));
%     meanUpEMG = squeeze(mean(upBumpEMG));

    set(0,'CurrentFigure', bump)
    suptitle([title1, ' Passive'])
    if gracileFlag(num1)
        suptitle([title1, ' Passive GRACILE'])
    end

    subplot(4,3,2);
    plot(linspace(-1*beforeBump, afterBump, length(speedUpKin(:,1))), speedUpKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    plot([.125,.125],[0,paramsBump.yMax], 'r--')
    ylim([0,paramsBump.yMax])
    set(gca,'TickDir','out', 'box', 'off') 
    set(gca,'xtick',[],'ytick',[])
    xlim([-1*beforeBump, afterBump])
    
   
    if plotRasters
        unitRaster(upBump, paramsBump);
    end
    yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(meanUpEMG(:,1))), meanUpEMG(:,20), 'r')
%     plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,2), 'r')
    hold on
%     plot(linspace(-1*beforeBump, afterBump, length(meanupForce(:,1))), meanupForce(:,1), 'b')

    
    
    % Up Move Firing
    set(0,'CurrentFigure', move)

    subplot(4,3,5)
    xlim([-1*beforeMove, afterMove])
    for  i = 1:length(upMove)
        upMoveFiring(i,:) = upMove(i).(unitSpikes)(upMove(i).idx_movement_on-(beforeMove*100):upMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meanupMoveFiring = 100*mean(upMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meanupMoveFiring)), conv(meanupMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
    xlim([-1*beforeMove, afterMove])
    %Up Bump Firing
    
    set(0,'CurrentFigure', bump)
    subplot(4,3,5)
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out')
    upBumpFiring = zeros(length(upBump), length(speedUpKin));
    for  i = 1:length(upBump)
        upBumpFiring(i,:) = upBump(i).(unitSpikes)(upBump(i).idx_bumpTime-(beforeBump*100):upBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meanupFiring = 100*mean(upBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meanupFiring)), conv(meanupFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)

    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
    

    %saveas(gca, 'UpBumpKinematics.png')
      
    %% down active
    downBump = bumpTrials([bumpTrials.bumpDir] == 270);
    downMoveKin = zeros(length(downMove), length(downMove(1).idx_movement_on-(beforeMove*100):downMove(1).idx_movement_on+(afterMove*100)), 2);
    downMoveForce = zeros(length(downMove), length(downMove(1).idx_movement_on-(beforeMove*100):downMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics
    for  i = 1:length(downMove)
        downMoveKin(i,:,:) = downMove(i).vel(downMove(i).idx_movement_on-(beforeMove*100):downMove(i).idx_movement_on+(afterMove*100),:);
%         downMoveForce(i,:,:)= downMove(i).force(downMove(i).idx_movement_on -(beforeMove*100):downMove(i).idx_movement_on + (afterMove*100),:);
    
    end
    meandownKin = squeeze(mean(downMoveKin));
    speeddownKin = sqrt(meandownKin(:,1).^2 + meandownKin(:,2).^2);
%     meandownForce1 = squeeze(mean(downMoveForce));
    
    downMoveFiring = zeros(length(downMove), length(speeddownKin));
    set(0,'CurrentFigure', move)
    subplot(4,3,8)

    plot(linspace(-1*beforeMove, afterMove, length(speeddownKin(:,1))), speeddownKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    ylim([0,paramsBump.yMax])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off')
    set(gca,'xtick',[],'ytick',[])

    % down Passive Kinematics
    downBumpKin = zeros(length(downBump), length(downBump(1).idx_bumpTime-(beforeBump*100):downBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(downBump)
        downBumpKin(i,:,:) = downBump(i).vel(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),:);
%         downBumpForce(i,:,:)= downBump(i).force(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),:);
       
    end
    meandownKin = squeeze(mean(downBumpKin));
    speeddownKin = sqrt(meandownKin(:,1).^2 + meandownKin(:,2).^2);
%     meandownForce = squeeze(mean(downBumpForce));
    
   
    if plotRasters
      unitRaster(downMove, paramsMove);
    end
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(meandownForce1(:,1))), meandownForce1(:,2), 'b')
%     hold on
%     plot(linspace(-1*beforeBump, afterBump, length(meandownForce1(:,1))), meandownForce1(:,1), 'r')

    set(0,'CurrentFigure', bump)

    subplot(4,3,8);
    plot(linspace(-1*beforeBump, afterBump, length(speeddownKin(:,1))), speeddownKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    plot([.125,.125],[0,paramsBump.yMax], 'r--')
    ylim([0,paramsBump.yMax])
    set(gca,'TickDir','out', 'box', 'off') 
    set(gca,'xtick',[])
    ylabel('Trial #')
    xlim([-1*beforeBump, afterBump])

    if plotRasters
        unitRaster(downBump, paramsBump);
    end
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(meandownForce(:,1))), meandownForce(:,1), 'r')
%     hold on
%     plot(linspace(-1*beforeBump, afterBump, length(meandownForce(:,1))), meandownForce(:,2), 'b')

    
    % down Move Firing
    set(0,'CurrentFigure', move)
    
    subplot(4,3,11)
    xlim([-1*beforeMove, afterMove])
    for  i = 1:length(downMove)
        downMoveFiring(i,:) = downMove(i).(unitSpikes)(downMove(i).idx_movement_on-(beforeMove*100):downMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meandownMoveFiring = 100*mean(downMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meandownMoveFiring)), conv(meandownMoveFiring,w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    xlabel('Time (seconds')
    ylabel('Firing Rate (Hz)')
    set(gca, 'TickDir', 'out', 'box', 'off')
    xlim([-1*beforeMove, afterMove])
    
    %down Bump 
    set(0,'CurrentFigure', bump)
    subplot(4,3,11)
    xlim([-1*beforeBump, afterBump])
    set(gca,'TickDir','out')
    downBumpFiring = zeros(length(downBump), length(speeddownKin));
    for  i = 1:length(downBump)
        downBumpFiring(i,:) = downBump(i).(unitSpikes)(downBump(i).idx_bumpTime-(beforeBump*100):downBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meandownFiring = 100*mean(downBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meandownFiring)), conv(meandownFiring,w ,'same'), 'edgecolor', 'none', 'BarWidth', 1)
    xlabel('Time (seconds')
    ylabel('Firing Rate (Hz)')
    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
        %saveas(gca, 'downBumpKinematics.png')
        
      
      %% left Passive
    leftBump = bumpTrials([bumpTrials.bumpDir] == 180);
    leftMoveKin = zeros(length(leftMove), length(leftMove(1).idx_movement_on-(beforeMove*100):leftMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics

    for  i = 1:length(leftMove)
        leftMoveKin(i,:,:) = leftMove(i).vel(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),:);
%         leftMoveForce(i,:,:)= leftMove(i).force(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),:);
    end
    meanleftKin = squeeze(mean(leftMoveKin));
    speedleftKin = sqrt(meanleftKin(:,1).^2 + meanleftKin(:,2).^2);
    leftBumpFiring = zeros(length(leftBump), length(speedleftKin));

%     meanleftForce1 = squeeze(mean(leftMoveForce));

    leftMoveFiring = zeros(length(leftMove), length(speedleftKin));
    set(0,'CurrentFigure', move)
    subplot(4,3,4);
    plot(linspace(-1*beforeMove, afterMove, length(speedleftKin(:,1))), speedleftKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    ylim([0,paramsBump.yMax])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off')
    set(gca,'xtick',[],'ytick',[])

    % left Passive Kinematics
    leftBumpKin = zeros(length(leftBump), length(leftBump(1).idx_bumpTime-(beforeBump*100):leftBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(leftBump)
        leftBumpKin(i,:,:) = leftBump(i).vel(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),:);
%         leftBumpForce(i,:,:)= leftBump(i).force(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),:);
    end
    meanleftKin = squeeze(mean(leftBumpKin));
    speedleftKin = sqrt(meanleftKin(:,1).^2 + meanleftKin(:,2).^2); 
%     meanleftForce = squeeze(mean(leftBumpForce));
    
  
    if plotRasters
        unitRaster(leftMove, paramsMove);
    end
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(meanleftForce1(:,1))), meanleftForce1(:,1), 'r')
%     hold on
%     plot(linspace(-1*beforeBump, afterBump, length(meanleftForce1(:,1))), meanleftForce1(:,2), 'b')

    set(0,'CurrentFigure', bump)
    subplot(4,3,4);
    plot(linspace(-1*beforeBump, afterBump, length(speedleftKin(:,1))), speedleftKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    plot([.125,.125],[0,paramsBump.yMax], 'r--')
    ylim([0,paramsBump.yMax])
    set(gca,'TickDir','out', 'box', 'off') 
    set(gca,'xtick',[],'ytick',[])
    xlim([-1*beforeBump, afterBump])

    if plotRasters
       unitRaster(leftBump, paramsBump);
    end
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(speedleftKin(:,1))), meanleftForce(:,1), 'r')
%     hold on
%     plot(linspace(-1*beforeBump, afterBump, length(speedleftKin(:,1))), meanleftForce(:,2), 'b')
    
    % left Move Firing
    set(0,'CurrentFigure', move)

    subplot(4,3,7)
    xlim([-1*beforeMove, afterMove])
    for  i = 1:length(leftMove)
        leftMoveFiring(i,:) = leftMove(i).(unitSpikes)(leftMove(i).idx_movement_on-(beforeMove*100):leftMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meanleftMoveFiring = 100*mean(leftMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meanleftMoveFiring)), conv(meanleftMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
    xlim([-1*beforeMove, afterMove])
    %left Bump Firing
    set(0,'CurrentFigure', bump)

    subplot(4,3,7)
    xlim([-1*beforeBump, afterBump])
    set(gca,'TickDir','out')
    set(gca,'xtick',[],'ytick',[])
    leftBumpFiring = zeros(length(leftBump), length(speedleftKin));

    for  i = 1:length(leftBump)
        leftBumpFiring(i,:) = leftBump(i).(unitSpikes)(leftBump(i).idx_bumpTime-(beforeBump*100):leftBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meanleftFiring = 100*mean(leftBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meanleftFiring)), conv(meanleftFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)

    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
        %saveas(gca, 'leftBumpKinematics.png')
        
        
        
        
        
        
            %% right Passive
    rightBump = bumpTrials([bumpTrials.bumpDir] == 0);
    rightMoveKin = zeros(length(rightMove), length(rightMove(1).idx_movement_on-(beforeMove*100):rightMove(1).idx_movement_on+(afterMove*100)), 2);
    % Generate Movement Kinematics
    for  i = 1:length(rightMove)
        rightMoveKin(i,:,:) = rightMove(i).vel(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),:);
%         rightMoveForce(i,:,:)= rightMove(i).force(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),:);
    end
    meanrightKin = squeeze(mean(rightMoveKin));
    speedrightKin = sqrt(meanrightKin(:,1).^2 + meanrightKin(:,2).^2);
%     meanrightForce1= squeeze(mean(rightMoveForce));

    rightMoveFiring = zeros(length(rightMove), length(speedrightKin));
    set(0,'CurrentFigure', move)

    subplot(4,3,6);
    plot(linspace(-1*beforeMove, afterMove, length(speedrightKin(:,1))), speedrightKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    ylim([0,paramsBump.yMax])
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out','box', 'off')
    set(gca,'xtick',[],'ytick',[])

    % right Passive Kinematics
    rightBumpKin = zeros(length(rightBump), length(rightBump(1).idx_bumpTime-(beforeBump*100):rightBump(1).idx_bumpTime+(afterBump*100)), 2);
    for  i = 1:length(rightBump)
        rightBumpKin(i,:,:) = rightBump(i).vel(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),:);
%         rightBumpForce(i,:,:)= rightBump(i).force(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),:);
    end
    meanrightKin = squeeze(mean(rightBumpKin));
%     meanrightForce = squeeze(mean(rightBumpForce));
    speedrightKin = sqrt(meanrightKin(:,1).^2 + meanrightKin(:,2).^2); 

    if plotRasters
       unitRaster(rightMove, paramsMove);
    end
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce1(:,1), 'r')
%     hold on
%     plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce1(:,2), 'b')
    set(0,'CurrentFigure', bump)

    subplot(4,3,6);
    plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), speedrightKin(:,1), 'k')
    hold on
    plot([0,0],[0,paramsBump.yMax], 'b--')
    plot([.125,.125],[0,paramsBump.yMax], 'r--')
    ylim([0,paramsBump.yMax])
    set(gca,'TickDir','out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
    xlim([-1*beforeBump, afterBump])

    if plotRasters
       unitRaster(rightBump, paramsBump);
    end
%     yyaxis right
%     plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce(:,1), 'r')
%     hold on
%     plot(linspace(-1*beforeBump, afterBump, length(speedrightKin(:,1))), meanrightForce(:,2), 'b')

    
    % right Move Firing
    set(0,'CurrentFigure', move)

    subplot(4,3,9)
    xlim([-1*beforeBump, afterBump])
    for  i = 1:length(rightMove)
        rightMoveFiring(i,:) = rightMove(i).(unitSpikes)(rightMove(i).idx_movement_on-(beforeMove*100):rightMove(i).idx_movement_on+(afterMove*100),num1);
    end
    meanrightMoveFiring = 100*mean(rightMoveFiring);
    bar(linspace(-1*beforeMove, afterMove, length(meanrightMoveFiring)), conv(meanrightMoveFiring, w, 'same'), 'edgecolor', 'none', 'BarWidth', 1)
    set(gca,'TickDir','out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
    xlim([-1*beforeMove, afterMove])
    %right Bump Firing
    set(0,'CurrentFigure', bump)

    subplot(4,3,9)
    xlim([-1*beforeMove, afterMove])
    set(gca,'TickDir','out')
    set(gca,'xtick',[],'ytick',[])
    rightBumpFiring = zeros(length(rightBump), length(speedrightKin));

    for  i = 1:length(rightBump)
        rightBumpFiring(i,:) = rightBump(i).(unitSpikes)(rightBump(i).idx_bumpTime-(beforeBump*100):rightBump(i).idx_bumpTime+(afterBump*100),num1);
    end
    meanrightFiring = 100*mean(rightBumpFiring);
    bar(linspace(-1*beforeBump, afterBump, length(meanrightFiring)), conv(meanrightFiring,w ,'same'), 'edgecolor', 'none', 'BarWidth', 1)

    xlim([-1*beforeBump, afterBump])

    set(gca, 'TickDir', 'out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
        %saveas(gca, 'rightBumpKinematics.png')
        
        
    maxFiring = max([conv(meanupMoveFiring, w), conv(meanupFiring, w), conv(meandownMoveFiring,w), conv(meandownFiring,w),...
        conv(meanleftMoveFiring,w), conv(meanleftFiring,w),...
        conv(meanrightMoveFiring,w), conv(meanrightFiring,w)]);

    set(0,'CurrentFigure', bump)
    set(gca,'TickDir','out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
    subplot(4,3,5)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(4,3,7)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(4,3,9)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(4,3,11)
    ylim([0, max(1,1.1*maxFiring)])
    
    set(0,'CurrentFigure', move)
    set(gca,'TickDir','out', 'box', 'off')
    set(gca,'xtick',[],'ytick',[])
    subplot(4,3,5)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(4,3,7)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(4,3,9)
    ylim([0, max(1,1.1*maxFiring)])
    subplot(4,3,11)
    ylim([0, max(1,1.1*maxFiring)])
    
    disp(num1)
    if savePlots
            if gracileFlag(num1)
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, 'Gracile',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), 'GRACILE.pdf'],bump)
                set(move, 'Renderer', 'Painters');
                save2pdf([savePath, 'Gracile', filesep,strrep(title1, ' ', '_'), 'Move', num2str(date), 'GRACILE.pdf'],move)
                saveas(bump,[savePath,'Gracile',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), 'GRACILE.png'])
                saveas(move,[savePath,'Gracile', filesep, strrep(title1, ' ', '_'), '_Move_', num2str(date), 'GRACILE.png'])
            else
                set(bump, 'Renderer', 'Painters');
                save2pdf([savePath, 'Cuneate',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.pdf'],bump)
                set(move, 'Renderer', 'Painters');
                save2pdf([savePath,'Cuneate', filesep,strrep(title1, ' ', '_'), '_Move_', num2str(date), '.pdf'],move)
                saveas(bump,[savePath, 'Cuneate',filesep, strrep(title1, ' ', '_'), '_Bump_', num2str(date), '.png'])
                saveas(move,[savePath, 'Cuneate',filesep, strrep(title1, ' ', '_'), '_Move_', num2str(date), '.png'])
            end

    end


        
    end

   


%% Short time

