close all
clearvars -except td
snapDate = '20190829';
monkey = 'Snap';
date = snapDate;
number =2;
type = 'RefFrameLassoMuscleEnc';
mapping = getSensoryMappings('Snap');
if exist('td')~=1
    td = getTD(monkey, date, 'CO',number); 
end
td = removeUnsorted(td);
neurons1 = loadAnalysis(td, type);
% clear neurons1
if ~exist('neurons1')
    neurons1 = doOpensimLassoEncoding(td);
end
neurons = insertMappingsIntoNeuronStruct(neurons1, mapping);
%% Compare hand position encoding vs joint angle encoding
for  i =1:height(neurons)
    nrn = neurons(i,:);
    fh1 = figure
    subplot(2,1,1)
    plot(nrn.fitInfo(1,1).MSE)
    hold on
    xlabel('Lambda Run')
    ylabel('MSE')
    plot([nrn.fitInfo.IndexMinMSE, nrn.fitInfo.IndexMinMSE], [min(nrn.fitInfo.MSE), max(nrn.fitInfo.MSE)], 'r-')
    plot([nrn.fitInfo.Index1SE, nrn.fitInfo.Index1SE], [min(nrn.fitInfo.MSE), max(nrn.fitInfo.MSE)], 'b--')
    
    
    subplot(2,1,2)
    plot(neurons(i,:).fitInfo(1,1).DF)
    hold on
    ylabel('# of Conserved Input')
    xlabel('Lambda Run')
    plot([nrn.fitInfo.IndexMinMSE, nrn.fitInfo.IndexMinMSE], [0, 39], 'r-')
    plot([nrn.fitInfo.Index1SE, nrn.fitInfo.Index1SE], [0, 39], 'b--')
    path   = getPathFromTD(td);
    figName = [path, 'plotting\LassoPlots\LassoLMElec', num2str(neurons(i,:).chan), 'ID', num2str(neurons(i,:).ID),'.png'];
    suptitle(['Elec ', num2str(neurons(i,:).chan), ' ID ', num2str(neurons(i,:).ID)])
    saveas(fh1, figName);
end