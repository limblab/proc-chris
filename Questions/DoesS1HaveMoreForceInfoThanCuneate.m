%% Load the TD
close all
clear all

% monkey = 'Han';
% date = '20170203';
% array = 'S1';
% monkey = 'Butter';
% date = '20190117';
% array = 'cuneate';
monkey ='Crackle';
date = '20190417';
array = 'cuneate';
task = 'OOR';
params.start_idx        =  'idx_goCueTime';
params.end_idx          =  'idx_endTime';

if ~exist('tdStart') %| ~checkCorrectTD(tdStart, monkey, date)
    tdStart =getTD(monkey, date, task,1);
    if length(tdStart) == 1
        tdStart = splitTD(tdStart);
    end
    tdStart = tdToBinSize(tdStart, 10);

end


td = smoothSignals(tdStart, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .1));
for i= 1:length(td)
    if td(i).forceDir == 360
        td(i).forceDir = 0;
    end
end
td = removeUnsorted(td);
td = getSpeed(td);
td = getMoveOnsetAndPeak(td, params);
% td = removeGracileTD(td);

td = removeBadTrials(td);
[~, td] = getTDidx(td, 'result','R');
td(isnan([td.idx_movement_on])) = [];
td = trimTD(td, 'idx_movement_on', 'idx_endTime');

dirsM = unique([td.tgtDir]);
dirsM(isnan(dirsM)) = [];

dirsF = unique([td.forceDir]);
dirsF(isnan(dirsF)) = [];


spikes = [array, '_spikes'];
params.model_type = 'linmodel';
params.num_boots = 1;
params.eval_metric = 'r2';
% params.glm_distribution
varsToUse = {{'vel', 1:2},...
             {'force', 1:2}};
               
 guide = td(1).([array, '_unit_guide']);
     %%
for i = 1:length(td(1).(spikes)(1,:))
    for j =1:length(varsToUse)
        params.out_signals= varsToUse{j};
        params.model_name = varsToUse{j}{1};
        params.in_signals = {spikes,i};
        td= getModel(td, params);
        r2S1(i,j) = mean(squeeze(evalModel(td, params)));
        r2Cu(i,j) = mean(squeeze(evalModel(td, params)));
        r2Cr(i,j) = mean(squeeze(evalModel(td, params)));
    end
end
%%
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\OOR\Han\20170203\SingleUnitDecodingS1.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\OOR\Butter\20190117\SingleUnitDecoding.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\OOR\Crackle\20190417\SingleUnitDecodingCr.mat')

%%
figure2();
histogram(r2S1(:,1),0:.01:.35)
hold on
histogram(r2S1(:,2),0:.01:.35)
xlabel('Decoding R2')
ylabel('# of Units')
legend('Velocity', 'Force')
title('S1 single unit Decoding Force/vel')

figure2();
histogram(r2Cu(:,1),0:.01:.35)
hold on
histogram(r2Cu(:,2),0:.01:.35)
xlabel('Decoding R2')
ylabel('# of Units')
legend('Velocity', 'Force')
title('Cuneate single unit Decoding Force/vel')

figure2();
histogram(r2Cr(:,1),0:.01:.35)
hold on
histogram(r2Cr(:,2),0:.01:.35)
xlabel('Decoding R2')
ylabel('# of Units')
legend('Velocity', 'Force')
title('Cuneate Crackle single unit Decoding Force/vel')

mean(r2S1(:,2))
mean(r2Cu(:,2))
mean(r2Cr(:,2))