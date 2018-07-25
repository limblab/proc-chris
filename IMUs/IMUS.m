close all
v=  VideoWriter('EricVideo.avi');
v.FrameRate = 100;
open(v)

upperLength = 18;
lowerLength = 23;

angle1 = [Roll1, Pitch1, Yaw1];
angle2 = [Roll, Pitch, Yaw];

for i = 1:length(Roll1)
    rotMat1{i} = getRotMat(Roll(i), Pitch(i), Yaw(i));
    rotMat2{i} = getRotMat(Roll1(i), Pitch1(i), Yaw1(i));
end

upperArm = [-1*upperLength;0;0];
lowerArm = [-1*lowerLength;0;0];

fig1= figure;
for i = 1:length(Roll1)
    elbow = rotMat1{i}*upperArm;
    elbowVec(i,:) = elbow;
    hand =elbow + rotMat2{i}*lowerArm;
    handVec(i,:) = hand;
    plot3([0, elbow(1)], [0,elbow(2)], [0, elbow(3)])
    hold on
    plot3([elbow(1), hand(1)],  [elbow(2), hand(2)],[elbow(3), hand(3)])
    hold off
    ylim([-20,20])
    zlim([-20,20])
    xlim([-20,20])
    view(-4,11) % 146 1.2
    title(i)
    drawnow
    pause(.001)
    frame = getframe(fig1);
    writeVideo(v, frame);
end
close(v)

%%

for i = 1:length(Roll1)
    scatter3(handVec(i,1), handVec(i,2), handVec(i,3))
    ylim([-20,20])
    zlim([-20,20])
    xlim([-20,20])
    view(-4,11) % 146 1.2
    title(i)
    pause(.001)
end

figure
scatter3(handVec(250,1), handVec(250,2), handVec(250,3), 'r')
hold on

scatter3(handVec(4550,1), handVec(4550,2), handVec(4550,3), 'b')
zlim([-20,20])
xlim([-20,20])
ylim([-20,20])
view(-4,11) % 146 1.2
%%
figure
for i = 1:length(Roll1)
    scatter3(filtHand1(i), filtHand2(i), filtHand3(i))
    ylim([-20,20])
    zlim([-20,20])
    xlim([-20,20])
    view(2) % 146 1.2
    title(i)
    drawnow
    pause(.001)
end