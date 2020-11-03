function [nNeg, nPos, nNoDif] = plotSensitivityWindows(neurons, params)
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
    sDif = neurons.sDifBootWin;
    
    
    sAct = neurons.sActBootWin;
    sPas = neurons.sPasBootWin;
    
    mSAct = squeeze(mean(sAct,2));
    mSPas = squeeze(mean(sPas,2));
    colors = linspecer(length(mSAct(1,:)));
    figure;
    max1 =  max([max(max(mSAct)),max(max(mSPas))]);
    for j = 1:length(colors(:,1))
        scatter(mSAct(:,j), mSPas(:,j), 32,colors(j,:), 'filled')
        hold on
        
        nNeg(j) = sum(quantile(sDif(:,:,j)', .025) > 0);
        nPos(j) = sum(quantile(sDif(:,:,j)', .975) < 0);
        nNoDif(j) = sum(quantile(sDif(:,:,j)', .025) < 0 & quantile(sDif(:,:,j)', 0.975)>0);
        
    end
    plot([0, max1], [0, max1]) 
    title('Sensitivity by window')
    xlabel('Active sensitivity')
    ylabel('Passive sensitivity')
    legend('0 to 130', '130 to 230', '230 to 330', '330 to 430')
    
    fh1 = figure;
    plot(nNeg, 'LineWidth',4)
    hold on
    plot(nPos, 'LineWidth',4)
    plot(nNoDif, 'LineWidth',4)
    xlabel('Window used')
    ylabel('# of neurons')
    title('Effect of window on significantly sensitive')
    legend('Actively tuned', 'Passively Tuned', 'No difference')
    
    n1 = neurons(1,:);
    window = neurons(1,:).actWindow{1};
    fname = strjoin([n1.monkey, window{1,1}, num2str(window{1,2}), window{2,1}, num2str(window{2,2}), 'Windows.png'], '_');
    saveas(fh1, [path1,fname]);
    
end