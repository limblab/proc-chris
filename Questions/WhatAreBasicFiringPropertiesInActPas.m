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
%% Pre-process TD
td1 = removeBadTrials(td);
td1 = removeBadNeurons(td1);
tdAct = trimTD(td1, actWindow{1}, actWindow{2});
tdPas = trimTD(td1, pasWindow{1}, pasWindow{2});
%% Make firing structure

firing.active.left = cat(3, tdAct([tdAct.target_direction] == pi).cuneate_spikes);
firing.active.right = cat(3, tdAct([tdAct.target_direction] == 0).cuneate_spikes);
firing.active.up = cat(3, tdAct([tdAct.target_direction] == pi/2).cuneate_spikes);
firing.active.down = cat(3, tdAct([tdAct.target_direction] == 3*pi/2).cuneate_spikes);
firing.active.all = cat(3, tdAct.cuneate_spikes);

firing.passive.left = cat(3, tdPas([tdPas.bumpDir] == 180).cuneate_spikes);
firing.passive.right = cat(3, tdPas([tdPas.bumpDir] == 0).cuneate_spikes);
firing.passive.up = cat(3, tdPas([tdPas.bumpDir] == 90).cuneate_spikes);
firing.passive.down = cat(3, tdPas([tdPas.bumpDir] == 270).cuneate_spikes);
firing.passive.all = cat(3, tdPas.cuneate_spikes);
%%
colors =linspecer(8);
for i = 1:length(td1(1).cuneate_spikes(1,:))
    close all

    figure
    plot(mean(squeeze(firing.passive.left(:,i,:)),2),'Color', colors(5,:))
    hold on
    plot(mean(squeeze(firing.passive.right(:,i,:)),2),'Color', colors(6,:))
    plot(mean(squeeze(firing.passive.down(:,i,:)),2),'Color', colors(7,:))
    plot(mean(squeeze(firing.passive.up(:,i,:)),2),'Color', colors(8,:))
    
    
    figure
    plot(mean(squeeze(firing.active.left(:,i,:)),2),'Color', colors(1,:))
    hold on
    plot(mean(squeeze(firing.active.right(:,i,:)),2),'Color', colors(2,:))
    plot(mean(squeeze(firing.active.down(:,i,:)),2),'Color', colors(3,:))
    plot(mean(squeeze(firing.active.up(:,i,:)),2),'Color', colors(4,:))
    
    pause
end
%%
firingMean.active.left = squeeze(mean(firing.active.left)).*100;
firingMean.active.left(firingMean.active.left==0) = 1;
firingMean.active.right = squeeze(mean(firing.active.right)).*100;
firingMean.active.right(firingMean.active.right==0) = 1;
firingMean.active.up = squeeze(mean(firing.active.up)).*100;
firingMean.active.up(firingMean.active.up==0) = 1;
firingMean.active.down = squeeze(mean(firing.active.down)).*100;
firingMean.active.down(firingMean.active.down==0) = 1;

firingMean.passive.left = squeeze(mean(firing.passive.left)).*100;
firingMean.passive.left(firingMean.passive.left==0) = 1;
firingMean.passive.right = squeeze(mean(firing.passive.right)).*100;
firingMean.passive.right(firingMean.passive.right==0) = 1;
firingMean.passive.up = squeeze(mean(firing.passive.up)).*100;
firingMean.passive.up(firingMean.passive.up==0) = 1;
firingMean.passive.down = squeeze(mean(firing.passive.down)).*100;
firingMean.passive.down(firingMean.passive.down==0) = 1;

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
    scatter(actVel.left(:,1), actVel.left(:,2), firingMean.active.left(i,:),'r')
    hold on
    scatter(actVel.right(:,1), actVel.right(:,2), firingMean.active.right(i,:),'r')
    scatter(actVel.up(:,1), actVel.up(:,2), firingMean.active.up(i,:),'r')
    scatter(actVel.down(:,1), actVel.down(:,2), firingMean.active.down(i,:),'r')
    
    scatter(pasVel.left(:,1), pasVel.left(:,2), firingMean.passive.left(i,:),'b')
    scatter(pasVel.right(:,1), pasVel.right(:,2), firingMean.passive.right(i,:),'b')
    scatter(pasVel.up(:,1), pasVel.up(:,2), firingMean.passive.up(i,:),'b')
    scatter(pasVel.down(:,1), pasVel.down(:,2), firingMean.passive.down(i,:),'b')
    
    pause
end
