close all
% path='/media/chris/HDD/Data/MonkeyData/LFADSData/MultiMonkey Stitching S1 CoBump';
% load([path, 'Han_20160415_td_peak.mat'])

factNum =[1,2];
numTrials = length(td);
rc.loadPosteriorMeans();
for j = 1:1
f1 = figure();
hold on
f2 = figure();
hold on
factorAll{j} = [];
condsAll{j} = [];
    
factors = rc.runs(j,1).posteriorMeans.factors;
conds = rc.runs(j,1).posteriorMeans.conditionIds;
for i = 1:numTrials

    f1;
    if conds(i) == 0
        plot(factors(factNum(1),:,i), factors(factNum(2),:,i),'r')
    elseif conds(i) ==1
        plot(factors(factNum(1),:,i), factors(factNum(2),:,i),'b')
    elseif conds(i) ==2
        plot(factors(factNum(1),:,i), factors(factNum(2),:,i),'k')
    else
        plot(factors(factNum(1),:,i), factors(factNum(2),:,i), 'g')
    end
    

    if j ==1
        title('Posterior Means for go cue aligned trials')
    elseif j == 2
        title('Posterior Means for movement onset aligned trials')
    elseif j ==3 
        title('Posterior Means for peak speed aligned trials')
    elseif j ==4
        title('Posterior Means for End Aligned Trials')

    end
    factorAll{j} = [factorAll{j};factors(1:2, :, i)'];
    condsAll{j} = [condsAll{j}; conds(i)*ones(length(factors(1,:,i)),1)];
end
    colors = [1,0,0;0,1,0,;0,0,1;0,0,0];
    [~,pcaFact{j}] = pca(factorAll{j}); 
    figure
    hold on
    scatter(pcaFact{j}(:, 1), pcaFact{j}(:,2), 1, colors(condsAll{j}+1,:))
    if j ==1
        title('PCA factors for go cue aligned trials')
    elseif j == 2
        title('PCA factors for movement onset aligned trials')
    elseif j ==3 
        title('PCA factors for peak speed aligned trials')
    elseif j ==4
        title('PCA factors for End Aligned Trials')

    end
end

%%
close all
% tdGoVel = cat(1, tdGo.vel);
% fitGoX = fitlm(factorAll{1}, tdGoVel(:,1))
% fitGoY = fitlm(factorAll{1}, tdGoVel(:,2))
% spikingGo = cat(1, tdGo.LeftS1_spikes);
% fitGoXNeurons = fitlm(spikingGo, tdGoVel(:,1))
% fitGoYNeurons = fitlm(spikingGo, tdGoVel(:,2))
% 
% tdMoveVel = cat(1, tdMove(1:numTrials).vel);
% fitMoveX = fitlm(factorAll{2}, tdMoveVel(:,1))
% fitMoveY = fitlm(factorAll{2}, tdMoveVel(:,2))

% 
% tdEndVel = cat(1, tdEnd(1:numTrials).vel);
% fitEndX = fitlm(factorAll{4}, tdEndVel(:,1))
% fitEndY = fitlm(factorAll{4}, tdEndVel(:,2))


tdPeak = td;
tdPeakVel = cat(1, tdPeak(1:numTrials).vel);
params.signals= 'area2_spikes';
tdPeakBinned = binTD(tdPeak, 5);
tdPeakPCA = getPCA(tdPeakBinned, params); 

tdBinnedVel = cat(1, tdPeakPCA.vel);
tdBinnedPCA = cat(1, tdPeakPCA.area2_pca);

fitPeakXPCA = fitlm(tdBinnedPCA, tdBinnedVel(:,1));
fitPeakYPCA = fitlm(tdBinnedPCA, tdBinnedVel(:,2));
figure
plot(fitPeakXPCA)
figure
plot(fitPeakYPCA)

fitPeakX = fitlm(factorAll{3}, tdPeakVel(:,1))
fitPeakY = fitlm(factorAll{3}, tdPeakVel(:,2))

figure
plot(fitPeakX)
figure
plot(fitPeakY)
%%

% Find total separability
    
factors = rc.runs(3,1).posteriorMeans.factors;
conds = rc.runs(3,1).posteriorMeans.conditionIds;
%%
signal = squeeze(mean(factors,2))';
conds = conds;
[train_idx,test_idx] = crossvalind('LeaveMOut',length(conds),floor(length(conds)/10));

% get model
mdl = fitcdiscr(signal(train_idx,:),conds(train_idx));

class = predict(mdl,signal(test_idx,:));
separability = sum(class == conds(test_idx))/sum(test_idx);

class_train = predict(mdl,signal(train_idx,:));
sep_train = sum(class_train == conds(train_idx))/sum(train_idx);
%%
bump_colors = linspecer(4);
act_dir_idx = conds+1;

w = mdl.Sigma\diff(mdl.Mu)';
signal_sep = signal*w;

% get basis vector orthogonal to w for plotting
null_sep = null(w');
signal_null_sep = signal*null_sep;
[~,signal_null_sep_scores] = pca(signal_null_sep);

figure
% plot for act/pas separability
hold all
scatter3(signal_sep(:,1),signal_sep(:,2),signal_sep(:,3),50,bump_colors(act_dir_idx,:),'filled')
ylim = get(gca,'ylim');
zlim = get(gca,'zlim');
plot3([0 0],ylim,[0 0],'--k','linewidth',2)
plot3([0 0],[0 0],zlim,'--k','linewidth',2)
set(gca,'box','off','tickdir','out')
view([0 0])
axis off