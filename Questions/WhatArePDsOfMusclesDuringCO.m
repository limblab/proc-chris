%% Load and preprocess data
clear all 
close all
date = '20180326';
monkey = 'Butter';
task = 'CO';
array = 'cuneate';

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO',1);
td = normalizeTDLabels(td);
td = getNorm(td,struct('signals','vel','field_extra','speed'));
td = tdToBinSize(td, 10);

%% Set Parameters for PD calculation
if ~isfield(td, 'idx_movement_on')
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeak(td, params);
end

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
param.arrays = {array};
param.in_signals = {'vel'};
param.train_new_model = true;

params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
param.windowAct= windowAct;
param.windowPas =windowPas;
param.date = date;

%% Compute PDs for muscle tuning
musclePDs = coMuscleTuning(td, params);

%% Save muscle PDs
path = getNeuronsPath(musclePDs.actPD);
mkdir([path, filesep, 'musclePDs'])
save([path, filesep,'musclePDs', filesep, strjoin({monkey, date, task, 'MusclePDs'}, '_')],'musclePDs');
%% Get the active and passively tuned neurons
close all
actTunedNeurons = neuronStructPlot(neurons, struct('tuningCondition', {{'isSorted', 'isCuneate', 'proprio'}}));
% pasTunedNeurons = neuronStructPlot(neurons, struct('tuningCondition', {{'isSorted'}}));
%% Get only muscle velocities, plot the PDs between the muscles and the neurons
musclesOnlyAct = musclePDs.actPD(contains(musclePDs.actPD.signalID, '_muscVel'),:);
musclesOnlyPas = musclePDs.pasPD(contains(musclePDs.pasPD.signalID, '_muscVel'),:);
close all
edges = -180:45:180;
fh1 = figure;
histogram(rad2deg(musclesOnlyAct.velPD), edges)
ylabel('Number of Muscle PDs')
yyaxis right
histogram(rad2deg(actTunedNeurons.actPD.velPD),edges)
legend('Muscle PDs', 'Neuron PDs')
title('Active Preferred Directions')
ylabel('Number of neurons')
xlim([-180, 180])
set(gca,'TickDir','out', 'box', 'off')

fh2 = figure;
histogram(rad2deg(musclesOnlyPas.velPD),edges)
ylabel('Number of Muscle PDs')
yyaxis right
histogram(rad2deg(pasTunedNeurons.pasPD.velPD), edges)
legend('Muscle PDs', 'Neuron PDs')
title('Passive PDs')
xlim([-180, 180])
ylabel('Number of neurons')
set(gca,'TickDir','out', 'box', 'off')

savePath = [getBasicPath(monkey, dateToLabDate(date), getGenericTask('CO')), 'plotting', filesep,'MusclePDPlots', filesep];
mkdir(savePath)
title1 = string([monkey, '_',array, '_', date,'_musclePDs']);
saveas(fh1,strcat(savePath, title1, '_actPDs.pdf'))
saveas(fh1,strcat(savePath, title1, '_actPDs.png'))
saveas(fh2,strcat(savePath, title1, '_pasPDs.pdf'))
saveas(fh2,strcat(savePath, title1, '_pasPDs.png'))
%%
close all
windowNeurons = actTunedNeurons(rad2deg(actTunedNeurons.pasPD.velPD) >90 & rad2deg(actTunedNeurons.pasPD.velPD) <180 ,:);
neuronStructPlot(windowNeurons, struct('tuningCondition', {{'isCuneate','sinTunedPas'}},'savePlots', true, 'suffix', 'Windowed'))
%%
close all
for i = 1:height(windowNeurons)
    figure
    plot(windowNeurons.pasTuningCurve.bins(i,:), windowNeurons.pasTuningCurve.velCurve.*20');
%     title(['Channel ', num2str(windowNeurons.chan(i)), ' Unit ', num2str(windowNeurons.ID(i))])
end