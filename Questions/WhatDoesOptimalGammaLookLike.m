close all

clearvars -except td

if exist('td')~=1
    load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Snap\20190829\TD\Snap_CO_20190829_TD_002.mat')
end
spindleBin = .005;
padLen = .100;
condition ='target_direction';
trimStart = {'idx_movement_on', -50};
trimEnd = {'idx_movement_on', 250};
plotAvgMuscle = true;
plotSpindleOut = true;
array = 'cuneate';
binSize = spindleBin;

algorithm = 'sa';
% algorithm = 'ga';

coupledGamma = false;
numSpline = 4;
splineInterp = 1;

params.symFlag = false;
params.useLin = false;
params.plotResult = false;
params.binSize = binSize;
params.padLen = padLen;
params.coupledGamma = true;
params.numSpline = numSpline;

spindleParams = [1.5,2.0,0.03,0,0];


if ~isfield(td, 'idx_movement_on')
%     td = tdToBinSize(td, 10);
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td, struct('s_thresh', 4));
    td = smoothSignals(td, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .03));

end
td1 = trimTD(td, trimStart, trimEnd);
td1 = removeBadOpensim(td1);

guide = td1(1).cuneate_unit_guide;
unit = find(guide(:,1) == 80 & guide(:,2) == 1);

allMusc = [td1(1).opensim_names];
muscles = allMusc(contains([td1(1).opensim_names], '_len'));
muscles = muscles(8);

conds = uniquetol([td1.(condition)]);
conds(isnan(conds)) =[];

avgMuscLen = mean(cat(1, td1.opensim));
avgMuscLen = avgMuscLen(contains([td1(1).opensim_names], '_len'));
avgMuscLen = avgMuscLen(8);

for i = 1:length(conds)
    tdC = td1([td1.(condition)] == conds(i));
    tdC = tdToBinSize(tdC, spindleBin*1000);

    tmp = squeeze(mean(cat(3, tdC.opensim),3));
    tmp = tmp(:,contains([td1(1).opensim_names], '_len'));
    muscleLenTrialAvg(:,i) = squeeze(tmp(:,8,:));
    tmp1 = squeeze(mean(cat(3, tdC.cuneate_spikes),3));
    fr(:,i) = squeeze(tmp1(:, unit,:));
end
binSize = tdC(1).bin_size;


%% Generate the vector for interpolation and use in the spindle model




%% For each target direction
    %% for each muscle
len = muscleLenTrialAvg/avgMuscLen;
% Prepend the starting length to avoid edge effects

c = optimizeGamma(fr, len, spindleParams, [.5,.3*ones(1, length(conds)*numSpline)], params);
ub =  ones(1, numSpline*length(conds)+1);
ub(1) = 600;
lb = zeros(1, numSpline*length(conds)+1);
switch algorithm
    case 'sa'
        opts = optimoptions(@simulannealbnd);
        opts.Display = 'iter';
        opts.MaxStallIterations = 200;
        [gammaMin, cOpt] = simulannealbnd(@(gamma)optimizeGamma(fr, len, spindleParams, gamma, params), [180,.3*ones(1, length(conds)*numSpline)], lb,ub, opts);
    case 'ga'
        opts = optimoptions(@ga);
        opts.Display = 'diagnose';
        [gammaMin, cOpt] = ga(@(gamma)optimizeGamma(fr, len, spindleParams, gamma, params), length([180,.3*ones(1, length(conds)*numSpline)]),[],[],[],[], lb,ub,[], opts);
end
    
%%
close all
t = binSize:binSize:binSize*length(muscleLenTrialAvg(:,1));
figure
for i = 1:length(conds)
   coDirPlot(i)
   plot(t,muscleLenTrialAvg(:,i)/mean(muscleLenTrialAvg(:,i)))
    xlim([0,t(end)])
end

figure
for i = 1:length(conds)
    coDirPlot(i)
    [~, gmas] = getGammaSpline(gammaMin(i,1:4),length(muscleLenTrialAvg(:,i)),false, padLen/binSize);
    [~, gmad] = getGammaSpline(gammaMin(i,1:4),length(muscleLenTrialAvg(:,i)),false, padLen/binSize);
    
    plot(t,gmas)
    hold on
    plot(t,gmad)
    ylim([0,1.2])
    xlim([0,t(end)])
end
subplot(3,3,5)
plot([0,1], [0,0])
hold on
plot([0,1],[1,1])
legend('Static', 'Dynamic')

suptitle('Optimal Gamma Drive')


figure
[c1, r] = optimizeGamma(fr, len, spindleParams, gammaMin, params);

for i = 1:length(conds)
    
    len = muscleLenTrialAvg(:, i);
    % Prepend the starting length to avoid edge effects
    prependLen = [len(1)*ones(floor((padLen/binSize)), 1) ; len];
    % Normalize length to mean muscle length
    normLen = prependLen/avgMuscLen;
    % Resample to 5 ms bins
    
    coDirPlot(i)
    plot(t,r(:,i))
    yyaxis right
    plot(t,fr(:,i))
    xlim([0,t(end)])
end
subplot(3,3,5)
plot([0,1],[1,1])
yyaxis right
plot([0,1], [0,0])
legend('Spindle', 'Neuron')