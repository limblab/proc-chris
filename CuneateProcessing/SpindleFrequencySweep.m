% figure
% plot(ex1.analog(1,1).data.t,ex1.analog(1,1).data.Sync)
% hold on
% yyaxis right
% plot(linspace(0, max(ex1.analog(1,1).data.t), length(ex1.bin.data.RightCuneateCH75ID1)), smooth(ex1.bin.data.RightCuneateCH75ID1))
% xlim([25,30])

pulseStart = 0.664;
pulseWindowStart = pulseStart:2:58.664;
pulseWindowEnd = pulseStart+2:2:60.664;

windows1 = [pulseWindowStart', pulseWindowEnd'];
vibTime = .001:.001:2;
firingTime = 0.05:0.05:2;
vibPulse = zeros(length(windows1(:,1)), length(vibTime));
firingVib = zeros(length(windows1(:,1)), length(firingTime));
for i = 1:30
    vibPulse(i,:) = ex1.analog(1,1).data.Sync(ex1.analog(1,1).data.t>= windows1(i,1) & ex1.analog(1,1).data.t< windows1(i,2));
    firingVib(i,:) = ex1.bin.data.RightCuneateCH75ID1([ex1.bin.data.t] >=windows1(i,1) & [ex1.bin.data.t]<windows1(i,2));
end
figure
plot(vibTime, mean(vibPulse))
hold on
yyaxis right
plot(firingTime, mean(firingVib))

%% 

close all
meanFiring = mean(mean(firingVib([1:4, 28:30], :)));
for j=5:27
    figure
    subtractedRate(j,:) = [smooth(firingVib(j,:))-meanFiring]'./linspace(40, 140, length(firingVib(j,:)));
    plot(linspace(40, 140, length(firingVib(j,:))),[smooth(firingVib(j,:))-meanFiring]'./linspace(40, 140, length(firingVib(j,:))))
    xlim([30,170])
end
meanSubtractedRate = mean(subtractedRate);
figure
plot(linspace(40, 140, length(firingVib(j,:))),meanSubtractedRate)
    