%% Load all files for comparison
clear all
close all

butterArray = 'cuneate';
landoArray = 'LeftS1';
crackleArray = 'cuneate';

monkeyButter = 'Butter';
monkeyLando = 'Lando';
monkeyCrackle = 'Snap';

dateButter = '20180326';
dateLando = '20170320';
dateCrackle = '20190829';
mappingLog = getSensoryMappings(monkeyButter);

tdButter =getTD(monkeyButter, dateButter, 'CO',1);
tdLando = getTD(monkeyLando, dateLando, 'COactpas');
tdCrackle = getTD(monkeyCrackle, dateCrackle, 'CO',2);
tdCrackle = getSpeed(tdCrackle);
tdButter= tdCrackle;
%% Preprocess them (binning, trimming etc)
% tdButter = getRWMovements(tdButter);
[~, tdButter]= getTDidx(tdButter,'result', 'r');
[~, tdLando] = getTDidx(tdLando, 'result','r');
% tdButter= removeBadTrials(tdButter);
tdButter = getSpeed(tdButter);
tdButter= getMoveOnsetAndPeak(tdButter);
tdButter= tdButter(~isnan([tdButter.idx_movement_on]));
tdButter = trimTD(tdButter, {'idx_movement_on'}, 'idx_endTime');
tdLando = removeBadTrials(tdLando);
tdLando = trimTD(tdLando, {'idx_movement_on'}, 'idx_endTime');
tdButter= tdToBinSize(tdButter, 50);
tdLando = tdToBinSize(tdLando, 50);

%% Decoding accuracy:
butterNaming = tdButter.([butterArray, '_unit_guide']);
landoNaming = tdLando.([landoArray, '_unit_guide']);

landoVel = cat(1, tdLando.vel);
landoPos = cat(1, tdLando.pos);
landoNeurons = cat(1,tdLando.([landoArray, '_spikes']));
landoSortedNeurons = landoNeurons(:, landoNaming(:,2) ~=0);

butterVel = cat(1, tdButter.vel);
butterPos = cat(1, tdButter.pos);
butterNeurons = cat(1, tdButter.([butterArray, '_spikes']));
butterSortedNeurons = butterNeurons(:,butterNaming(:,2)~=0);

numBoots  =100;
P = .9
for i = 1:numBoots
    [m,n] = size(butterSortedNeurons) ;
    idx = randperm(m)  ;

    butterTraining = butterSortedNeurons(idx(1:round(P*m)),:);
    butterTrainingPosX = butterPos(idx(1:round(P*m)),1);
    butterTrainingPosY = butterPos(idx(1:round(P*m)),2);
    butterTrainingVelX = butterVel(idx(1:round(P*m)),1);
    butterTrainingVelY = butterVel(idx(1:round(P*m)),2);
    butterTrainingSpeed = rownorm(butterVel(idx(1:round(P*m)),:));
    
    butterTesting = butterSortedNeurons(idx(round(P*m)+1:end),:) ;
    butterTestingPosX = butterPos(idx(round(P*m)+1:end),1);
    butterTestingPosY = butterPos(idx(round(P*m)+1:end),2);
    butterTestingVelX = butterVel(idx(round(P*m)+1:end),1);
    butterTestingVelY = butterVel(idx(round(P*m)+1:end),2);
    butterTestingSpeed = rownorm(butterVel(idx(round(P*m)+1:end),:));
    
    [m,n] = size(landoSortedNeurons) ;
    idx = randperm(m)  ;
    landoTraining = landoSortedNeurons(idx(1:round(P*m)), :);
    landoTesting = landoSortedNeurons(idx(round(P*m)+1:end), :);
    
    landoTrainingPosX = landoPos(idx(1:round(P*m)),1);
    landoTrainingPosY = landoPos(idx(1:round(P*m)),2);
    landoTrainingVelX = landoVel(idx(1:round(P*m)),1);
    landoTrainingVelY = landoVel(idx(1:round(P*m)),2);
    landoTrainingSpeed = rownorm(landoVel(idx(1:round(P*m)),:));
    
    landoTestingPosX = landoPos(idx(round(P*m)+1:end),1);
    landoTestingPosY = landoPos(idx(round(P*m)+1:end),2);
    landoTestingVelX = landoVel(idx(round(P*m)+1:end),1);
    landoTestingVelY = landoVel(idx(round(P*m)+1:end),2);
    landoTestingSpeed = rownorm(landoVel(idx(round(P*m)+1:end),:));
   
    butterPosXModel = fitlm(butterTraining, butterTrainingPosX);
    butterPosYModel = fitlm(butterTraining, butterTrainingPosY);
    butterVelXModel = fitlm(butterTraining, butterTrainingVelX);
    butterVelYModel = fitlm(butterTraining, butterTrainingVelY);
    butterSpeedModel = fitlm(butterTraining, butterTrainingSpeed);
    
    landoPosXModel = fitlm(landoTraining, landoTrainingPosX);
    landoPosYModel = fitlm(landoTraining, landoTrainingPosY);
    landoVelXModel = fitlm(landoTraining, landoTrainingVelX);
    landoVelYModel = fitlm(landoTraining, landoTrainingVelY);
    landoSpeedModel = fitlm(landoTraining, landoTrainingSpeed);
    
