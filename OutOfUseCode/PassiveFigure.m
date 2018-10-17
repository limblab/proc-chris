close all
bumpTrials = cds.trials(~isnan(cds.trials.bumpTime)& cds.trials.result == 'R',:);
spikeTimes = cds.units([cds.units.chan]== 75 & [cds.units.ID] == 1).spikes.ts;
beforeTime = .1;
afterTime = .5;
windows = [[bumpTrials.bumpTime]-beforeTime, [bumpTrials.bumpTime]+afterTime];
force1 = [cds.force.t, cds.force.fx, cds.force.fy];
kin = [cds.kin.t, cds.kin.vx, cds.kin.vy];

for i =1 : length(windows(:,1))
    windowForce = force1(force1(:,1) > windows(i,1) & force1(:,1) < windows(i,2), [3,2]);
    windowKin = kin(kin(:,1) >windows(i,1) & kin(:,1) < windows(i,2),2:3);
    windowTime = force1(force1(:,1) > windows(i,1) & force1(:,1) < windows(i,2), 1);
    windowForce(:,1) = windowForce(:,1) - windowForce(1,1);
    windowForce(:,2) = windowForce(:,2) - windowForce(1,2);
    
    windowKin(:,1) = windowKin(:,1) - windowKin(1,1);
    windowKin(:,2) = windowKin(:,2) - windowKin(2,2);
    dotProd = dot(windowForce', windowKin');
    windowForce = windowForce .*-1;
%     figure
%     subplot(2,1,1)
%     plot(windowForce(:,1))
%     hold on
%     plot(windowForce(:,2))
%     title('Forces')
%     subplot(2,1,2)
%     plot(windowKin(:,1))
%     hold on
%     plot(windowKin(:,2))
%     title('Kinematics')
%     suptitle(['Bump Direction ', num2str(bumpTrials.bumpDir(i))])
    cross = zeros(length(dotProd),1);
    for j = beforeTime*100 + 5:length(dotProd)-1
        if (dotProd(j)>0 & dotProd(j+1)<0)
            cross(j) = 1;
        end
    end

    firstCross= find(cross, 1);
    if ~isnan(firstCross)
        revTime(i) = windows(i,1) + (firstCross/100 +.05);
%         figure
%         plot(windowTime, dotProd)
%         hold on
%         plot([windowTime(firstCross), windowTime(firstCross)], [min(dotProd), max(dotProd)], 'r-')
%         title(['Bump Direction ', num2str(bumpTrials.bumpDir(i))])
%         xlim([windowTime(1), windowTime(end)])

        
        cutForce{i}= windowForce(beforeTime*100:firstCross,:);
        cutKin{i} = windowKin(beforeTime*100:firstCross,:);
    end
    
end
%%
beforeTime = .3;
afterTime = .5;
close all
leftBump = bumpTrials(bumpTrials.bumpDir(revFlag) ==180,:);
rightBump = bumpTrials(bumpTrials.bumpDir(revFlag) == 0,:);
upBump = bumpTrials(bumpTrials.bumpDir(revFlag) ==90,:);
downBump = bumpTrials(bumpTrials.bumpDir(revFlag) == 270,:);
unit = cds.units(245);
revWindow = [[revTime(revTime~=0)-beforeTime]', [revTime(revTime~=0)+afterTime]'];
revFlag = revTime(revTime~=0)>0;
leftRevWindow = revWindow(bumpTrials.bumpDir(revFlag) ==180,:);
rightRevWindow = revWindow(bumpTrials.bumpDir(revFlag) == 0,:);
upRevWindow = revWindow(bumpTrials.bumpDir(revFlag) ==90,:);
downRevWindow = revWindow(bumpTrials.bumpDir(revFlag) ==270,:);


