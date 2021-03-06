function [nNeg, nPos, nNoDif, proj1, statTab] = plotSensitivity(neurons, params)
    path1 = 'D:\Figures\SensitivityChecks1\';
    tuningCondition = {'isSorted'};
    plotUnitNum =false;
    useWindowed = true;
    useMins = false;
    minVal = 2;
    if nargin > 1, assignParams(who,params); end % overwrite parameters

     if iscell(tuningCondition)
        for i = 1:length(tuningCondition)
            if strcmp(tuningCondition{i}(1), '~')
                neurons = neurons(find(~neurons.(tuningCondition{i}(2:end))),:);
            else
                if contains(tuningCondition{i}, '|')
                    conds = split(tuningCondition{i}, '|');
                    flag1 = neurons.(conds{1}) | neurons.(conds{2});
                    neurons = neurons(find(flag1),:);
                    
                else
                    if length(tuningCondition{i}) >8 & strcmp(tuningCondition{i}(1:8), 'daysDiff')
                        dayCutoff = str2num(tuningCondition{i}(9:end));
                        flag1 = abs(neurons.daysDiff)<dayCutoff;
                        neurons =neurons(find(flag1),:);
                    else
                        neurons = neurons(find(neurons.(tuningCondition{i})),:);
                    end
                end
            end
            
        end
    else
        neurons = neurons(find(neurons.(tuningCondition)),:);
     end
    if useWindowed
        sDif = neurons.sDifBoot;
    else
        sDif = neurons.sDifBootNoWin;
    end
    
    monkey = strjoin(unique(neurons.monkey));
    monks = unique(neurons.monkey);
    
    fh1 = figure;
    colors = linspecer(length(monks));
    max1 = 0;
    for mon = 1:length(monks)
        neuronsM = neurons(strcmp(neurons.monkey, monks(mon)),:);
        if useWindowed
            sAct = neuronsM.sActBoot;
            sPas = neuronsM.sPasBoot;
        else
             sAct = neuronsM.sActBootNoWin;
             sPas = neuronsM.sPasBootNoWin;
        end

        mSAct = squeeze(mean(sAct,2));
        mSPas = squeeze(mean(sPas,2));
        if useMins
            minFlag = mSAct<minVal & mSPas<minVal;
            mSAct(minFlag) =[];
            mSPas(minFlag) = [];
        end
        max1 =  max([max(max(mSAct)),max(max(mSPas)), max1]);
        scatter(mSPas, mSAct, 32 ,  colors(mon,:),   'filled')
    hold on
    end
    if useMins
        if useWindowed
            sAct = neurons.sActBoot;
            sPas = neurons.sPasBoot;
        else
             sAct = neurons.sActBootNoWin;
             sPas = neurons.sPasBootNoWin;
        end
        mSAct = squeeze(mean(sAct,2));
        mSPas = squeeze(mean(sPas,2));
        minFlag1 = mSAct<minVal & mSPas<minVal;
        sDif(minFlag1,:) =[];
    end
    nNeg = sum(quantile(sDif(:,:)', .025) > 0);
    nPos = sum(quantile(sDif(:,:)', .975) < 0);
    nNoDif = sum(quantile(sDif(:,:)', .025) < 0 & quantile(sDif(:,:)', 0.975)>0);
    
    negFlag = quantile(sDif(:,:)', .025) > 0;
    posFlag = quantile(sDif(:,:)', .975) < 0;
    noDifFlag = quantile(sDif(:,:)', .025) < 0 & quantile(sDif(:,:)', 0.975)>0;
    
    
    statTab = table(negFlag', posFlag', noDifFlag', 'VariableNames', {'Potentiated', 'Attenuated', 'NoDif'});

    n1 = neurons(1,:);
    if useWindowed
        sAct = neurons.sActBoot;
        sPas = neurons.sPasBoot;
    else
        sAct = neurons.sActBootNoWin;
        sPas = neurons.sPasBootNoWin;
    end
    mSAct = squeeze(mean(sAct,2));
    mSPas = squeeze(mean(sPas,2));
    if useMins
        minFlag = mSAct<minVal & mSPas<minVal;
        mSAct(minFlag) =[];
        mSPas(minFlag) = [];
    end
    plot([0, max1], [0, max1], 'k--')
    set(gca,'TickDir','out', 'box', 'off')

    title(['Sensitivity, Vel ', monkey])
    xlabel('Passive sensitivity')
    ylabel('Active sensitivity')
    axis square
    
    legend(monks)
    window = neurons(1,:).actWindow{1};
    if plotUnitNum
        for i = 1:height(neurons)
            dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
            text(mSPas(i,:) + dx, mSAct(i,:) + dy, num2str(neurons.chan(i)));
        end
    end
    
    fname = strjoin([n1.monkey, window{1,1}, num2str(window{1,2}), window{2,1}, num2str(window{2,2}), 'Vel.png'], '');
    saveas(fh1, [path1,fname]);
    
    figure
    vec = [-1/sqrt(2), 1/sqrt(2)];
    mat1 = [mSPas,mSAct];
    proj1 = vec*mat1'; 
    histogram(proj1, 15)
    xlabel('Attenuated <---   ---> Potentiated')
    ylabel('# of units')
    title(strjoin(['Histogram of Vel Sensitivity Changes ', monks', ' ', window{1,1}, num2str(window{1,2}), window{2,1}, num2str(window{2,2})], ''))
    set(gca,'TickDir','out', 'box', 'off')

end