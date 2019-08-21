%% Load the TD
close all
clearvars -except tdStart
savePlots = false;
savePlots1 = true;

monkey = 'Butter';
date = '20190117';
array = 'cuneate';
% monkey ='Crackle';
% date = '20190417';
% array = 'cuneate';
task = 'OOR';
params.start_idx        =  'idx_goCueTime';
params.end_idx          =  'idx_endTime';
plotPDs = true;

if ~exist('tdStart') | ~checkCorrectTD(tdStart, monkey, date)
    tdStart =getTD(monkey, date, task,1);
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
td = removeGracileTD(td);

td = removeBadTrials(td);
[~, td] = getTDidx(td, 'result','R');
td(isnan([td.idx_movement_on])) = [];
td = trimTD(td, 'idx_movement_on', 'idx_endTime');

dirsM = unique([td.target_direction]);
dirsM(isnan(dirsM)) = [];

dirsF = unique([td.forceDir]);
dirsF(isnan(dirsF)) = [];

paramsPD.out_signals  = [array, '_spikes'];
paramsPD.out_signal_names  = td(1).([array, '_unit_guide']);

paramsPD.in_signals   = 'vel';
paramsPD.distribution  = 'poisson';
paramsPD.num_boots   = 100;
%%
paramsForce= paramsPD;
paramsForce.in_signals = 'force';
forcePDs = getTDPDs(td, paramsForce);
velPDs = getTDPDs(td, paramsPD);
tuned = checkIsTunedPDtable(velPDs, pi/4, 'vel') & checkIsTunedPDtable(forcePDs, pi/4, 'force');
forcePDs(~tuned,:) = [];
velPDs(~tuned,:) = [];
%%
figure2();
velPD1 = velPDs.velPD;
forcePD1 = forcePDs.forcePD;
pdVFDif = angleDiff(velPD1, forcePD1, true, false);
scatter(velPDs.velPD, forcePDs.forcePD)
hold on
plot([-pi, pi], [-pi, pi],'k--')
title('Velocity vs Force PDs')
xlabel('Velocity PD dir')
ylabel('Force PD dir')
[rho, pval] = circ_corrcc(velPD1, forcePD1);

figure2();
histogram(rad2deg(pdVFDif),15)
title('Angle between force/vel PD')
xlabel('Angle difference (deg)')
ylabel('# of units')

%% Do different force directions have different sensitivities?
% Fit models for each force direction. 
% 1. Are the velocity PDs the same? 
% 2. Do they have the same sensitivity?
% Answers:
% 1. The velocity PDs are very similar across applied force directions for
% most units
% 2. The sensitivities vary significantly as a funciton of the bias force
% directions
sinTuned = ones(length(td(1).cuneate_spikes(1,:)),1);
for i = 1:length(dirsF)
%     h = msgbox(['Working on dir : ', num2str(dirsF(i))]);
    [~, td1] = getTDidx(td, 'forceDir', dirsF(i));
    halfInd = randperm(length(td1));

    pds{i} = getTDPDBootedByTrial(td1, paramsPD);
    sinTuned = sinTuned & logical(checkIsTunedPDtable(pds{i}, pi/4,'vel')); 
    modDepths(:,i) = [pds{i}.velModdepth];
    modDepthCI(:,:,i) = [pds{i}.velModdepthCI];
    pd1(:,i) = [pds{i}.velPD];
    figure2();
