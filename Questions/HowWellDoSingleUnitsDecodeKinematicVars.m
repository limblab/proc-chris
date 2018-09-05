%% Load all files for comparison
clear all
monkey = 'Butter';
date = '20180405';
mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, 'RW');
tdLando = getTD('Lando', '20170728', 'RW_hold');
%% Preprocess them (binning, trimming etc)
tdButter = getRWMovements(tdButter);
tdButter= removeBadTrials(tdButter);
tdButter = trimTD(tdButter, {'idx_movement_on'}, 'idx_endTime');
tdLando = removeBadTrials(tdLando);
tdLando = trimTD(tdLando, {'idx_movement_on'}, 'idx_endTime');
tdButter= binTD(tdButter, 10);
tdLando = binTD(tdLando, 10);

%% Decoding accuracy of single neurons:
butterNaming = tdButter.cuneate_unit_guide;
landoNaming = tdLando.cuneate_unit_guide;

landoVel = cat(1, tdLando.vel);
landoPos = cat(1, tdLando.pos);
landoNeurons = cat(1,tdLando.cuneate_spikes);
landoSortedNeurons = landoNeurons(:, landoNaming(:,2) ~=0);

butterVel = cat(1, tdButter.vel);
butterPos = cat(1, tdButter.pos);
butterNeurons = cat(1, tdButter.cuneate_spikes);
butterSortedNeurons = butterNeurons(:,butterNaming(:,2)~=0);

for i = 1:length(butterSortedNeurons(1,:))

    butterPosXModel{i} = fitlm(butterSortedNeurons(:,i), butterPos(:,1));
    butterPosYModel{i} = fitlm(butterSortedNeurons(:,i), butterPos(:,2));
    butterVelXModel{i} = fitlm(butterSortedNeurons(:,i), butterVel(:,1));
    butterVelYModel{i} = fitlm(butterSortedNeurons(:,i), butterVel(:,2));
    butterSpeedModel{i} = fitlm(butterSortedNeurons(:,i), rownorm(butterVel));

    butterR2{i}.pos = [butterPosXModel{i}.Rsquared.Adjusted, butterPosYModel{i}.Rsquared.Adjusted];
    butterR2{i}.vel = [butterVelXModel{i}.Rsquared.Adjusted, butterVelYModel{i}.Rsquared.Adjusted];
    butterR2{i}.speed= butterSpeedModel{i}.Rsquared.Adjusted;

end
butterR2Table = struct2table([butterR2{:}]);
for i = 1:length(landoSortedNeurons(1,:))
    landoPosXModel{i} = fitlm(landoSortedNeurons(:,i), landoPos(:,1));
    landoPosYModel{i} = fitlm(landoSortedNeurons(:,i), landoPos(:,2));
    landoVelXModel{i} = fitlm(landoSortedNeurons(:,i), landoVel(:,1));
    landoVelYModel{i} = fitlm(landoSortedNeurons(:,i), landoVel(:,2));
    landoSpeedModel{i} = fitlm(landoSortedNeurons(:,i), rownorm(landoVel));

    landoR2{i}.pos = [landoPosXModel{i}.Rsquared.Adjusted, landoPosYModel{i}.Rsquared.Adjusted];
    landoR2{i}.vel = [landoVelXModel{i}.Rsquared.Adjusted, landoVelYModel{i}.Rsquared.Adjusted];
    landoR2{i}.speed = landoSpeedModel{i}.Rsquared.Adjusted; 
end

landoR2Table = struct2table([landoR2{:}]);


%% Histograms of correlations of neurons w/ kinematics
figure
ax1 = axes('Position',[0 0 1 1],'Visible','off');
ax2 = axes('Position',[.15 .2 .8 .6]);
subplot(6,1,1)
histogram(butterR2Table.pos(:,1),15)
title('Posx')
subplot(6,1,2)
histogram(butterR2Table.pos(:,2),15)
title('Posy')
subplot(6,1,3)
histogram(butterR2Table.vel(:,1),15)
title('Velx')
subplot(6,1,4)
histogram(butterR2Table.vel(:,2),15)
title('Vely')
subplot(6,1,5)
histogram(butterR2Table.speed,15)
title('Speed')
xlim([0,.25])
suptitle('Modulation Depths as determined by unit firing predicted by encoding model')
xlabel('Predicted Modulation depth (highest predicted firing-lowest predicted firing)')
ylabel('# of neurons')
linkaxes
xlim([0,.35])
ax1 = subplot(6,1,6);
axes(ax1)
text(.1,.1,{'Butter20180405RW'}, 'FontSize', 6)
set(ax1, 'Visible', 'off')

%%
butterR2Arr = table2array(butterR2Table);
[coeff, score, latent] = pca(butterR2Arr);

axis equal
figure
ax1 = axes('Position',[0 0 1 1],'Visible','off');
ax2 = axes('Position',[.15 .2 .8 .6]);
scatter(score(:,1), score(:,2))
title('PCA plots of R2 Values for Encoders')
xlabel('PC1')
ylabel('PC3')
axes(ax1)
text(.1,.1,{'Butter20180405RW'}, 'FontSize', 6)