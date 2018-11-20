%% Load all files for comparison
clear all
close all
landoArray = 'LeftS1';
butterArray = 'cuneate';

monkeyButter = 'Butter';
monkeyLando = 'Lando';

dateButter = '20180426';
dateLando = '20170223';
mappingLog = getSensoryMappings(monkeyButter);

tdButter =getTD(monkeyButter, dateButter, 'TRT');
tdLando = getTD(monkeyLando, dateLando, 'RW');

%% Preprocess them (binning, trimming etc)
tdButter = getRWMovements(tdButter);
tdButter= removeBadTrials(tdButter);
tdButter = trimTD(tdButter, {'idx_movement_on'}, 'idx_endTime');
tdLando = removeBadTrials(tdLando);
tdLando = trimTD(tdLando, {'idx_movement_on'}, 'idx_endTime');
tdButter= binTD(tdButter, 5);
tdLando = binTD(tdLando, 5);

%% Decoding accuracy:
butterNaming = tdButter.([butterArray, '_unit_guide']);
landoNaming = tdLando.LeftS1_unit_guide;

landoVel = cat(1, tdLando.vel);
landoPos = cat(1, tdLando.pos);
landoNeurons = cat(1,tdLando.([landoArray, '_spikes']));
landoSortedNeurons = landoNeurons(:, landoNaming(:,2) ~=0);

butterVel = cat(1, tdButter.vel);
butterPos = cat(1, tdButter.pos);
butterNeurons = cat(1, tdButter.([butterArray, '_spikes']));
butterSortedNeurons = butterNeurons(:,butterNaming(:,2)~=0);

numBoots  =10;
[m,n] = size(butterSortedNeurons) ;

idx = randperm(m)  ;
for i = 1:m
    flag = 1:m;
    flag = flag ~=m;
    butterTraining = butterSortedNeurons(flag,:);
    butterTrainingPosX = butterPos(flag,1);
    butterTrainingPosY = butterPos(flag,2);
    butterTrainingVelX = butterVel(flag,1);
    butterTrainingVelY = butterVel(flag,2);
    butterTrainingSpeed = rownorm(butterVel(flag,:));
    
    butterTesting = butterSortedNeurons(m,:) ;
    butterTestingPosX = butterPos(m,1);
    butterTestingPosY = butterPos(m,2);
    butterTestingVelX = butterVel(m,1);
    butterTestingVelY = butterVel(m,2);
    butterTestingSpeed = rownorm(butterVel(m,:));
    
    butterPosXModel = fitlm(butterTraining, butterTrainingPosX);
    butterPosYModel = fitlm(butterTraining, butterTrainingPosY);
    butterVelXModel = fitlm(butterTraining, butterTrainingVelX);
    butterVelYModel = fitlm(butterTraining, butterTrainingVelY);
    butterSpeedModel = fitlm(butterTraining, butterTrainingSpeed);
    
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
    butterR2(i).pos = [rsquare(predict(butterPosXModel, butterTesting),butterTestingPosX), rsquare(predict(butterPosYModel, butterTesting), butterTestingPosY) ];
    butterR2(i).vel = [rsquare(predict(butterVelXModel, butterTesting), butterTestingVelX), rsquare(predict(butterVelYModel, butterTesting), butterTestingVelY)];
    butterR2(i).speed= rsquare(predict(butterSpeedModel, butterTesting), butterTestingSpeed');
    disp([num2str(i), ' of', num2str(length(butterTraining(:,1)))])

end
% In general, it seems that the velocity decoding by the neurons is
% superior to the position decoding. This isn't that surprising and is
% consistent with S1 results
%%

[m,n] = size(landoSortedNeurons) ;

idx = randperm(m)  ;
for i = 1:m/10
    flag = 1:m;
    flag = flag ~=m;
    landoTraining = landoSortedNeurons(flag,:);
    landoTrainingPosX = landoPos(flag,1);
    landoTrainingPosY = landoPos(flag,2);
    landoTrainingVelX = landoVel(flag,1);
    landoTrainingVelY = landoVel(flag,2);
    landoTrainingSpeed = rownorm(landoVel(flag,:));
    
    landoTesting = landoSortedNeurons(m,:) ;
    landoTestingPosX = landoPos(m,1);
    landoTestingPosY = landoPos(m,2);
    landoTestingVelX = landoVel(m,1);
    landoTestingVelY = landoVel(m,2);
    landoTestingSpeed = rownorm(landoVel(m,:));
    
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
    landoR2(i).pos = [rsquare(predict(landoPosXModel, landoTesting),landoTestingPosX), rsquare(predict(landoPosYModel, landoTesting), landoTestingPosY) ];
    landoR2(i).vel = [rsquare(predict(landoVelXModel, landoTesting), landoTestingVelX), rsquare(predict(landoVelYModel, landoTesting), landoTestingVelY)];
    landoR2(i).speed= rsquare(predict(landoSpeedModel, landoTesting), landoTestingSpeed');
    disp([num2str(i), ' of', length(landoTraining(:,1))])
end
%%
barMat = [mean([landoR2.pos]), mean([landoR2.vel]), mean([landoR2.speed]); ...
    mean([butterR2.pos]), num2str(mean([butterR2.vel]), mean([butterR2.speed]))];

bar(barMat')
set(gca,'TickDir','out', 'box', 'off')
