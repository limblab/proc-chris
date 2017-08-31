%% Looking Specifically at 3 units
%% Finding Windows with movement
% To-do for this file:
% Check that the units are the same (for sure)
% Confirm motion tracking makes sense
% Implement sensor models
%

handleSpeed = sqrt(sum(abs(handleKin).^2,2));
moveFlag = handleSpeed>.1*max(handleSpeed);

close all

bicepsFiring = binned1(moveFlag,2);
bicepsLength = motionTrack(moveFlag,3);
bicepsVel = gradient(bicepsLength);
bicepsVel = bicepsVel*50;
bicepsAcc = gradient(bicepsVel);
rectBicepsVel = bicepsVel;
rectBicepsVel(rectBicepsVel<0) = 0;
bicepsRectAcc = gradient(rectBicepsVel);
ecrFiring = binned1(:,9);
ecrLength = motionTrack(:, 12);
ecrVel = gradient(ecrLength);
rectECRVel = ecrVel;
rectECRVel(rectECRVel<0) = 0;
brachialisFiring = binned1(:,7);
brachialisLength = motionTrack(:, 5);
brachialisVel = gradient(brachialisLength);
rectBrachialisVel = brachialisVel;
rectBrachialisVel(rectBrachialisVel<0) = 0;

%% Plotting
bicepsVelModel = fitlm(bicepsVel, bicepsFiring)
rectBicepsVelModel = fitlm(rectBicepsVel, bicepsFiring)
bicepsLenVelModel = fitlm([rectBicepsVel, bicepsLength], bicepsFiring)
plot(bicepsVelModel)


ecrVelModel = fitlm(ecrVel, ecrFiring)
rectECRVelModel = fitlm(rectECRVel, ecrFiring)
plot(rectECRVelModel)



brachialisVelModel = fitlm(brachialisVel, brachialisFiring)
rectBrachialisVelModel = fitlm(rectBrachialisVel, brachialisFiring)


%% PSTH code
close all
bicepsVelPSTH = zeros(length(10:length(bicepsFiring)), 10);
for  i = 10:length(bicepsFiring)
    bicepsVelPSTH(i,:) = bicepsFiring(i)*rectBicepsVel(i-9:i);
end
stdErrBiceps = std(bicepsVelPSTH);
errorbar(mean(bicepsVelPSTH), stdErrBiceps)

ecrVelPSTH = zeros(length(10:length(ecrFiring)), 10);
for  i = 10:length(ecrFiring)
    ecrVelPSTH(i,:) = ecrFiring(i)*ecrVel(i-9:i);
end
stdErrECR = std(ecrVelPSTH);
errorbar(mean(ecrVelPSTH), stdErrECR)

%%
figure
plot(r)
hold on
yyaxis right
plot(smooth(bicepsFiring))
%%
scatter(rModel2, smooth(bicepsFiring))
fitlm(rModel2, smooth(bicepsFiring))

%%
close all
% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(5);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothBicepsFiring = conv(bicepsFiring, gaussFilter);
smoothBicepsFiring = smoothBicepsFiring(1:length(rModelMilliModel1));
rectModel1 = rModelMilliModel1(rModelMilliModel1>750);
rectSmoothBicepsFiring = smoothBicepsFiring(rModelMilliModel1>750);
% plot it.
scatter(rectModel1./1000,rectSmoothBicepsFiring,'r.')
hold on
[n,c] = hist3([rectModel1./1000, rectSmoothBicepsFiring]);
contour(c{1},c{2},n')
xlabel('Spindle Firing')
ylabel('Neuron Firing')
fitlm(rectModel1, rectSmoothBicepsFiring)


close all
% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(5);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothBrachialisFiring = conv(brachialisFiring, gaussFilter);
smoothBrachialisFiring = smoothBrachialisFiring(1:length(rModelMilliModel1));
rectBrach1 = rBrach1(rBrach1>200);
rectSmoothBrachialisFiring = smoothBrachialisFiring(rBrach1>200);
% plot it.
scatter(rectBrach1./1000,rectSmoothBrachialisFiring,'r.')
hold on
[n,c] = hist3([rectBrach1./1000, rectSmoothBrachialisFiring]);
contour(c{1},c{2},n')
xlabel('Spindle Firing')
ylabel('Neuron Firing')
fitlm(rectBrach1, rectSmoothBrachialisFiring)

figure
scatter(bicepsVel,smoothBicepsFiring)
hold on
[n,c] = hist3([bicepsVel, smoothBicepsFiring]);
contour(c{1},c{2},n')

figure
scatter(bicepsVel,rModel4)
hold on
[n,c] = hist3([bicepsVel, rModel4]);
contour(c{1},c{2},n')


figure
spindleHigh = rModel2(rModel2>50.5);
neuronHigh = smoothBicepsFiring(rModel2>50.5);
lm2 = fitlm(spindleHigh, neuronHigh)
scatter(spindleHigh, neuronHigh)
hold on
plot(lm2)

figure
bicepsVelHigh = bicepsVel(rModel2>50.5);
lm1 = fitlm(bicepsVelHigh, neuronHigh);
scatter(bicepsVelHigh, neuronHigh)
hold on
plot(lm1)
