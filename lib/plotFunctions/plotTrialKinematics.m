function plotTrialKinematics(td, params)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
figure
subplot(3,1,1:2)
for i = 1:length(td)
    scatter(td(i).pos(:,1), td(i).pos(:,2))
    hold on
end
ylim([-50, -20])

xlim([-15,15])

subplot(3,1,3)
for i = 1:length(td)
    plot(rownorm(td(i).vel))
    hold on
end
end

