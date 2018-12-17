% monkey = 'Lando';
% date = '20170917';
clear all
monkey = 'Butter';
date = '20180607';
actWindow = {{'idx_movement_on', -5}, {'idx_movement_on', 13}};
pasWindow = {{'idx_bumpTime', -5}, {'idx_bumpTime', 13}};
mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO');
getSensoryMappings(monkey);
% neuronsToUse =  [2,4,60,98,172,12,19,23,25,27,29,91,175];
neuronsToUse = find(td(1).cuneate_unit_guide(:,2) >0);
%% Pre-process TD
td1 = removeBadTrials(td);
td1 =  td1(~isnan([td1.target_direction]));
% td1 = removeBadNeurons(td1);
td1 = smoothSignals(td1, struct('signals', 'cuneate_spikes','kernel_SD', .01, 'causal',true));

tdAct = trimTD(td1, actWindow{1}, actWindow{2});
tdPas = trimTD(td1, pasWindow{1}, pasWindow{2});
%% Make firing structure

firing.active.left.raw = cat(3, tdAct([tdAct.target_direction] == pi).cuneate_spikes);
firing.active.right.raw = cat(3, tdAct([tdAct.target_direction] == 0).cuneate_spikes);
firing.active.up.raw = cat(3, tdAct([tdAct.target_direction] == pi/2).cuneate_spikes);
firing.active.down.raw = cat(3, tdAct([tdAct.target_direction] == 3*pi/2).cuneate_spikes);
firing.active.all = cat(3, tdAct.cuneate_spikes);

firing.passive.left.raw = cat(3, tdPas([tdPas.bumpDir] == 180).cuneate_spikes);
firing.passive.right.raw = cat(3, tdPas([tdPas.bumpDir] == 0).cuneate_spikes);
firing.passive.up.raw = cat(3, tdPas([tdPas.bumpDir] == 90).cuneate_spikes);
firing.passive.down.raw = cat(3, tdPas([tdPas.bumpDir] == 270).cuneate_spikes);
firing.passive.all = cat(3, tdPas.cuneate_spikes);
%%
%%
firing.active.left.mean = squeeze(mean(firing.active.left.raw,3)).*100;
firing.active.right.mean = squeeze(mean(firing.active.right.raw,3)).*100;
firing.active.up.mean = squeeze(mean(firing.active.up.raw,3)).*100;
firing.active.down.mean = squeeze(mean(firing.active.down.raw,3)).*100;
%%
firing.passive.left.mean = squeeze(mean(firing.passive.left.raw,3)).*100;
firing.passive.right.mean = squeeze(mean(firing.passive.right.raw,3)).*100;
firing.passive.up.mean = squeeze(mean(firing.passive.up.raw,3)).*100;
firing.passive.down.mean = squeeze(mean(firing.passive.down.raw,3)).*100;
% %%
% colors =linspecer(8);
% for i = 1:length(td1(1).cuneate_spikes(1,:))
%     close all
% 
%     figure
%     plot(mean(squeeze(firing.passive.left.mean(:,i,:)),2),'Color', colors(5,:))
%     hold on
%     plot(mean(squeeze(firing.passive.right.mean(:,i,:)),2),'Color', colors(6,:))
%     plot(mean(squeeze(firing.passive.down.mean(:,i,:)),2),'Color', colors(7,:))
%     plot(mean(squeeze(firing.passive.up.mean(:,i,:)),2),'Color', colors(8,:))
%     
%     
%     figure
%     plot(mean(squeeze(firing.active.left.mean(:,i,:)),2),'Color', colors(1,:))
%     hold on
%     plot(mean(squeeze(firing.active.right.mean(:,i,:)),2),'Color', colors(2,:))
%     plot(mean(squeeze(firing.active.down.mean(:,i,:)),2),'Color', colors(3,:))
%     plot(mean(squeeze(firing.active.up.mean(:,i,:)),2),'Color', colors(4,:))
%     
%     pause
% end

%%
temp = cp_als(tensor(firing.active.all(:, neuronsToUse,:)- mean(firing.active.all(:,neuronsToUse, :))), 2, 'maxiters', 300, 'printitn',10);
%M_neural = cp_apr(neural_tensor,num_factors,'maxiters',300,'printitn',10);% color by direction
num_colors = 4;
dir_colors = linspecer(num_colors);
trial_dirs = cat(1,td1.target_direction);
dir_idx = mod(round(trial_dirs/(2*pi/num_colors)),num_colors)+1;
trial_colors = dir_colors(dir_idx,:);

% plot tensor decomposition
plotTensorDecomp(temp,struct('trial_colors',trial_colors,'bin_size',td1(1).bin_size,'temporal_zero',5+1))

%% Compute the PCA plot of selected neurons
close all
% neuronsToUse =  [2,4,60,98,172,12,19,23,25,27,29,91,175];
allPSTH = [firing.active.left.mean(:,neuronsToUse), firing.active.right.mean(:,neuronsToUse), firing.active.up.mean(:,neuronsToUse), firing.active.down.mean(:,neuronsToUse)];
wristFlexors = [98, 19, 23, 25,27,29];
wristExtensors = [4,12];
latSpindle = [60];
elbowFlexion = [172,91 175];
bicepSpindle = [2];

