upperArmLength = 6.5;
lowerArmLength = 6;
handLength=4;
plotInitial = 1;
close all

elbowVecStart = [1;0;0];
wristVecStart = [1; 0;0];
handVecStart = [1; 0;0];

elbowVec = [cosd(upperArmMarker.Yaw).*cosd(upperArmMarker.Pitch), sind(upperArmMarker.Yaw).*cosd(upperArmMarker.Pitch), sind(upperArmMarker.Pitch)];
wristVec = [cosd(foreArmMarker.Yaw).*cosd(foreArmMarker.Pitch), sind(foreArmMarker.Yaw).*cosd(foreArmMarker.Pitch), sind(foreArmMarker.Pitch)];
handVec = [cosd(handMarker.Yaw).*cosd(handMarker.Pitch), sind(handMarker.Yaw).*cosd(handMarker.Pitch), sind(handMarker.Pitch)];

shoulderRotMat = getMatFromYPR(upperArmMarker.Yaw, upperArmMarker.Pitch, upperArmMarker.Roll);
elbowRotMat = getMatFromYPR(foreArmMarker.Yaw, foreArmMarker.Pitch, foreArmMarker.Roll);
wristRotMat = getMatFromYPR(handMarker.Yaw, handMarker.Pitch, handMarker.Roll);

for i = 1:length(elbow(:,1))
    elbowVec(i,:) = squeeze(shoulderRotMat(i,:,:))*elbowVecStart;
    wristVec(i,:) = squeeze(elbowRotMat(i,:,:))*wristVecStart;
    handVec(i,:) = squeeze(wristRotMat(i,:,:))*handVecStart;
end
% elbowAngle = atan2d(rownorm(cross(elbowVec, wristVec)), dot(elbowVec', wristVec'));
% wristAngle = atan2d(rownorm(cross(wristVec, handVec)), dot(wristVec', handVec'));
shoulder = zeros(height(backMarker), 3);
%%
elbow1 = upperArmLength*elbowVec;
wrist1 = elbow1+lowerArmLength*wristVec;
hand1 = wrist1+ handLength*handVec;

% elbow = elbow1(:,[3,1,2]);
% wrist = wrist1(:,[3,1,2]);
% hand = hand1(:,[3,1,2]);
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
    title(i)
    view(76,44)
    pause(.000001);
    hold off
    drawnow;
    
end