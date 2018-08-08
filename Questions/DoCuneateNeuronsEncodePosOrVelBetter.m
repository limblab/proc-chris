%% Load all files for comparison
load('/media/chris/DataDisk/MonkeyData/CO/Butter/20180607/TD/Butter_CO_20180607_1_TD_sorted-resort_resort.mat')
tdButter = td;
load('/media/chris/DataDisk/MonkeyData/CO/Lando/20170917/TD/Lando_COactpas_20170917_TD.mat')
tdLando = td;
%% Preprocess them (binning, trimming etc)
tdButter = trimTD(tdButter, {'idx_endTime', -50}, 'idx_endTime');
tdLando = trimTD(tdLando, {'idx_endTime', -50}, 'idx_endTime');
tdButter= binTD(tdButter, 5);
tdLando = binTD(tdLando, 5);

%% Decoding accuracy:
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

butterPosXModel = fitlm(butterSortedNeurons, butterPos(:,1));
butterPosYModel = fitlm(butterSortedNeurons, butterPos(:,2));
butterVelXModel = fitlm(butterSortedNeurons, butterVel(:,1));
butterVelYModel = fitlm(butterSortedNeurons, butterVel(:,2));

butterR2.pos = [butterPosXModel.Rsquared.Adjusted, butterPosYModel.Rsquared.Adjusted];
butterR2.vel = [butterVelXModel.Rsquared.Adjusted, butterVelYModel.Rsquared.Adjusted];

landoPosXModel = fitlm(landoSortedNeurons, landoPos(:,1));
landoPosYModel = fitlm(landoSortedNeurons, landoPos(:,2));
landoVelXModel = fitlm(landoSortedNeurons, landoVel(:,1));
landoVelYModel = fitlm(landoSortedNeurons, landoVel(:,2));

landoR2.pos = [landoPosXModel.Rsquared.Adjusted, landoPosYModel.Rsquared.Adjusted];
landoR2.vel = [landoVelXModel.Rsquared.Adjusted, landoVelYModel.Rsquared.Adjusted];
% In general, it seems that the velocity decoding by the neurons is
% superior to the position decoding. This isn't that surprising and is
% consistent with S1 results
