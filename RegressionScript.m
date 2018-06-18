close all
tdBin = binTD(td,5);
tdBin = trimTD(tdBin, {'idx_movement_on', 3}, {'idx_movement_on', 13});
tdBin = getPCA(tdBin);

pos = cat(1, tdBin.pos);
vel = cat(1, tdBin.vel);
cuneate_spikes = cat(1, tdBin.cuneate_pca);
cuneate_spikes = cuneate_spikes(:,1:5);
figure
xpos = fitlm(cuneate_spikes, pos(:,1))
plot(xpos)
figure
xvel = fitlm(cuneate_spikes, vel(:,1))
plot(xvel)
figure
ypos = fitlm(cuneate_spikes, pos(:,2))
plot(ypos)
figure
yvel = fitlm(cuneate_spikes, vel(:,2))
plot(yvel)
%%
leftTD = tdBin([tdBin.target_direction] == pi);
rightTD = tdBin([tdBin.target_direction] == 0);
upTD = tdBin([tdBin.target_direction] == pi/2);
downTD = tdBin([tdBin.target_direction] == 3*pi/2);
cuneate_left = cat(3, leftTD.cuneate_pca);
cuneate_right = cat(3, rightTD.cuneate_pca);
cuneate_up = cat(3, upTD.cuneate_pca);
cuneate_down = cat(3, downTD.cuneate_pca);

figure
hold on
for i = 1:length(rightTD)
    scatter3(cuneate_right(:, 1, i), cuneate_right(:,2,i), cuneate_right(:,4,i), 'r')
    
end
for i = 1:length(upTD)
    scatter3(cuneate_up(:, 1, i), cuneate_up(:,2,i), cuneate_up(:,3,i), 'b')
    
end

for i = 1:length(leftTD)
    scatter3(cuneate_left(:, 1, i), cuneate_left(:,2,i), cuneate_left(:,3,i),'g')
    
end

for i = 1:length(downTD)
    scatter3(cuneate_down(:, 1, i), cuneate_down(:,2,i), cuneate_down(:,3,i),'k')
    
end