%     if isvalid(h); delete(h); end
end
paramsPD.in_signals   = 'force';
%% Do neurons have Force PDs and vel PDs in the same direction?
% 1. How do Force PDs compare to velocity PDs?
% 2. Do computed force PDs change with the bias force changing?
% 3. How does the force sensitivity change with the changing bias force?
% Answers:
% 1. They are largely similar (similar to Prud'homme & Kalaska
% 2. They are largely the same across bias forces.
% 3. The sensitvity changes dramatically across applied bias forces.
sinTunedForce = ones(length(td(1).cuneate_spikes(1,:)),1);
for i = 1:length(dirsF)
%     h = msgbox(['Working on dir : ', num2str(dirsF(i))]);
    [~, td1] = getTDidx(td, 'forceDir', dirsF(i));
    pdsF{i} = getTDPDs(td1, paramsPD);
    sinTunedForce = sinTunedForce & logical(checkIsTunedPDtable(pdsF{i}, pi/4, 'force')); 
    modDepthsF(:,i) = [pdsF{i}.forceModdepth];
    modDepthCIF(:,:,i) = [pdsF{i}.forceModdepthCI];
    pd2(:,i) = [pdsF{i}.forcePD];

%     if isvalid(h); delete(h); end
end
%% Do Force PDs change direction based on the movement velocity?
paramsPD.in_signals   = 'force';
sinTuned3 = ones(length(td(1).cuneate_spikes(1,:)),1);
for i = 1:length(dirsM)
%     h = msgbox(['Working on dir : ', num2str(dirsM(i))]);
    [~, td1] = getTDidx(td, 'target_direction', dirsM(i));
    pds3{i} = getTDPDs(td1, paramsPD);
    sinTuned3 = sinTuned3 & logical(checkIsTunedPDtable(pds3{i}, pi/4,'force')); 
    modDepths3(:,i) = [pds3{i}.forceModdepth];
    modDepthCI3(:,:,i) = [pds3{i}.forceModdepthCI];
    pd3(:,i) = [pds3{i}.forcePD];

%     if isvalid(h); delete(h); end
end
%% Cut out any non-sinusoidally tuned neurons
for i = 1:length(dirsF)
   pds{i} = pds{i}(sinTuned,:);
   pdsF{i} = pdsF{i}(sinTunedForce,:);
end
tunedMF = sinTuned & sinTunedForce;
pdVelTunedBoth = pd1(tunedMF,:);
pdForceTunedBoth = pd2(tunedMF,:);
pd1(~sinTuned ,:) = [];
modDepths(~sinTuned,:) = [];
modDepthCI(~sinTuned,:, :) = []; 
guide = td1(1).cuneate_unit_guide;
guide(~sinTuned,:) =[]; 

pd2(~sinTuned | ~sinTunedForce,:) = [];
modDepthsF(~sinTuned| ~sinTunedForce,:) = [];
modDepthCIF(~sinTuned| ~sinTunedForce,:, :) = []; 
guideF = td1(1).cuneate_unit_guide;
guideF(~sinTunedForce,:) =[];



pd3(~sinTuned3,:) = [];
modDepths3(~sinTuned3, :) =[];
modDepthCI3(~sinTuned3,:) =[];


for i = 1:length(pd1(:,1))
    pd1Var(i) = circ_var(pd1(i,:)');
end
%%
figure2();
histogram(rad2deg(pd1Var), 0:5:90);
title('Neurons have low variance in PD as function of bias forces')
xlabel('Variance in PD (degrees)')
ylabel('# of neurons')
set(gca,'TickDir','out', 'box', 'off')

%% Compute the sensitivities and plot the mo
close all
if plotPDs
savePlots1 = true;
for i = 1:length(pd1(:,1))
    % Plot: Modulation depth across bias force directions
    isUni = circ_rtest(deg2rad(dirsF),modDepths(i,:));
    [~, modDepthPeak] = max(modDepths(i,:));
    peakSensAng(i) = dirsF(modDepthPeak);

    [~, modDepthTrough] = min(modDepths(i,:));

    troughSensAng(i) = dirsF(modDepthTrough);

    close all
    figure2();
    bar(modDepths(i,:))
    hold on
    errorbar(1:8, modDepths(i,:), squeeze(modDepthCI(i,1,:))-modDepths(i,:)',squeeze(modDepthCI(i,2,:))-modDepths(i,:)') 
    title('Sensitivities across force directions')
    xlabel('Force directions')
    ylabel('Sensitivity')
    xticklabels(string(num2cell(dirsF)))
    if savePlots1
        saveas(gca, ['SensitivityDirectionsElec', num2str(guide(i,1)), 'Unit', num2str(guide(i,2)),'.png'])
    end
set(gca,'TickDir','out', 'box', 'off')

    colors = linspecer(length(dirsF));
    % Plot: Velocity PDs across bias force directions
    figure2();
    for j = 1:length(pd1(1,:))
        polarplot([pd1(i,j), pd1(i,j)],[0,modDepths(i,j)], 'Color', colors(j,:))
        hold on
    end
    legend(string(num2cell(dirsF)), 'Location', 'northwest')
    set(gca,'TickDir','out', 'box', 'off')

    title(['Velocity Preferred Directions, Elec ', num2str(guide(i,1)), ' Unit ', num2str(guide(i,2))])
    if savePlots
        saveas(gca, ['VelPreferredDirectionsElec', num2str(guide(i,1)), 'Unit', num2str(guide(i,2)),'.png'])
    end
    figure2();
    polarplot([deg2rad(dirsF), dirsF(1)], [modDepths(i,:), modDepths(i,1)])
    hold on
    polarplot([deg2rad(dirsF), dirsF(1)],[squeeze(modDepthCI(i,1,:));squeeze(modDepthCI(i,1,1))])
    polarplot([deg2rad(dirsF), dirsF(1)], [squeeze(modDepthCI(i,2,:));squeeze(modDepthCI(i,2,1))])
    polarplot([circ_mean(pd1(i,:)'),circ_mean(pd1(i,:)')], [0, max(modDepths(i,:))])
    title(['SensitivitiesByForceBiasElec', num2str(guide(i,1)), 'U', num2str(guide(i,2))])
    set(gca,'TickDir','out', 'box', 'off')
    
    if savePlots
    saveas(gca, ['SensitivitiesByForceBiasElec', num2str(guide(i,1)), 'U', num2str(guide(i,2)), '.png'])
    end
    % Plot: Force PDs as a function of bias force direction
%     pause
end
%%
close all
figure
scatter(peakSensAng, circ_mean(pd1'))

figure
histogram(peakSensAng', 10)
title('Peak sensitivity angle across neurons')
xlabel('Peak sensitivity direction (deg)')
ylabel('Num units')

figure2();
histogram(angleDiff(rad2deg(circ_mean(pd1')'), peakSensAng', false, false),12)
title('Angle between peak sensitivity force direction and PD')
    xlabel('Angle between peak sensitivity force direction and PD')
    ylabel('# of units')
    set(gca,'TickDir','out', 'box', 'off')

figure2();
histogram(angleDiff(rad2deg(circ_mean(pd1')'), troughSensAng', false, false), 12)
title('Angle between lowest sensitivity force direction and PD')
    xlabel('Angle between low sensitivity force direction and PD')
    ylabel('# of units')
    set(gca,'TickDir','out', 'box', 'off')

figure
scatter(angleDiff(rad2deg(circ_mean(pd1')'), troughSensAng', false, false),angleDiff(rad2deg(circ_mean(pd1')'), peakSensAng', false, false))
xlabel('Angle between peak sensitivity force dir and PD')
ylabel('Angle between low sensitivity force dir and PD')
set(gca,'TickDir','out', 'box', 'off')

%%
for i=1:length(pd2(:,1))
    close all
    figure2();
    for j = 1:length(pd2(1,:))
        polarplot([pd2(i,j), pd2(i,j)],[0,modDepthsF(i,j)], 'Color', colors(j,:))
        hold on
    end
    title(['Force Preferred Directions, Elec ', num2str(guideF(i,1)), ' Unit ', num2str(guideF(i,2))])
    set(gca,'TickDir','out', 'box', 'off')
    if savePlots
    saveas(gca, ['ForcePreferredDirectionsElec', num2str(guideF(i,1)), 'Unit', num2str(guideF(i,2)),'.pdf'])
    end
end
%%
    colors = linspecer(length(dirsM));

for i =1 :length(pd3(:,1))
    figure2();
    bar(modDepths3(i,:))
    hold on
    errorbar(1:8, modDepths3(i,:), squeeze(modDepthCI3(i,1,:))-modDepths3(i,:)',squeeze(modDepthCI3(i,2,:))-modDepths3(i,:)') 
    title('Sensitivities across reach directions')
    xlabel('Reach directions')
    ylabel('Sensitivity')
    set(gca,'TickDir','out', 'box', 'off')

    figure2();
    for j= 1:length(pd3(1,:))
        polarplot([pd3(i,j), pd3(i,j)], [0, modDepths3(i,j)], 'Color', colors(j,:))
        hold on
    end
    title('Force PDs across directions')
    set(gca,'TickDir','out', 'box', 'off')

end
end
%% Do assistive and resistive forces have different effects on the sensitivity of CN neurons to velocity?
% Answer: Not in a consistent way. Largely similar. This is strange,
% because the speeds are a good bit lower in the resisted trials. This
% indicates that the power low may not hold in these cases.
tdAssist = td(rad2deg([td.target_direction]) == [td.forceDir]);
tdResist = td(rad2deg([td.target_direction]) == findResistive([td.forceDir]));
paramsPD.in_signals   = 'vel';

pdAssist = getTDPDs(tdAssist,paramsPD);
pdResist = getTDPDs(tdResist, paramsPD);


sinTunedA = checkIsTunedPDtable(pdAssist, pi/4, 'vel');
sinTunedR = checkIsTunedPDtable(pdResist, pi/4, 'vel');
sinTuned1 = sinTunedA & sinTunedR;
pdAssist(~sinTuned1,:) = [];
pdResist(~sinTuned1,:) = [];

assistMod = pdAssist.velModdepth;
resistMod = pdResist.velModdepth;
% plot: Assistive sensitivity vs resistive sensitivity
figure2();
scatter(assistMod, resistMod);
hold on
plot([0, max([assistMod, resistMod])], [0, max([assistMod,resistMod])]);
xlabel('Assistive Sensitivity')
ylabel('Resistive Sensitivity')
title('Effects of assistive vs resistive bumps on neuron sensitivity')
set(gca,'TickDir','out', 'box', 'off')

%% Does assistive force in direction of PD systematically decrease the sensitivity?
% Is this decrease a function of the increased speed?
neuronList = [1 2;...
              6 2;...
              10 3;...
              11 1;...
              12 1;...
              18 2;...
              24 1;...
              36 1;...
              38 1;...
              39 1;...
              40 1;...
              41 1;...
              43 1;...
              51 1;...
              67 1;...
              68 1;...
              69 1;...
              71 1;...
              72 1;...
              74 1;...
              75 1;...
              76 1];

for i = 1:length(dirsM)
    tdMF = td([td.target_direction] == dirsM(i));
    tdMF(isnan([tdMF.idx_peak_speed])) = [];
    tdMF = trimTD(tdMF, {'idx_peak_speed', -10}, {'idx_peak_speed', 10});
    meanFiring(i,:) = getMeanTD(tdMF, struct('signal', 'cuneate_spikes'));
end
[~, pdDir] = max(meanFiring);
guideShort =[];
for i = 1:length(guide(:,1))
%     ind = find(neuronList(i,1) == guide(:,1) & neuronList(i,2) == guide(:,2));
    ind = i;
    tdNeuronAss = forceInPDTrials(td, pdDir(ind));
    tdNeuronRes = forceInPDTrials(td, findResistive(pdDir(ind), true));
    [~, modelAss] = getModel(tdNeuronAss, struct('model_type', 'glm', 'model_name', 'assistive','in_signals', {{'vel'}}, 'out_signals', {{'cuneate_spikes', ind}}));
    [~, modelRes] = getModel(tdNeuronRes, struct('model_type', 'glm', 'model_name', 'assistive','in_signals', {{'vel'}}, 'out_signals', {{'cuneate_spikes', ind}}));
    senAss(i) = norm(modelAss.b(2:3));
    senRes(i) = norm(modelRes.b(2:3));
    guideShort(end+1,:) = guide(ind,:);
    
end
figure2();
scatter(senAss, senRes, 16, 'k', 'filled')
title('Sensitivity in PD, assistive and resistive')
xlabel('Assistive Sensitivity')
ylabel('Resistive Sensitivity')
hold on
plot([0, max(senAss, senRes)] , [0, max(senAss, senRes)], 'k--')
xlim([0, max([senAss, senRes])])
ylim([0, max([senAss, senRes])])

%% Does the resistive bias force actually slow down the movements?
% Answer: Yes, more for some directions than others, but all are slower.
for i = 1:length(dirsM)
    avgVelAssist(i,:) = getMeanTD(tdAssist([tdAssist.target_direction] == dirsM(i)),struct('signal', 'vel'));
    avgVelResist(i,:) = getMeanTD(tdResist([tdResist.target_direction] == dirsM(i)),struct('signal', 'vel'));

end
spdAss = rownorm(avgVelAssist);
spdRes = rownorm(avgVelResist);
figure
scatter(spdAss, spdRes)
axis equal
hold on
plot([0, max([spdAss, spdRes])], [0, max([spdAss, spdRes])])
%% Do the Load-velocity plots in CN look similar to those in S1 (Prudhomme/Kalaska comparison)
% Answer: Not really. They don't seem to have as strong of a load component
% as shown in their paper.
close all
clear meanFiring
for i = 1:length(dirsM)
    for j = 1:length(dirsF)
        tdMF = td([td.forceDir] == dirsF(j) & [td.target_direction] == dirsM(i));
        if ~isempty(tdMF)
        tdMF(isnan([tdMF.idx_peak_speed]))=[];
        tdMF = trimTD(tdMF, {'idx_peak_speed', -10}, {'idx_peak_speed', 10});
        meanFiring(i,j,:) = getMeanTD(tdMF, struct('signal', 'cuneate_spikes'));
        else
            meanFiring(i,j,:) = zeros(1,1,length(meanFiring(1,1,:)));
        end
    end
end
guide1 = td(1).cuneate_unit_guide;
mkdir([getPathFromTD(td), '\plotting\ForceSurfaces\']);
for i =1 :length(meanFiring(1,1,:))
    title1 = ['LoadVelInteractionElec' ,num2str(guide1(i,1)), 'U', num2str(guide1(i,2)),'.pdf'];
    figure();
    surf(meanFiring(:,:,i))
    title(['Load/Velocity interaction Elec: ' ,num2str(guide1(i,1)), ' unit: ', num2str(guide1(i,2))])
    ylabel('Movement direction')
    xlabel('Force direction')
    zlabel('Firing rate')
    if savePlots
        saveas(gca, [getPathFromTD(td),'\plotting\ForceSurfaces\',title1])
    end
end
%%
spikes = [array, '_spikes'];
params.model_type = 'glm';
params.num_boots = 1;
params.eval_metric = 'pr2';
% params.glm_distribution
varsToUse = {{'pos'},...
             {'vel'},...
             {'acc'},...
             {'force'},...
             {'speed'},...
             {'speed';'vel'}};
               
 guide = td(1).cuneate_unit_guide;
     
for i = 1:length(varsToUse)
    disp(['Working on  ' strjoin(varsToUse{i})])
    params.in_signals= varsToUse{i};
    params.model_name = strjoin(varsToUse{i}, '_');
    modelNames{i} = strjoin(varsToUse{i}, '_');
    params.out_signals = {spikes};
    td= getModel(td, params);
    pr2(i,:) = squeeze(evalModel(td, params));
end
%%
params1.glm_distribution = 'normal';
params1.model_type ='glm';
params1.in_signals = {'vel'};
params1.out_signals = {'force'};
params1.model_name = 'vel2force';
params1.eval_metric = 'r2';

td = getModel(td, params1);
pr2Vel2Force = squeeze(evalModel(td, params1));

%%
figure2();
histogram(pr2(2,:),0:.05:1)
hold on
histogram(pr2(4,:),0:.05:1)
%%

