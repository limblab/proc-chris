function [processedTrial, neuronProcessed1] = compiledCOMoveAnalysis(td, params)
% 
%% Parameter defaults

    includeSpeedTerm = false;
    cutoff = pi/2; %cutoff for significant of sinusoidal tuning
    arrays= {'cuneate'}; %default arrays to look for
    windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
    windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
    distribution = 'poisson'; %what distribution to use in the GLM models
    train_new_model = true; %whether to train new models (can pass in old models in params struct to save time, or don't and it'll run but pass a warning
    neuronProcessed1 = []; %
    monkey  = td(1).monkey;
    %% Assign params
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    tdAct = td(strcmp({td.result},'R'));
    tdAct = tdAct(~isnan([tdAct.idx_movement_on]));
    tdAct = tdAct(isnan([tdAct.bumpDir]));
    tdAct = trimTD(tdAct, windowAct(1,:), windowAct(2,:));
    tdBump = td(~isnan([td.bumpDir]) & abs([td.bumpDir]) <361); 
    tdPas = trimTD(tdBump, windowPas(1,:), windowPas(2,:));
    
%% td preprocessing
    if(~isfield(td(1), 'idx_movement_on'))
        td = getMoveOnsetAndPeak(td);
    end
    if(tdAct(1).bin_size == .01)
        tdAct = binTD(tdAct,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end
    if(tdPas(1).bin_size == .01)
        tdPas = binTD(tdPas,5);
    else
        error('This function requires that the input TD be binned at 10 ms');
    end

    moveDirs = unique([td.target_direction]);
    moveDirs = moveDirs(~isnan(moveDirs));
    bumpDirs = unique([td.bumpDir]);
    bumpDirs = bumpDirs(~isnan(bumpDirs));
    meanBumpFR = zeros(length(moveDirs), length(bumpDirs), length(td(1).cuneate_unit_guide(:,1)));
    unitGuide = td(1).cuneate_unit_guide;
    
    moveWindow = {'idx_movement_on', 0; 'idx_movement_on', 50};
    
    tdMove1 = trimTD(td, moveWindow(1,:), moveWindow(2, :));
    tdMove = tdMove1(isnan([tdMove1.bumpDir]));
    tdBump = tdMove1(~isnan([tdMove1.bumpDir]));
    for i = 1:length(moveDirs)
        tdDir{i} = tdMove([tdMove.target_direction] == moveDirs(i));
        frDir = cat(3, tdDir{i}.cuneate_spikes)./tdDir{i}(1).bin_size;
        meanFRDir(i,:) = mean(mean(frDir,3));
        
    end
    for i=1:length(moveDirs)
        for j = 1:length(bumpDirs)
            tdBump1{i,j} = tdMove1([tdMove1.bumpDir] == bumpDirs(j) & [tdMove1.target_direction] == moveDirs(i));
            frDir = cat(3, tdBump1{i,j}.cuneate_spikes)./tdBump1{i,j}(1).bin_size;
            meanFRBump(i,j,:) = mean(mean(frDir,3));
            netFR(i, j, :) = squeeze(meanFRBump(i, j,:))' - meanFRDir(i,:);

        end
    end
    
    for i = 1:length(netFR(1,1,:))
        close all
        figure
        plot(netFR(:,:, i))
        xlabel('Movement Direction')
        legend({'Bump 1', 'Bump 2', 'Bump 3', 'Bump 4'});
        pause
    end

end

