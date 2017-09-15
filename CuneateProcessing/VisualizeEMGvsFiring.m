close all
figure
ax1= subplot(2,1,1);
hold on
title('EMG vs Cuneate Firing')
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH75ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, smooth(binned.RightCuneateCH75ID1))
yyaxis right
plot(binned.t, smooth(smooth(binned.EMG_PecInf)))
ax2 = subplot(2,1,2);
hold on
title('Muscle Vel vs. Cuneate Firing')
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH75ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, smooth(binned.RightCuneateCH75ID1))
yyaxis right
plot(binned.t, binned.pectoralis_sup_muscVel)
suptitle('Pectoralis')
linkaxes([ax1, ax2], 'x');
xlim([10,20])
%%
close all
figure
ax1= subplot(2,1,1);
hold on
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH88ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, smooth(binned.RightCuneateCH88ID1))
yyaxis right
plot(binned.t, smooth(smooth(binned.EMG_FCU)))
ax2 = subplot(2,1,2);
hold on
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH88ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, smooth(binned.RightCuneateCH88ID1))
yyaxis right
plot(binned.t, smooth(binned.flex_carpi_ulnaris_muscVel))

linkaxes([ax1, ax2], 'x');
xlim([10,20])

%%
close all
figure
ax1= subplot(2,1,1);
hold on
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH80ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, smooth(binned.RightCuneateCH80ID1))
yyaxis right
plot(binned.t, binned.EMG_ECRb)
ax2 = subplot(2,1,2);
hold on
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH80ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, smooth(binned.RightCuneateCH80ID1))
yyaxis right
plot(binned.t, smooth(binned.ext_carpi_rad_longus_muscVel))

linkaxes([ax1, ax2], 'x');

xlim([10,20])
figure
%%
close all
figure
hold on
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH88ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, smooth(binned.RightCuneateCH79ID1))
ylabel('Firing')
yyaxis right
% plot(binned.t, smooth(binned.EMG_TriLat), 'r')

plot(binned.t, binned.tricep_lat_muscVel)
ylabel('Triceps velocity')

interactionFit = fitlm(binned, 'RightCuneateCH79ID1~tricep_lat_muscVel + tricep_lat_len+ EMG_TriLat + tricep_lat_muscVel:tricep_lat_len + EMG_TriLat:tricep_lat_len + EMG_TriLat:tricep_lat_muscVel')
xlim([10,20])