%% Looking Specifically at 3 units
%% Finding Windows with movement

handleSpeed = sqrt(sum(abs(handleKin).^2,2));
moveFlag = handleSpeed>.9*max(handleSpeed);

close all
bicepsFiring = binned1(moveFlag,2);
bicepsLength = motionTrack(moveFlag,3);
bicepsVel = gradient(bicepsLength);
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