[~, intersectWF] = intersect(neuronsToUse, wristFlexors, 'stable');
[~, intersectWE] = intersect(neuronsToUse, wristExtensors, 'stable');
[~, intersectLat] = intersect(neuronsToUse, latSpindle, 'stable');
[~, intersectEF] = intersect(neuronsToUse, elbowFlexion, 'stable');
[~, intersectBic]= intersect(neuronsToUse, bicepSpindle, 'stable');

intersectWF = vertcat(intersectWF, intersectWF+13, intersectWF+26, intersectWF +39);
intersectWE = vertcat(intersectWE, intersectWE+13, intersectWE+26, intersectWE +39);
intersectLat = vertcat(intersectLat, intersectLat+13, intersectLat+26, intersectLat +39);
intersectEF = vertcat(intersectEF, intersectEF+13, intersectEF+26, intersectEF +39);
intersectBic = vertcat(intersectBic, intersectBic+13, intersectBic+26, intersectBic +39);


[coeff, scores, latent, t2, explained, mu] = pca(allPSTH);
[W, H] = nnmf(allPSTH, 2);

figure2();
plot(-50:10:130,scores(:,1))
hold on
plot(-50:10:130,scores(:,2))
plot(-50:10:130,scores(:,3))
plot(-50:10:130,scores(:,4))
title('PCA templates for PSTH')
xlabel('time (ms)')
ylabel('firing (Hz)')
legend('PCA1', 'PCA2', 'PCA3','PCA4')
set(gca,'TickDir','out', 'box', 'off')

figure2();
scatter(W(:,1), W(:,2))

figure2();
plot(cumsum(explained))
title('Variance explained plot')
xlabel('PCs included')
ylabel('Variance explained')
set(gca,'TickDir','out', 'box', 'off')

colors = linspecer(5);

figure2();
scatter3(coeff(intersectWF,1), coeff(intersectWF,2), coeff(intersectWF,3),[], colors(1,:))
hold on
scatter3(coeff(intersectEF,1), coeff(intersectEF,2), coeff(intersectEF,3),[], colors(2,:))
scatter3(coeff(intersectLat,1), coeff(intersectLat,2), coeff(intersectLat,3),[], colors(3,:))
scatter3(coeff(intersectWE,1), coeff(intersectWE,2), coeff(intersectWE,3),[], colors(4,:))
scatter3(coeff(intersectBic,1), coeff(intersectBic,2), coeff(intersectBic,3),[], colors(5,:))

legend('Wrist flexor spindles', 'Elbow Flexion', 'Lat spindle', 'Wrist Extensor Spindle', 'Biceps Spindle')
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
axis equal
CaptureFigVid([[1:360]', 20*ones(360,1)], 'ClusteringVideoPSTHPCs.mpg')

%%
firing.active.left.autocor = autocorr(firing.active.left.mean);
firing.active.right.autocor = autocorr(firing.active.right.mean);
firing.active.up.autocor = autocorr(firing.active.up.mean);
firing.active.down.autocor = autocorr(firing.active.down.mean);

firing.passive.left.autocor = autocorr(firing.passive.left.mean);
firing.passive.right.autocor = autocorr(firing.passive.right.mean);
firing.passive.up.autocor = autocorr(firing.passive.up.mean);
firing.passive.down.autocor = autocorr(firing.passive.down.mean);

%% Get position for each trial at 100 ms post onset
tdActiveKinematics  = trimTD(tdAct, {'idx_movement_on', 10}, {'idx_movement_on', 10});
tdPassiveKinematics = trimTD(tdPas, {'idx_bumpTime', 10}, {'idx_bumpTime', 10});

actVel.left = cat(1, tdActiveKinematics([tdAct.target_direction] == pi).vel);
actVel.right = cat(1, tdActiveKinematics([tdAct.target_direction] == 0).vel);
actVel.down = cat(1, tdActiveKinematics([tdAct.target_direction] == 3*pi/2).vel);
actVel.up = cat(1, tdActiveKinematics([tdAct.target_direction] == pi/2).vel);

pasVel.left = cat(1, tdPassiveKinematics([tdPas.bumpDir] == 180).vel);
pasVel.right = cat(1, tdPassiveKinematics([tdPas.bumpDir] == 0).vel);
pasVel.down = cat(1, tdPassiveKinematics([tdPas.bumpDir] == 270).vel);
pasVel.up = cat(1, tdPassiveKinematics([tdPas.bumpDir] == 90).vel);

%% Plot neuron firing rates as function of direction
for i = 1:length(tdAct(1).cuneate_spikes(1,:))
    close all
    figure
    scatter(actVel.left(:,1), actVel.left(:,2), firing.active.left(i,:),'r')
    hold on
    scatter(actVel.right(:,1), actVel.right(:,2), firing.active.right(i,:),'r')
    scatter(actVel.up(:,1), actVel.up(:,2), firing.active.up(i,:),'r')
    scatter(actVel.down(:,1), actVel.down(:,2), firing.active.down(i,:),'r')
    
    scatter(pasVel.left(:,1), pasVel.left(:,2), firing.passive.left(i,:),'b')
    scatter(pasVel.right(:,1), pasVel.right(:,2), firing.passive.right(i,:),'b')
    scatter(pasVel.up(:,1), pasVel.up(:,2), firing.passive.up(i,:),'b')
    scatter(pasVel.down(:,1), pasVel.down(:,2), firing.passive.down(i,:),'b')
    
    pause
end
