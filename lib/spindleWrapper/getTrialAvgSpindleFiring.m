function [spindleFR,dynSpindleFR,statSpindleFR] = getTrialAvgSpindleFiring(td, params)
close all
spindleBin = .005;
binSize = td(1).bin_size;
padLen = .100;
condition ='target_direction';
trimStart = {'idx_movement_on', -100};
trimEnd = {'idx_movement_on', 400};
plotAvgMuscle = true;
plotSpindleOut = true;

if nargin > 1, assignParams(who,params); end % overwrite defaults

if ~isfield(td, 'idx_movement_on')
%     td = tdToBinSize(td, 10);
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td, struct('s_thresh', 4));
end
proximal = logical([0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,1,0,0,1,0,1,1,1,1,1,1]);
td = trimTD(td, trimStart, trimEnd);
td = removeBadOpensim(td);
allMusc = [td(1).opensim_names];
muscles = allMusc(contains([td(1).opensim_names], '_len'));
muscles = muscles(proximal);
conds = uniquetol([td.(condition)]);
conds(isnan(conds)) =[];
avgMuscLen = mean(cat(1, td.opensim));
avgMuscLen = avgMuscLen(contains([td(1).opensim_names], '_len'));
avgMuscLen = avgMuscLen(proximal);
for i = 1:length(conds)
    tdC = td([td.(condition)] == conds(i));
    muscleLenByTrial{i} = cat(3, tdC.opensim);
    muscleLenTrialAvg(:,:,i) = squeeze(mean(cat(3, tdC.opensim),3));

end

muscleLenTrialAvg = muscleLenTrialAvg(:, contains([td(1).opensim_names], '_len'),:);
muscleLenTrialAvg = muscleLenTrialAvg(:, proximal, :);
if plotAvgMuscle
    plotSpindleFR(muscleLenTrialAvg, struct('names', {muscles}))
end
%% Generate the vector for interpolation and use in the spindle model
t = linspace(binSize, binSize*length(muscleLenTrialAvg(:,1,1))+ padLen, length(muscleLenTrialAvg(:,1,1))+padLen/binSize);
t = (t - t(1))';
resampT =  spindleBin:spindleBin:t(end);

%% For each target direction
for i =1:length(conds) 
    tic
    clear rOut rdOut rsOut
    %% for each muscle
    for j = 1:length(muscleLenTrialAvg(1,:,1))
        len = muscleLenTrialAvg(:, j, i);
        % Prepend the starting length to avoid edge effects
        prependLen = [len(1)*ones(floor((padLen/binSize)), 1) ; len];
        % Normalize length to mean muscle length
        normLen = prependLen/avgMuscLen(j);
        % Resample to 5 ms bins
        resampLen = interp1(t, normLen, resampT);
        
        
        diffLen = diff(resampLen)*1300;
        diffLen = [diffLen(1) diffLen];
        
        [~, dataB, ~, dataC] = sarcSimDriver(resampT, [.3; 0*ones(length(diffLen)-1,1)],[.3; 0*ones(length(diffLen)-1,1)], diffLen); 
        [r, rd, rs] = sarc2spindle(dataB, dataC,1.5,2.0,0.03,1,0);
        
%         r = resample(r, resampT, 1/binSize);
%         rd = resample(rd, resampT, 1/binSize);
%         rs = resample(rs, resampT, 1/binSize);
        r = r(floor(padLen/spindleBin):end);
        rd = rd(floor(padLen/spindleBin):end);
        rs = rs(floor(padLen/spindleBin):end);
        
        rOut(:,j) = r;
        rdOut(:,j) = rd;
        rsOut(:,j) = rs;
        disp(['Done with muscle ', num2str(j)])
    end
    toc
    disp(['Condition ', num2str(i) ' complete of ', num2str(length(conds))])
    spindleFR(:,:,i) = rOut;
    dynSpindleFR(:,:,i) = rdOut;
    statSpindleFR(:,:,i) = rsOut;
    
end
if plotSpindleOut
    plotSpindleFR(spindleFR, struct('names', {muscles}))
end
end