%     butterR2(i).pos = [butterPosXModel.Rsquared.Adjusted, butterPosXModel.Rsquared.Adjusted];
%     butterR2(i).pos = [butterPosYModel.Rsquared.Adjusted, butterPosYModel.Rsquared.Adjusted];
%     
%     butterR2(i).vel = [butterVelXModel.Rsquared.Adjusted, butterVelXModel.Rsquared.Adjusted];
%     butterR2(i).vel = [butterVelYModel.Rsquared.Adjusted, butterVelYModel.Rsquared.Adjusted];
%     
%     butterR2(i).speed = butterSpeedModel.Rsquared.Adjusted;
%     
%     landoR2(i).pos = [landoPosXModel.Rsquared.Adjusted, landoPosXModel.Rsquared.Adjusted];
%     landoR2(i).pos = [landoPosYModel.Rsquared.Adjusted, landoPosYModel.Rsquared.Adjusted];
% 
%     landoR2(i).vel = [landoVelXModel.Rsquared.Adjusted, landoPosXModel.Rsquared.Adjusted];
%     landoR2(i).vel = [landoVelYModel.Rsquared.Adjusted, landoPosYModel.Rsquared.Adjusted];
%     
%     landoR2(i).speed = landoSpeedModel.Rsquared.Adjusted;
    butterR2(i).pos = [corr(predict(butterPosXModel, butterTesting),butterTestingPosX).^2, corr(predict(butterPosYModel, butterTesting), butterTestingPosY).^2 ];
    butterR2(i).vel = [corr(predict(butterVelXModel, butterTesting), butterTestingVelX).^2, corr(predict(butterVelYModel, butterTesting), butterTestingVelY).^2];
    butterR2(i).speed= corr(predict(butterSpeedModel, butterTesting), butterTestingSpeed').^2;

    landoR2(i).pos = [corr(predict(landoPosXModel, landoTesting), landoTestingPosX).^2,corr(predict(landoPosYModel, landoTesting).^2, landoTestingPosY).^2 ];
    landoR2(i).vel = [corr(predict(landoVelXModel, landoTesting), landoTestingVelX).^2, corr(predict(landoVelYModel, landoTesting), landoTestingVelY).^2];
    landoR2(i).speed= corr(predict(landoSpeedModel, landoTesting), landoTestingSpeed').^2;
end
% In general, it seems that the velocity decoding by the neurons is
% superior to the position decoding. This isn't that surprising and is
% consistent with S1 results
%%
close all
barMat = [mean([landoR2.pos]), mean([landoR2.vel]), mean([landoR2.speed]); ...
    mean([butterR2.pos]), mean([butterR2.vel]), mean([butterR2.speed])];

landoPosMean = mean(cat(1, landoR2.pos),2);
% stdErr = [
landoVelMean = mean(cat(1, landoR2.vel),2);
landoSpeedMean = [landoR2.speed];

butterPosMean = mean(cat(1, butterR2.pos),2);
butterVelMean = mean(cat(1, butterR2.vel),2);
butterSpeedMean = [butterR2.speed];

sderrButterSpeed = sort(bootstrp(1000, @mean, butterSpeedMean- mean(butterSpeedMean)));
sderrButterPos = sort(bootstrp(1000, @mean, butterPosMean- mean(butterPosMean)));
sderrButterVel = sort(bootstrp(1000, @mean, butterVelMean- mean(butterVelMean)));

sderrLandoSpeed = sort(bootstrp(1000, @mean, landoSpeedMean - mean(landoSpeedMean)));
sderrLandoPos =sort(bootstrp(1000, @mean, landoPosMean - mean(landoPosMean)));
sderrLandoVel = sort(bootstrp(1000, @mean, landoVelMean- mean(landoVelMean)));


c = categorical({'Position','Velocity','Speed'});

b1 = bar(barMat');
hold on
c1 = errorbar([.85, 1.15, 1.85,2.15, 2.85, 3.15], [barMat(:,1); barMat(:,2); barMat(:,3)],...
    [sderrLandoPos(25), sderrButterPos(975),...
    sderrLandoVel(25), sderrButterVel(975),...
    sderrLandoSpeed(25), sderrButterSpeed(975)],...
    [sderrLandoPos(25), sderrButterPos(975),...
    sderrLandoVel(25), sderrButterVel(975),...
    sderrLandoSpeed(25), sderrButterSpeed(975)], 'k.');

hold on
d1=scatter(1.15*ones(length(butterPosMean),1), butterPosMean,[],[0.2 .2 .2]);
d2=scatter(2.15*ones(length(butterVelMean),1), butterVelMean, [],[0.2 .2 .2]);
d3=scatter(3.15*ones(length(butterSpeedMean),1), butterSpeedMean,[],[0.2 .2 .2]);
d4=scatter(.85*ones(length(landoPosMean),1), landoPosMean,[],[0.2 .2 .2]);
d5=scatter(1.85*ones(length(landoPosMean),1), landoVelMean,[],[0.2 .2 .2]);
d6=scatter(2.85*ones(length(landoPosMean),1), landoSpeedMean,[],[0.2 .2 .2]);
xticklabels({'Position', 'Velocity', 'Speed'})
set(gca,'TickDir','out', 'box', 'off')
legend(b1, {'Area 2', 'Cuneate'})
ylabel('R2 of Decoding Model')
xlabel('Kinematic input')
