%% Basic parameter setup
close all
clearvars -except td1Start td2Start
plotResponses = false; % if you want to plot the actual and predicted responses
plotPerpFiring = true; % if you want to plot the firing rates in a scatter plot
normalizeFR = true; % To normalize firing rate to premovement firing
sqrtTransform = true;
useLMTransform = true; % To transform the two days into same scale with a simple linear regression on the PSTHs
plotRescaling = true; % To plot the rescaling of the PSTHs post-modeling
zeroBump = true; % Testing the effect of zeroing out the bump prediction on fits
zeroMove = false; % Testing the effect of zeroing out the move prediction on fits
meanSubtract= false; % Whether to subtract the mean in the R2 calculation (makes it only count predictive accuracy above predicting the mean firing rate)
actSubtract = true; % Subtract the active condition to determine the contribution of just the bump to the residual
useMaxBumpDir = false;
%% File parameters
date = '20180530';
monkey = 'Butter';
unitNames= 'cuneate';
%% Load the TDs (if they haven't yet been loaded) and do the time-intensive processing
if ~exist('td1Start') | ~exist('td2Start')
    
td1Start =getTD(monkey, date, 'COmoveBump',1);
td2Start = getTD(monkey, '20180607','CO',1);
% Add a speed term
td1Start = getNorm(td1Start,struct('signals','vel','field_extra','speed')); 
td2Start = getNorm(td2Start,struct('signals','vel','field_extra','speed'));
% bin to 10 ms
td1Start = tdToBinSize(td1Start, 10);
td2Start = tdToBinSize(td2Start,10);
end

%% Load the Neuron structs (not necessary anymore, but the code is useful)
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\neuronStruct\Butter_20180607_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons2 = neurons;
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180530\neuronStruct\Butter_20180530_CObump_cuneate_idx_movement_on_0_idx_movement_on_13_idx_bumpTime_0_idx_bumpTime_13_NeuronStruct_MappedNeurons.mat')
neurons1 = neurons;
clear neurons;
%% Compute the neuron matching (the manual list if based on visual PSTH and waveshape inspection)
% crList= findMatchingNeurons(neurons1, neurons2);
crList =  [1 2 1 2; ...
           2 1 2 1;...
           3 1 3 1;...
           11 1 11 1; ...
           12 1 12 1;...
           14 1 14 1; ...
           16 1 16 1;...
           17 1 17 1;...
           18 1 18 1;...
           18 2 18 3;...
           20 1 20 1; ...
           20 2 20 2; ...
           22 1 22 1; ...
           22 2 22 2; ...
           23 1 23 1; ...
           24 2 24 2; ...
           24 3 24 3; ...
           27 1 27 1; ...
           27 2 27 2; ...
           33 1 33 1; ...
           36 1 36 1; ...
           38 1 38 1; ...
           40 1 40 1; ...
           41 1 41 1;...
           42 1 42 1; ...
           45 1 45 1; ...
           50 1 50 1; ...
           62 1 62 1; ...
           67 1 67 1; ...
           72 1 72 2; ...
           74 1 74 1;...
           76 1 76 1];
           
           
%% Compute the bump effect and move effect from 0607
% Smoothing firing rates w/ 50 ms gaussian kernel
td1 = smoothSignals(td1Start, struct('signals', ['cuneate_spikes']));
td2 = smoothSignals(td2Start, struct('signals', ['cuneate_spikes']));

% Getting move onset
td2 = getMoveOnsetAndPeak(td2);
td1 = getMoveOnsetAndPeak(td1);

% Trimming premovement and movement windows for the center-bump trials
preMove2 = trimTD(td2, {'idx_goCueTime', -10}, {'idx_goCueTime', -5});
tdMove2= trimTD(td2, {'idx_goCueTime',50}, {'idx_goCueTime', 63}); % when the bump "would have" been
tdBump2= td2(~isnan([td2.idx_bumpTime])); % Get just the bump trials
tdBump2 = trimTD(tdBump2, 'idx_bumpTime', {'idx_bumpTime', 13}); % get the center-hold bumps

%% Parse all directions in both days
dirsM = unique([tdMove2.target_direction]);
dirsB = unique([tdBump2.bumpDir]);
dirsM = dirsM(~isnan(dirsM));
dirsB = dirsB(~isnan(dirsB));

%% Compute the bump effect and move effect from 0530
%% Trim 0530 file into premovement and bump times
disp('Trimming Files')
preMove1 = trimTD(td1, {'idx_goCueTime', -10}, {'idx_goCueTime', -5}); %Premovement
scaleMove = td1(isnan([td1.bumpDir]));
% Get the reach direction PSTH plots for both files
noBumpAct1 = trimTD(scaleMove, {'idx_goCueTime', 50}, {'idx_goCueTime', 63});
scale1 = trimTD(scaleMove, {'idx_movement_on', -30}, {'idx_movement_on',30});
scale2 = trimTD(td2, {'idx_movement_on', -30}, {'idx_movement_on',30});
td1 = trimTD(td1, {'idx_goCueTime', 50}, {'idx_goCueTime', 63}); % Bump

unitG1= td1(1).cuneate_unit_guide; % Get unit guide for 0530
unitG2 = td2(1).cuneate_unit_guide; % Get unit guide for 0607

firingPre1 = cat(1, preMove1.cuneate_spikes)/preMove1(1).bin_size; % Premove Firing for 0530
firingPre2 = cat(1, preMove2.cuneate_spikes)/preMove2(1).bin_size; % Premove Firing for 0607

firingMeanPre2 = mean(firingPre2); % mean Premove Firing
firingMeanPre1 = mean(firingPre1); % mean Premove Firing

firingScale1 = cat(3, scale1.cuneate_spikes)/scale1(1).bin_size; %
firingScale2 = cat(3, scale2.cuneate_spikes)/scale2(1).bin_size;

% This is only used if the LM model isn't selected
firingMeanScale1 = firingMeanPre1;
firingMeanScale2 = firingMeanPre2;
disp('Scaling to the same units')

%% Iterate through units in 0607 and compute move effects and bump effects by direction
for i = 1:length(unitG2)
    % For each reach direction compute the mean firing rate change
    for j = 1:length(dirsM)
        tdMDir = tdMove2([tdMove2.target_direction] == dirsM(j));
        firing = cat(1, tdMDir.cuneate_spikes)/tdMDir(1).bin_size;
        unitMFR(i,j) = mean(firing(:, i)) - firingMeanPre2(i);
    end
    % For each bump direction compute the mean firing rate change
    for k = 1:length(dirsB)
        tdBDir = tdBump2([tdBump2.bumpDir] == dirsB(k));
        firing = cat(1, tdBDir.cuneate_spikes)/tdBDir(1).bin_size;
        unitBFR(i,k) = mean(firing(:, i)) - firingMeanPre2(i);
    end
    % Compute the "predicted" linear combination of these two effects.
    for j = 1:4
        for k = 1:4
            if zeroBump
                unitBFR(i,k) = 0;
            end
            if zeroMove
                unitMFR(i,j) = 0;
            end
            predicted(i,j,k) = unitMFR(i,j) + unitBFR(i, k)+ firingMeanPre2(i);
        end
    end 
end
%% Iterate through each neuron for the move-bump session
for i = 1:length(unitG1)
    % And compute for each move direction
    for j = 1:length(dirsM)
        % in tandem with the bump direction what the actual firing rate is.
        for k = 1:length(dirsB)
            tdDir{j,k} = td1([td1.bumpDir] == dirsB(k) & ...
                [td1.target_direction] == dirsM(j)); % get the move-bump combo
            firing = cat(1, tdDir{j,k}.cuneate_spikes)/tdDir{j,k}(1).bin_size; 
            actual(i,j,k) = mean(firing(:,i)); 
        end
        tdReach1{j} = td1(isnan([td1.bumpDir]) & [td1.target_direction] == dirsM(j));
        firing = cat(1, tdReach1{j}.cuneate_spikes)/tdReach1{j}(1).bin_size;
        actualReach(i,j) = mean(firing(:,i));
    end
end
%% Iterate through matched neurons across days
close all
predicted(predicted<0) = 0; % Constrain tuning curve to be non-negative

savePath = [getBasePath(), getGenericTask(td1(1).task), ...
    filesep,td1(1).monkey,filesep date, filesep, 'plotting',...
    filesep, 'MoveBumpPredictions',filesep];

goodScale = ones(length(crList(:,1)),1);
for i = 1:length(crList)
    close all


    % Find the index of the unitGuide corresponds to each matched neuron
    ind1 = find(unitG1(:,1) == crList(i,1) &...
        unitG1(:,2) == crList(i,2));
    ind2 = find(unitG2(:,1) == crList(i,3) &...
        unitG2(:,2) == crList(i,4));
    title1 = [monkey, ' Electrode ' num2str(unitG2(ind2,1)),...
        ' Unit ', num2str(unitG2(ind2,2))];
    % if you want to do a simple scaling...
    if ~useLMTransform
        firingScalar = firingMeanScale2(ind2)/firingMeanScale1(ind1);
        % Get the actual and predicted firing rates for that neuron
        actualCR(i,:,:) = squeeze(actual(ind1,:,:))*firingScalar;
        actualReachMatch(i,:) = squeeze(actualReach(ind1, :))*firingScalar;
    else % simple linear regression works much better
        for j = 1:length(dirsM)
            % Get the firing directions
            firingDirs1 = scale1([scale1.target_direction] == dirsM(j));
            firingDirs2 = scale2([scale2.target_direction] == dirsM(j));
            % Get the actual firing
            firingScale1 = cat(3, firingDirs1.cuneate_spikes);
            firingScale2 = cat(3, firingDirs2.cuneate_spikes);
            % compute the PSTH of the response
            firingScale1PSTH(:,j) = mean(squeeze(firingScale1(:, ind1,:)),2);
            firingScale2PSTH(:,j) = mean(squeeze(firingScale2(:, ind2,:)),2);
        end
        % Vectorize across all directions
        firingPSTH1= firingScale1PSTH(:);
        firingPSTH2 = firingScale2PSTH(:);
        % Fit a linear model relating the two files (file 1 to file 2)
        lmScale = fitlm(firingPSTH1, firingPSTH2);
        % Find how well that model fits (typically >.8)
        r2Scale(i) = lmScale.Rsquared.Adjusted;
        temp = actual(ind1,:,:);
        temp = temp(:);
        % Predict the rescaled file 1 in file 2 terms
        temp1 = predict(lmScale, temp); 
        % put it back into the same shape
        actualCR(i,:,:) = reshape(temp1, 4,4);
        actualReachMatch = predict(lmScale, actualReach(ind1,:)')';
        % Rescale the PSTHs too, for visual inspection
        for j = 1:4
            firingScale12PSTH(:,j) = predict(lmScale, firingScale1PSTH(:,j));
        end
        % If you want to see how well this seems to work, check these plots
        % out
        if plotRescaling
            fh2 = figure;%('Visible', 'off');
            subplot(3,3,7)
            tx = text(0, 0, ['R2 = ', num2str(r2Scale(i))]);
            extent = tx.Extent;
            xlim([extent(1), extent(1) + extent(3)])
            ylim([extent(2), extent(2) + extent(4)])
            set(gca,'ycolor','w')
            set(gca,'xcolor','w')
            
            subplot(3,3,6)
            plot(firingScale1PSTH(:, 1))
            hold on
            plot(firingScale2PSTH(:,1))
            plot(firingScale12PSTH(:,1))
            
            subplot(3,3,2)
            plot(firingScale1PSTH(:, 2))
            hold on
            plot(firingScale2PSTH(:,2))
            plot(firingScale12PSTH(:,2))
            
            subplot(3,3,4)
            plot(firingScale1PSTH(:, 3))
            hold on
            plot(firingScale2PSTH(:,3))      
            plot(firingScale12PSTH(:,3))
            
            subplot(3,3,8)
            plot(firingScale1PSTH(:, 4))
            hold on
            plot(firingScale2PSTH(:,4))
            plot(firingScale12PSTH(:,4))
            
            subplot(3,3,9)
            plot([0,1], [0,1])
            hold on
            plot([0,1], [1,0])
            plot([0,1], [.5,.5])
            legend('Scale 1', 'Scale 2', 'Matched Scale')
            suptitle1(['Electrode ', num2str(unitG2(ind2,1)), ' Unit ', num2str(unitG2(ind2, 2))])
            set(fh2, 'Renderer', 'Painters');
            save2pdf([savePath,strrep(title1, ' ', '_'), '_LinScaling_', num2str(date), '.pdf'],fh2)
            saveas(fh2,[savePath, strrep(title1, ' ', '_'), '_LinScaling_', num2str(date), '.png'])
    
        end
    end
    % If the scaling worked (r2 over .8) then I'll consider them well
    % scaled
    goodScale = r2Scale>.8;
    % Get the predicted FR for your unit
    predictedCR(i,:,:) = squeeze(predicted(ind2, :,:));
    theta = deg2rad([dirsB, dirsB(1)]);
    
    % THIS IS KEY LINE: This is where I get the actual (due to the reach
    % bump) and the predicted (combination of center hold bump and reach
    % modulation) for a matched neuron pair across both days.
    act = squeeze(actualCR(i,:,:));
    pred = squeeze(predictedCR(i,:,:));
    % If you want to normalize based on premovement firing
    if normalizeFR
        if sqrtTransform
            perpPred(i,:) = sqrt([pred(1,2), pred(1, 4), pred(2, 1), pred(2, 3), ...
                pred(3,2), pred(3, 4), pred(4,1), pred(4,3)]);
        
            perpAct(i,:) = sqrt([act(1,2), act(1, 4), act(2, 1), act(2, 3), ...
                act(3,2), act(3, 4), act(4,1), act(4,3)]);

            inLinePred(i,:) = sqrt([pred(1,1),pred(2,2),pred(3,3), pred(4,4)]);
            resistPred(i,:) = sqrt([pred(1,3),pred(2,4), pred(3,1), pred(4,2)]);

            inLineAct(i,:) = sqrt([act(1,1),act(2,2),act(3,3), act(4,4)]);
            resistAct(i,:) = sqrt([act(1,3),act(2,4), act(3,1), act(4,2)]);
        else
        perpPred(i,:) = [pred(1,2), pred(1, 4), pred(2, 1), pred(2, 3), ...
            pred(3,2), pred(3, 4), pred(4,1), pred(4,3)]/firingMeanPre2(ind2);
        
        perpAct(i,:) = [act(1,2), act(1, 4), act(2, 1), act(2, 3), ...
            act(3,2), act(3, 4), act(4,1), act(4,3)]/firingMeanPre2(ind2);

        inLinePred(i,:) = [pred(1,1),pred(2,2),pred(3,3), pred(4,4)]/firingMeanPre2(ind2);
        resistPred(i,:) = [pred(1,3),pred(2,4), pred(3,1), pred(4,2)]/firingMeanPre2(ind2);

        inLineAct(i,:) = [act(1,1),act(2,2),act(3,3), act(4,4)]/firingMeanPre2(ind2);
        resistAct(i,:) = [act(1,3),act(2,4), act(3,1), act(4,2)]/firingMeanPre2(ind2);
        end
        
    elseif meanSubtract % or just subtract the mean FR prior to movement
        
        perpPred(i,:) = [pred(1,2), pred(1, 4), pred(2, 1), pred(2, 3),...
            pred(3,2), pred(3, 4), pred(4,1), pred(4,3)] - firingMeanPre2(ind2);
        
        perpAct(i,:) = [act(1,2), act(1, 4), act(2, 1), act(2, 3),...
            act(3,2), act(3, 4), act(4,1), act(4,3)]- firingMeanPre2(ind2);

        inLinePred(i,:) = [pred(1,1),pred(2,2),pred(3,3), pred(4,4)]- firingMeanPre2(ind2);
        resistPred(i,:) = [pred(1,3),pred(2,4), pred(3,1), pred(4,2)]- firingMeanPre2(ind2);

        inLineAct(i,:) = [act(1,1),act(2,2),act(3,3), act(4,4)]- firingMeanPre2(ind2);
        resistAct(i,:) = [act(1,3),act(2,4), act(3,1), act(4,2)]- firingMeanPre2(ind2);
    elseif actSubtract % or subtract out the active reach entirely (to see how well the bump predicts the residual)
        act =  act - repmat(squeeze(actualReachMatch'), [1, 4]);
        pred = pred - repmat(squeeze(actualReachMatch'), [1,4]);
        perpPred(i,:) = [pred(1,2), pred(1, 4), pred(2, 1), pred(2, 3),...
            pred(3,2), pred(3, 4), pred(4,1), pred(4,3)] ;
        
        perpAct(i,:) = [act(1,2), act(1, 4), act(2, 1), act(2, 3),...
            act(3,2), act(3, 4), act(4,1), act(4,3)];

        inLinePred(i,:) = [pred(1,1),pred(2,2),pred(3,3), pred(4,4)];
        resistPred(i,:) = [pred(1,3),pred(2,4), pred(3,1), pred(4,2)];

        inLineAct(i,:) = [act(1,1),act(2,2),act(3,3), act(4,4)];
        resistAct(i,:) = [act(1,3),act(2,4), act(3,1), act(4,2)];
        
    else
        perpPred(i,:) = [pred(1,2), pred(1, 4), pred(2, 1),...
            pred(2, 3), pred(3,2), pred(3, 4), pred(4,1), pred(4,3)];
        
        perpAct(i,:) = [act(1,2), act(1, 4), act(2, 1), act(2, 3),...
            act(3,2), act(3, 4), act(4,1), act(4,3)];

        inLinePred(i,:) = [pred(1,1),pred(2,2),pred(3,3), pred(4,4)];
        resistPred(i,:) = [pred(1,3),pred(2,4), pred(3,1), pred(4,2)];

        inLineAct(i,:) = [act(1,1),act(2,2),act(3,3), act(4,4)];
        resistAct(i,:) = [act(1,3),act(2,4), act(3,1), act(4,2)];
    end
    
    % Prep for plotting
    [~, maxBumpDir(i)] = max(unitBFR(ind2, :));
    
    if plotResponses
    act = [act, act(:,1)];
    pred = [pred, pred(:,1)];
    max1 = max([max([pred, act]),.001]);
    % Plot
    fh1 = figure('Visible', 'off');
    subplot(3, 3, 6)
    polarplot(theta, act(1,:)')
    hold on
    polarplot(theta, pred(1,:)')
    rlim([0, max1])
    
    subplot(3, 3, 2)
    polarplot(theta, act(2,:)')
    hold on
    polarplot(theta, pred(2,:)')
    rlim([0, max1])
    
    subplot(3,3, 4)
    polarplot(theta, act(3,:)')
    hold on
    polarplot(theta, pred(3,:)')
    rlim([0, max1])
    
    subplot(3,3, 8)
    polarplot(theta, act(4,:)')
    hold on
    polarplot(theta, pred(4,:)')
    rlim([0, max1])
    
    suptitle1(['Electrode ', num2str(unitG2(ind2,1)), ' Unit ', num2str(unitG2(ind2, 2))])
    
    subplot(3,3,9)
    hold on
    plot([-1, 1;1 -1])
    legend('Actual', 'Predicted')
    
    set(fh1, 'Renderer', 'Painters');
    save2pdf([savePath,strrep(title1, ' ', '_'), '_PredictedVsActualLM_', num2str(date), '.pdf'],fh1)
    saveas(fh1,[savePath, strrep(title1, ' ', '_'), '_PredictedVsActualLM_', num2str(date), '.png'])
    end

end
%%
goodScale = logical(goodScale);
if plotPerpFiring

        
    perpAct = perpAct(goodScale,:);
    inLineAct = inLineAct(goodScale,:);
    resistAct =resistAct(goodScale,:);
    perpPred = perpPred(goodScale,:);
    inLinePred= inLinePred(goodScale,:);
    resistPred = resistPred(goodScale,:);
    
    perpActVec = perpAct(:);
    inLineActVec = inLineAct(:);
    resistActVec = resistAct(:);
    perpPredVec = perpPred(:);
    inLinePredVec = inLinePred(:);
    resistPredVec = resistPred(:);
    temp = [perpPredVec; inLinePredVec;resistPredVec];
    temp = temp(temp~= Inf & temp~=-Inf);
    max1 = max(temp);
    min1 = min([temp;0]);

    figure
    scatter(perpPredVec, perpActVec)
    hold on
    scatter(inLinePredVec, inLineActVec)
    scatter(resistPredVec, resistActVec)
    legend('Perpendicular', 'Assistive', 'Resistive')
    lmTot = fitlm([perpPredVec; inLinePredVec;resistPredVec], [perpActVec; inLineActVec; resistActVec]);

    
    plot([min1, max1], [min1, max1])
    plot([min1, max1], [lmTot.Coefficients.Estimate(1) + lmTot.Coefficients.Estimate(2)*min1,...
        (lmTot.Coefficients.Estimate(2)*max1 + lmTot.Coefficients.Estimate(1))])
    title(['Predicted firing vs Actual firing Normalized: ', num2str(normalizeFR)])
    xlabel('Predicted Firing')
    ylabel('Actual Firing')
    xlim([min1, max1])
    ylim([min1, max1])
    figure
    lm1 = fitlm(perpPredVec, perpActVec);
    lm2 = fitlm(inLinePredVec, inLineActVec);
    lm3 = fitlm(resistPredVec, resistActVec);
    lmTot = fitlm([perpPredVec; inLinePredVec;resistPredVec],...
        [perpActVec; inLineActVec; resistActVec]);
    
    plot(lm1)
    hold on
    plot(lm2)
    plot(lm3)
    
    perpSlope = lm1.Coefficients.Estimate(2);
    assistSlope = lm2.Coefficients.Estimate(2);
    resistSlope = lm3.Coefficients.Estimate(2);
    
    perpCI = coefCI(lm1);
    assistCI = coefCI(lm2);
    resistCI = coefCI(lm3);
    figure
    errorbar([1,2,3], [perpSlope, assistSlope, resistSlope],...
        [perpSlope - perpCI(2,1), assistSlope- assistCI(2,1), resistSlope - resistCI(2,1)],...
        [perpSlope - perpCI(2,2), assistSlope- assistCI(2,2), resistSlope - resistCI(2,2)]);
    xlim([0, 4])
    xticks([1,2,3])
    xticklabels({'Perpendicular', 'Assistive', 'Resistive'})
    title(['Slope of the predicted/actual FR regression Normalized: ' num2str(normalizeFR)])
    ylabel('Regression slope (hz/hz)')
    r2Tot = lmTot.Rsquared.Adjusted;
    r2Perp = lm1.Rsquared.Adjusted;
    r2Assist = lm2.Rsquared.Adjusted;
    r2Resist = lm3.Rsquared.Adjusted;
end

