close all
clearvars -except td
snapDate = '20190829';
monkey = 'Snap';
date = snapDate;
number =2;
type = 'RefFrameEnc';
mapping = getSensoryMappings('Snap');
if exist('td')~=1
    td = getTD(monkey, date, 'CO',number); 
end
td = removeUnsorted(td);
neurons1 = loadAnalysis(td, type);
% clear neurons1
if ~exist('neurons1')
    neurons1 = doOpensimEncoding(td);
end
neuronsMean = getMeanEncoding(neurons1);
neurons = insertMappingsIntoNeuronStruct(neuronsMean, mapping);
%% Compare hand position encoding vs joint angle encoding
neuronsFilt = neurons([neurons.isSpindle] ~=0,:);
neuronsCut = neurons([neurons.cutaneous] == 1 & [neurons.isCuneate]==1,:);
close all
comps = {'pos', 'jointAng';...
         'pos', 'muscleLen';...
         'vel', 'jointVel';...
         'vel', 'muscleVel';...
         'hand', 'joint';...
         'hand', 'muscle';
         'joint', 'muscle';...
         'hand', 'handElb';...
         'muscle', 'handElb'};
for i = 1:length(comps(:,1))
    figure
    scatter(neuronsFilt.(comps{i,1}), neuronsFilt.(comps{i,2}), 'b' ,'filled')
    hold on
    scatter(neuronsCut.(comps{i,1}), neuronsCut.(comps{i,2}), 'r', 'filled')
    plot([0,1], [0,1], 'k--')
    title([comps{i,1},' Enc vs ', comps{i,2},' Enc'])
    xlabel([comps{i,1},' R2'])
    ylabel([comps{i,2}, ' R2'])
    set(gca,'TickDir','out', 'box', 'off')
    ylim([0,1])
    xlim([-.3,1])
%     xticklabels({'-0.3','','','','','','','','','','1.0'})
%     yticklabels({'0','','','','','','','','','','1.0'})
    legend('Spindles', 'Cut', 'Unit')
end
%%
musMinHand = neuronsFilt.muscle - neuronsFilt.hand;
musMinJoint = neuronsFilt.muscle -neuronsFilt.joint;

mean(musMinHand)
mean(musMinJoint)

[a1, a2] = ttest(musMinHand)
[b1, b2] = ttest(musMinJoint)
%%
figure 
histogram(musMinHand, -.45:.1:.45)
xlabel('muscle minus hand')
    set(gca,'TickDir','out', 'box', 'off')


figure
histogram(musMinJoint, -.45:.1:.45)
xlabel('muscle minus joint')
    set(gca,'TickDir','out', 'box', 'off')

%% Compare muscle vel encoding to power law transformed muscle vel encoding

fieldNames = neuronsFilt.Properties.VariableNames;
isOSpow = zeros(length(fieldNames), 1);
powVar = [];
for i= 1:length(fieldNames)
    field = fieldNames{i};
    if length(field)>8 & strcmp(field(1:7), 'opensim')
        isOSpow(i) = true;
        powVar(end+1) = str2num(replace(field(9:end),'_','.'));
    end
end
osPowFields = fieldNames(logical(isOSpow));
pows = neuronsFilt(:,osPowFields);
powsArr = table2array(pows);
goodPows = powsArr(max(powsArr')>.2,:);
[~, mInd] = max(goodPows');
bestPow = powVar(mInd);
figure
histogram(bestPow,21)
figure

plot(powVar, powsArr')
