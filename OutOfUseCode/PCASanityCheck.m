close all
clear all
cloudX = normrnd(0,1, 10000,1);
cloudY = 5*normrnd(0,1, 10000,1);
cloud = [cloudX, cloudY]';
rotMat = [1,-1;1,1];
cloud = cloud'*rotMat;

scatter(cloud(:,1), cloud(:,2))
axis square
hold on
plot([-4, 4], [-4, 4])
[coeff, scores, latent, t2, explained, mu] = pca(cloud);

scatter(scores(:,1), scores(:,2))