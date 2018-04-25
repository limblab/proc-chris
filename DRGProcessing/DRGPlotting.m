close all

if ~exist('backMarker')
upperArmLength = 6.5;
lowerArmLength = 6;
handLength=2.5;
plotInitial = 9400;
elbowFlexion = 1100:9150;
wristFlexion = 9400:15800;
shoulderFlexion= 15960:21500;
freeMovement = 22000:27691;
close all

[sensor1.Roll, sensor1.Pitch, sensor1.Yaw] = importfileIMU([getIMUdatapath(), 'DRGImplant_First_Trial-000_00B429FF.txt'], inf);
[sensor2.Roll, sensor2.Pitch, sensor2.Yaw] = importfileIMU([getIMUdatapath(), 'DRGImplant_First_Trial-000_00B429F1.txt'], inf);
[sensor3.Roll, sensor3.Pitch, sensor3.Yaw] = importfileIMU([getIMUdatapath(), 'DRGImplant_First_Trial-000_00B42A08.txt'], inf);
[sensor4.Roll, sensor4.Pitch, sensor4.Yaw] = importfileIMU([getIMUdatapath(), 'DRGImplant_First_Trial-000_00B42A04.txt'], inf);

tbl1 = struct2table(sensor1);
tbl2 = struct2table(sensor2);
tbl3 = struct2table(sensor3);
tbl4 = struct2table(sensor4);

upperArmMarker= sensor1;
foreArmMarker = sensor3;
handMarker=  sensor2;
backMarker = sensor4;
end
%%

close all
foreArmArr = table2array(tbl3);
upArmArr = table2array(tbl1);
handArr = table2array(tbl2);

[matElb, scoresElb] = pca(foreArmArr(elbowFlexion,:));
[matSho, scoresSho] = pca(upArmArr(shoulderFlexion,:));
[matWrist, scoresWrist] = pca(handArr(wristFlexion,:));

figure
plot(scoresElb)
title('PCA of forearm kin during elbow flexion')

extendedArmTime = input('Look at the plot and enter the index when the elbow is fully extended (a trough)');
extendedArmTime = extendedArmTime + elbowFlexion(1);
upArmCal = upArmArr(extendedArmTime,:);
lowArmCal = foreArmArr(extendedArmTime,:);
handCal = handArr(extendedArmTime,:);

elbowVecStart = [1;0;0];
wristVecStart = [1; 0;0];
handVecStart = [1; 0;0];
%%
elbowVec = [cosd(upperArmMarker.Yaw-upArmCal(3)).*cosd(upperArmMarker.Pitch-upArmCal(2)), sind(upperArmMarker.Yaw-upArmCal(3)).*cosd(upperArmMarker.Pitch-upArmCal(2)), sind(upperArmMarker.Pitch-upArmCal(2))];
wristVec = [cosd(foreArmMarker.Yaw-lowArmCal(3)).*cosd(foreArmMarker.Pitch-lowArmCal(2)), sind(foreArmMarker.Yaw-lowArmCal(3)).*cosd(foreArmMarker.Pitch-lowArmCal(2)), sind(foreArmMarker.Pitch- lowArmCal(2))];
handVec = [cosd(handMarker.Yaw-handCal(3)).*cosd(handMarker.Pitch-handCal(2)), sind(handMarker.Yaw-handCal(3)).*cosd(handMarker.Pitch-handCal(2)), sind(handMarker.Pitch-handCal(2))];

shoulder = zeros(length(backMarker.Yaw), 3);
%%
elbow1 = upperArmLength*elbowVec;
wrist1 = elbow1+lowerArmLength*wristVec;
hand1 = wrist1+ handLength*handVec;

elbow = elbow1;
wrist = wrist1;
hand = hand1;
%%
f1= figure;
ax1 = plot3([shoulder(plotInitial,1), elbow(plotInitial,1)], [shoulder(plotInitial,2), elbow(plotInitial,2)],[shoulder(plotInitial,3), elbow(10000,3)]);
[az, el] =  view;
hold on
ax2 = plot3([elbow(plotInitial,1), wrist(plotInitial,1)], [elbow(plotInitial,2), wrist(plotInitial,2)], [elbow(plotInitial,3), wrist(plotInitial,3)],'r');
ax3 = plot3([wrist(plotInitial,1), hand(plotInitial,1)], [wrist(plotInitial,2), hand(plotInitial,2)], [wrist(plotInitial,3), hand(plotInitial,3)], 'g');
xlim([-5,20])
ylim([-15,10])
zlim([-15, 10])
ax = gca;
ax.NextPlot= 'replaceChildren';
for i =plotInitial:length(elbow(:,1))
    ax = plot3([shoulder(i,1), elbow(i,1)], [shoulder(i,2), elbow(i,2)],[shoulder(i,3), elbow(i,3)]);
    hold on
    ax2 = plot3([elbow(i,1), wrist(i,1)], [elbow(i,2), wrist(i,2)], [elbow(i,3), wrist(i,3)],'r');
    ax3 = plot3([wrist(i,1), hand(i,1)], [wrist(i,2), hand(i,2)], [wrist(i,3), hand(i,3)], 'g');
    xlim([-5,20])
    ylim([-15,10])
    zlim([-15, 10])
    if i> elbowFlexion(1) & i< elbowFlexion(end)
        title(['Elbow Flexion: ', num2str(i)])
    elseif i >wristFlexion(1) & i< wristFlexion(end)
        title(['Wrist Flexion: ', num2str(i)])
    elseif i >shoulderFlexion(1) & i < shoulderFlexion(end)
        title(['Shoulder Flexion: ', num2str(i)])
    elseif i > freeMovement(1) & i < freeMovement(end)
        title(['Free Movement: ', num2str(i)])
    end
    view(76,44)

    hold off
    drawnow;
    pause(.000001);
    
end
save('DRGFirstTrialKinematics', 'shoulder', 'elbow', 'hand')

%%
close all
clear all
tStartNeural = 11.075;
tStartIMU = 440;
tStart = 5;
tEnd = 50;
elbowFlexion = 1100:9150- tStartIMU;
wristFlexion = 9400:15800 -tStartIMU;
shoulderFlexion= 15960:21500- tStartIMU;
freeMovement = 22000:27691- tStartIMU;
cds = commonDataStructure();
cds.file2cds('C:\Users\csv057\Documents\MATLAB\DRGAcute\Neural Data\NHP02_0081-sorted', 'taskUnknown', 'arrayDRG', 'monkeyMcKinley','ranByChris',1);
% plotAcuteDRG(cds, elbow, wrist, hand, tStartNeural, tStartIMU, .01*elbowFlexion(1), .01*elbowFlexion(end));
% plotAcuteDRG(cds, elbow, wrist, hand, tStartNeural, tStartIMU, .01*wristFlexion(1), .01*wristFlexion(end));
% plotAcuteDRG(cds, elbow, wrist, hand, tStartNeural, tStartIMU, .01*shoulderFlexion(1), .01*shoulderFlexion(end));
% plotAcuteDRG(cds, elbow, wrist, hand, tStartNeural, tStartIMU, .01*freeMovement(1), .01*freeMovement(end));
%% 
params.all_points = true;
td = parseFileByTrial(cds, params);
td = binTD(td, 5);