figure
spikeList = [unit.spikes.ts];
timeVector = linspace(-.3, .5,50);
subplot(2,1,1)
binsLeft =zeros(50,1);
for trialNum = 1:height(leftBump)
    trialWindow = leftRevWindow(trialNum,:);
    binWindows = linspace(trialWindow(1), trialWindow(2), 50);
    first = find(spikeList>trialWindow(1),1);
    last = find(spikeList >trialWindow(2),1)-1;
    for spike = first:last
        x = [spikeList(spike)-trialWindow(1)-beforeTime, spikeList(spike)-trialWindow(1)-beforeTime];
        y = [trialNum*40/height(leftBump), trialNum*40/height(leftBump)+.5*40/height(leftBump)];
        plot(x,y,'k')
        binsLeft(find(spikeList(spike)>binWindows,1, 'last')) = binsLeft(find(spikeList(spike)>binWindows,1,'last'))+1;
        hold on
    end
end
subplot(2,1,2)
bar(timeVector, binsLeft)
ylim([0,100])
xlim([-.3, .5])
suptitle('Left Bumps')

figure
binsRight =zeros(50,1);
subplot(2,1,1)
for trialNum = 1:height(rightBump)
    trialWindow = rightRevWindow(trialNum,:);
    binWindows = linspace(trialWindow(1), trialWindow(2), 50);
    first = find(spikeList>trialWindow(1),1);
    last = find(spikeList >trialWindow(2),1)-1;
    for spike = first:last
        x = [spikeList(spike)-trialWindow(1)-beforeTime, spikeList(spike)-trialWindow(1)-beforeTime];
        y = [trialNum*40/height(rightBump), trialNum*40/height(rightBump)+.5*40/height(rightBump)];
        plot(x,y,'k')
        binsRight(find(spikeList(spike)>binWindows,1, 'last')) = binsRight(find(spikeList(spike)>binWindows,1,'last'))+1;
        hold on
    end
end
subplot(2,1,2)
bar(timeVector, binsRight)
ylim([0,100])
xlim([-.3, .5])
suptitle('Right Bumps')

figure
subplot(2,1,1)
binsUp =zeros(50,1);
for trialNum = 1:height(upBump)
    trialWindow = upRevWindow(trialNum,:);
    binWindows = linspace(trialWindow(1), trialWindow(2), 50);
    first = find(spikeList>trialWindow(1),1);
    last = find(spikeList >trialWindow(2),1)-1;
    for spike = first:last
        x = [spikeList(spike)-trialWindow(1)-beforeTime, spikeList(spike)-trialWindow(1)-beforeTime];
        y = [trialNum*40/height(upBump), trialNum*40/height(upBump)+.5*40/height(upBump)];
        plot(x,y,'k')
        binsUp(find(spikeList(spike)>binWindows,1, 'last')) = binsUp(find(spikeList(spike)>binWindows,1,'last'))+1;
        hold on
    end
end
subplot(2,1,2)
bar(timeVector, binsUp)
ylim([0,100])
xlim([-.3, .5])
suptitle('Up Bumps')


binsDown =zeros(length(binWindows),1);
figure
subplot(2,1,1)
for trialNum = 1:height(downBump)
    trialWindow = downRevWindow(trialNum,:);
    binWindows = linspace(trialWindow(1), trialWindow(2), 50);
    first = find(spikeList>trialWindow(1),1);
    last = find(spikeList >trialWindow(2),1)-1;
    for spike = first:last
        x = [spikeList(spike)-trialWindow(1)-beforeTime, spikeList(spike)-trialWindow(1)-beforeTime];
        y = [trialNum*40/height(downBump), trialNum*40/height(downBump)+.5*40/height(downBump)];
        plot(x,y,'k')
        binsDown(find(spikeList(spike)>binWindows,1, 'last')) = binsDown(find(spikeList(spike)>binWindows,1,'last'))+1;
        hold on
    end
end
subplot(2,1,2)
bar(timeVector, binsDown)
xlim([-.3, .5])
ylim([0,100])
suptitle('Down Bumps')
