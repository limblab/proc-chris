close all
figure
hold on
predicted = predict(emgKinAllData{1,1}, table2array(binned(:,[emgCols, muscleCols])));
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH75ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, binned.RightCuneateCH75ID1)
yyaxis right
plot(binned.t, predicted)
xlim([10,20])
close all
figure
hold on
predicted = predict(emgKinPassiveData{1,1}, table2array(binned(:,[emgCols, muscleCols])));
for i = 1:length(window1(:,1))
    rectangle('Position', [window1(i,1), 0, window1(i,2)-window1(i,1), max(binned.RightCuneateCH75ID1)], 'FaceColor', [.8,.8,.8], 'LineWidth', .00000001)
end
plot(binned.t, binned.RightCuneateCH75ID1)
yyaxis right
plot(binned.t, predicted)
xlim([10,20])


