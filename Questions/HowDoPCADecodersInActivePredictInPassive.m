clear all
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')
numPCs = 1:100;
td = getMoveOnsetAndPeak(td);
td = smoothSignals(td, struct('signals', 'cuneate_spikes'));
tdBump = td(~isnan([td.idx_bumpTime]));
tdMove = td(isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, {'idx_bumpTime', 0}, {'idx_bumpTime', 13});
tdMove = trimTD(tdMove, {'idx_movement_on', 0}, {'idx_movement_on', 13});
tdCombo = [tdBump, tdMove];
td = dimReduce(tdCombo, struct('signals', {{'cuneate_spikes', find(td(1).cuneate_unit_guide(:,2)>0)}}));
tdBump = td(~isnan([td.idx_bumpTime]));
tdMove = td(isnan([td.idx_bumpTime]));
for i = numPCs
%%

    %%

    params = struct('model_name' ,'test', 'in_signals', {{'cuneate_pca', 1:i}}, 'out_signals', 'vel', 'onlySorted' , false,'plot_on',false);
    [cv1, cv2,~,~,errorMoveMove, errorMoveBump] = fitCVAndTestLinModel(tdMove, tdBump, params);
    [cv3, cv4,~,~,errorBumpBump, errorBumpMove] = fitCVAndTestLinModel(tdBump, tdMove, params);
    cvMoveMove(i,:) = mean(cv1);
    cvBumpBump(i,:) = mean(cv3);
    cvMoveBump(i,:) = mean(cv2);
    cvBumpMove(i,:) = mean(cv4);
end

%%
figure
plot(cvMoveMove(:,1),'LineWidth', 3)
hold on
plot(cvBumpBump(:,1),'LineWidth', 3)
plot(cvMoveBump(:,1),'LineWidth', 3)
plot(cvBumpMove(:,1),'LineWidth', 3)
legend(['Move Trained',newline, 'Move Tested PCA'], ['Bump Trained', newline,  'Bump Tested PCA'], ['Move Trained' ,newline,  'Bump Tested PCA'], ['Bump Trained',newline,  'Move Tested PCA'],'Location', 'southoutside')
title('R2 of isocontext and contracontext velocity decoding X axis Velocity')
set(gca,'TickDir','out', 'box', 'off')
ylim([0,1])


figure
plot(cvMoveMove(:,2),'LineWidth', 3)
hold on
plot(cvBumpBump(:,2),'LineWidth', 3)
plot(cvMoveBump(:,2),'LineWidth', 3)
plot(cvBumpMove(:,2),'LineWidth', 3)
legend(['Move Trained',newline, 'Move Tested PCA'], ['Bump Trained', newline,  'Bump Tested PCA'], ['Move Trained' ,newline,  'Bump Tested PCA'], ['Bump Trained',newline,  'Move Tested PCA'],'Location', 'southoutside')
title('R2 of isocontext and contracontext velocity decoding Y axis Velocity')
set(gca,'TickDir','out', 'box', 'off')
ylim([0,1])

