tdBin = td1;
td_move = trimTD(tdBin, 'idx_peak_speed', 'idx_endTime');
bumpTrialsBin = tdBin(~isnan([tdBin.bumpDir]));
td_pas = trimTD(bumpTrialsBin, {'idx_bumpTime', 0} ,{'idx_bumpTime', 4});

close all

array= 'cuneate';
unitsToInclude =1:length(td_move(1).([array, '_spikes']));
dir_move = cat(1, td_move.target_direction);
% unitsToInclude = [1:9, 11, 14, 15, 16];

firing_move = cat(1, td_move.([array,'_spikes']));
firing_pas = cat(1, td_pas.([array,'_spikes']));
emg_move = cat(1,td_move.emg);

scoredFiring = sqrt(firing_move(:,unitsToInclude));
[coeff, score, latent] = pca(scoredFiring);
scored_emg = zscore(emg_move);
[coeff_emg, score_emg, latent_emg] = pca(scored_emg);

cond =[];
for i = 1:length(td_move)
    cond = [cond; dir_move(i)*ones(length(td_move(i).pos(:,1)), 1)];
end

figure
scatter3(score(cond == 0,1), score(cond==0,2), score(cond==0,3))
hold on
scatter3(score(cond == pi/2,1), score(cond==pi/2,2), score(cond==pi/2,3), 'r')
scatter3(score(cond == pi,1), score(cond==pi,2), score(cond==pi,3), 'k')
scatter3(score(cond == 3*pi/2,1), score(cond==3*pi/2,2), score(cond==3*pi/2,3), 'g')
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
legend('Right', 'Up', 'Left', 'Down')
title('PCA of Active firing')

scatter3(mean(score(cond == 0,1)), mean(score(cond==0,2)), mean(score(cond==0,3)),64,'b', 's')
hold on
scatter3(mean(score(cond == pi/2,1)), mean(score(cond==pi/2,2)), mean(score(cond==pi/2,3)), 64, 'r','s')
scatter3(mean(score(cond == pi,1)), mean(score(cond==pi,2)), mean(score(cond==pi,3)),64, 'k', 's')
scatter3(mean(score(cond == 3*pi/2,1)), mean(score(cond==3*pi/2,2)), mean(score(cond==3*pi/2,3)),64, 'g', 's')



figure
scatter3(score_emg(cond == 0,1), score_emg(cond==0,2), score_emg(cond==0,3))
hold on
scatter3(score_emg(cond == pi/2,1), score_emg(cond==pi/2,2), score_emg(cond==pi/2,3), 'r')
scatter3(score_emg(cond == pi,1), score_emg(cond==pi,2), score_emg(cond==pi,3), 'k')
scatter3(score_emg(cond == 3*pi/2,1), score_emg(cond==3*pi/2,2), score_emg(cond==3*pi/2,3), 'g')
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
legend('Right', 'Up', 'Left', 'Down')
title('PCA of EMG')


dir_bump = cat(1, td_pas.bumpDir);

scoredFiring_pas = sqrt(firing_pas(:,unitsToInclude));
[coeff_pas, score_pas, latent_pas] = pca(scoredFiring_pas);
cond_pas = [];
for i = 1:length(td_pas)
    cond_pas = [cond_pas; dir_bump(i)*ones(length(td_pas(i).pos(:,1)), 1)];
end

figure
scatter3(score_pas(cond_pas == 0,1), score_pas(cond_pas==0,2), score_pas(cond_pas==0,3))
hold on
scatter3(score_pas(cond_pas == 90,1), score_pas(cond_pas==90,2), score_pas(cond_pas==90,3), 'r')
scatter3(score_pas(cond_pas == 180,1), score_pas(cond_pas==180,2), score_pas(cond_pas==180,3), 'k')
scatter3(score_pas(cond_pas == 270), score_pas(cond_pas==270,2), score_pas(cond_pas==270,3), 'g')
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

title('PCA of Passive Firing')
%%

