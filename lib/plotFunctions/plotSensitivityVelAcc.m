function [nNeg, nPos, nNoDif] = plotSensitivityVelAcc(neurons, params)
    path1 = 'D:\Figures\SensitivityChecks1\';
    tuningCondition = {'isSorted'};
    if nargin > 1, assignParams(who,params); end % overwrite parameters

    if iscell(tuningCondition)
        for i = 1:length(tuningCondition)
            if strcmp(tuningCondition{i}(1), '~')
                neurons = neurons(find(~neurons.(tuningCondition{i}(2:end))),:);
            else
                if ~contains(tuningCondition{i}, '|')
                    neurons = neurons(find(neurons.(tuningCondition{i})),:);
                else
                    conds = split(tuningCondition{i}, '|');
                    flag1 = neurons.(conds{1}) | neurons.(conds{2});
                    neurons = neurons(find(flag1),:);
                end
            end
        end
    else
        neurons = neurons(find(neurons.(tuningCondition)),:);
    end
    sDif = neurons.sDifVelAccBoot;
    
    
    sAct = neurons.sActVelAccBoot;
    sPas = neurons.sPasVelAccBoot;
    
    mSAct = squeeze(mean(sAct,2));
    mSPas = squeeze(mean(sPas,2));
    colors = linspecer(length(mSAct(1,:)));
    fh1 = figure;
    max1 =  max([max(max(mSAct)),max(max(mSPas))]);
    scatter(mSPas, mSAct, 32, 'filled')
    hold on
        
    nNeg = sum(quantile(sDif(:,:)', .025) > 0);
    nPos = sum(quantile(sDif(:,:)', .975) < 0);
    nNoDif = sum(quantile(sDif(:,:)', .025) < 0 & quantile(sDif(:,:)', 0.975)>0);
    
    n1 = neurons(1,:);

    plot([0, max1], [0, max1]) 
    title(['Sensitivity, VelAcc', n1.monkey])
    xlabel('Passive sensitivity')
    ylabel('Active sensitivity')
    legend('Sensitivity (all covariates)')
    window = neurons(1,:).actWindow{1};
    fname = strjoin([n1.monkey, window{1,1}, num2str(window{1,2}), window{2,1}, num2str(window{2,2}), 'VelAcc.png'], '');
    saveas(fh1, [path1,fname]);
end