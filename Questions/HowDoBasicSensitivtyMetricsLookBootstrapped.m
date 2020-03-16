% clear all
close all
clearvars -except td1 td2 td3 td4 td5
plotRasters = 1;
savePlots = false;
isMapped = false;
savePDF = false;
recompute = false;
smoothWidth = .02;
windowInds = true;
numBoots = 100;
savePath = 'C:\Users\wrest\Pictures\ActPasDomainComparison\';
% 
monkey1 = 'Butter';
date1 = '20190129';
task1 = 'CO';
num1 = 2;

monkey2 = 'Crackle';
date2 = '20190418';
task2 = 'CO';
num2 = 1;

monkey3 = 'Snap';
date3 = '20190829';
task3 = 'CO';
num3 = 2;

monkey4 = 'Han';
date4 = '20171122';
task4 = 'COactpas';
num4 = 1;

monkey5 = 'Duncan';
date5 = '20190710';
task5 = 'CObumpmove';
num5 = 1;

sActSpindleComb =[];
sPasSpindleComb = [];

sActNSpindleComb =[];
sPasNSpindleComb =[];

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;
monkeyArray = {monkey1, date1, task1, num1;...
               monkey2, date2, task2, num2;...
               monkey3, date3, task3, num3;...
               monkey4, date4, task4, num4;...
               monkey5, date5, task5, num5};

cnSAct = [];
cnSPas = [];
if recompute
for mon = 1:5
    monkey = monkeyArray{mon, 1};
    date = monkeyArray{mon, 2};
    task = monkeyArray{mon, 3};
    num = monkeyArray{mon, 4};
    
    mappingLog = getSensoryMappings(monkey);

    switch mon
        case 1
            array = 'cuneate';
            if ~exist('td1')
                td1 = getTD(monkey, date, task,num);
                if td1(1).bin_size ==.001
                    td1 = binTD(td1, 10);
                end
                td1 = getSpeed(td1);
                td1 = smoothSignals(td1, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td1 = getNorm(td1,struct('signals','vel','field_extra','speed'));
                td1 = getMoveOnsetAndPeak(td1,params);
                td1 = td1(~isnan([td1.idx_movement_on]));

                
            end
            td1 = addSensoryMappingToGuide(td1);
            td1 = removeBadNeurons(td1, struct('remove_unsorted', false));
            td1 = removeUnsorted(td1);
            td1 = removeGracileTD(td1);
            td1 = removeNeuronsBySensoryMap(td1, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
            td1 = removeNeuronsByNeuronStruct(td1, struct('flags', {{'~handPSTHMan'}}));
            td = td1;
            mappingGuide{mon} = td(1).cuneate_mapping_guide;

        case 2
            array = 'cuneate';

            if ~exist('td2')
                td2 = getTD(monkey, date, task,num);
                if td2(1).bin_size ==.001
                    td2 = binTD(td2, 10);
                end
                td2 = getSpeed(td2);
                td2 = smoothSignals(td2, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td2 = getNorm(td2,struct('signals','vel','field_extra','speed'));
                td2 = getMoveOnsetAndPeak(td2,params);
                td2 = td2(~isnan([td2.idx_movement_on]));

            end
            td2 = addSensoryMappingToGuide(td2);

            td2 = removeBadNeurons(td2, struct('remove_unsorted', false));
            td2 = removeUnsorted(td2);
            td2 = removeGracileTD(td2);
            td2 = removeNeuronsBySensoryMap(td2, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
            td2 = removeNeuronsByNeuronStruct(td2, struct('flags', {{'~handPSTHMan'}}));

            td = td2;
            mappingGuide{mon} = td(1).cuneate_mapping_guide;

        case 3
            array = 'cuneate';

            if ~exist('td3')
                td3 = getTD(monkey, date, task,num);
                for i = 1:length(td3)
                    td3(i).opensim = [];
                end
                if td3(1).bin_size ==.001
                    td3 = binTD(td3, 10);
                end
                td3 = getSpeed(td3);
                td3 = smoothSignals(td3, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td3 = getNorm(td3,struct('signals','vel','field_extra','speed'));
                td3 = getMoveOnsetAndPeak(td3,params);
                td3 = td3(~isnan([td3.idx_movement_on]));
    

            end
%             td3 = removeVisually(td3);
            td3 = addSensoryMappingToGuide(td3);

            td3 = removeBadNeurons(td3, struct('remove_unsorted', false));
            td3 = removeUnsorted(td3);
            td3 = removeGracileTD(td3);
            td3 = removeNeuronsBySensoryMap(td3, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
            td3 = removeNeuronsByNeuronStruct(td3, struct('flags', {{'~handPSTHMan'}}));

            td = td3;
            mappingGuide{mon} = td(1).cuneate_mapping_guide;

        case 4
            array = 'LeftS1Area2';

            if ~exist('td4')
                td4 = getTD(monkey, date, task,num);
                if td4(1).bin_size ==.001
                    td4 = binTD(td4, 10);
                end
                td4 = getSpeed(td4);
                td4 = smoothSignals(td4, struct('signals', ['LeftS1Area2_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td4 = getNorm(td4,struct('signals','vel','field_extra','speed'));
                td4 = getMoveOnsetAndPeak(td4,params);

            end
            td4 = removeUnsorted(td4);
            td = td4;
            
        case 5
            array = 'leftS1';

            if ~exist('td5')
                td5 = getTD(monkey, date, task,num);
                if td5(1).bin_size ==.001
                    td5 = binTD(td5, 10);
                end
                td5 = getSpeed(td5);
                td5 = smoothSignals(td5, struct('signals', ['leftS1_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td5 = getNorm(td5,struct('signals','vel','field_extra','speed'));
                td5 = getMoveOnsetAndPeak(td5,params);
                td5(~isnan([td5.idx_bumpTime]) & [td5.idx_bumpTime]>[td5.idx_goCueTime]) =[];
            end
            td5 = removeUnsorted(td5);
            td5(isnan([td5.idx_movement_on]))= [];
            td = td5;
            
    end
    if windowInds
        suffix = ['WindowedMatch', monkey];
    else
        suffix = ['FullData', monkey];
    end
    


        
    guide = td(1).([array, '_unit_guide']);
    td([td.idx_peak_speed]< [td.idx_movement_on])=[];
    tdAct1 = trimTD(td, {'idx_movement_on',0}, {'idx_movement_on', 13});
    tdPas1 = td(~isnan([td.idx_bumpTime]));
    tdPas1 = trimTD(tdPas1, 'idx_bumpTime', {'idx_bumpTime', 13});
    tmpVec = 1:length(tdAct1);
    tmpVec2 = 1:length(tdPas1);
    bootMat = tmpVec(randi(length(tdAct1), numBoots, length(tdAct1)));
    bootMatP = tmpVec2(randi(length(tdPas1), numBoots, length(tdPas1)));
    
    sAct = zeros(length(guide),numBoots);
    sPas = zeros(length(guide),numBoots); 
    
    
    for boot = 1:numBoots
        disp(['Bootstrap number: ', num2str(boot)])
        tdAct = tdAct1(bootMat(boot,:));
        tdPas = tdPas1(bootMatP(boot,:));
    if mon ~=1
        tdAct(~isnan([tdAct.bumpDir]))=[];
    end
    
    
    dirsM = unique([td.target_direction]);
    dirsM(isnan(dirsM)) = [];
    dirsM(mod(dirsM, pi/4) ~=0) = [];
    
    dirsB = unique([td.bumpDir]);
    dirsB(isnan(dirsB)) = [];
    dirsB(mod(dirsB, 45) ~=0) = [];
           
    actFR = cat(1, tdAct.([array, '_spikes']));
    pasFR = cat(1, tdPas.([array, '_spikes']));

    velAct = cat(1,tdAct.vel);
    velPas = cat(1, tdPas.vel);
%     
%     speedAct = cat(2,tdAct.speed);
%     speedPas = cat(2,tdPas.speed);
    
    if windowInds
    [keepIndsAct, keepIndsPas] = getKeepInds(velAct, velPas);
    
%     speedAct = speedAct(keepIndsAct);
    velAct = velAct(keepIndsAct,:);
    actFR  = actFR(keepIndsAct,:);
    
%     speedPas = speedPas(keepIndsPas);
    velPas = velPas(keepIndsPas,:);
    pasFR =  pasFR(keepIndsPas,:);
    end


    if ~isempty(mappingLog)
    if ~contains(mappingLog(1).date, '/')
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'yyyyMMdd')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    else
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'MM/dd/yyyy')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    end

 
    mapped = false(length(guide(:,1)),1);
    spindle = false(length(guide(:,1)),1);
    neurons{mon} = [];
    for i = 1:length(guide(:,1))
        clear neuron
        neuron.chan = guide(i,1);
        neuron.unitNum = guide(i,2);
        neuron.monkey = {monkey};
        neuron.date = date;
        unit = find([ml.elec] == guide(i,1));
        
        lmAct = fitlm(velAct, actFR(:,i));
        sAct(i,boot) = norm(lmAct.Coefficients.Estimate(2:3));
        lmPas = fitlm(velPas, pasFR(:,i));
        sPas(i, boot) = norm(lmPas.Coefficients.Estimate(2:3));
        sActPasDif{mon}(boot,i) = sAct(i,boot) - sPas(i,boot);
        neuron.sAct = sAct(i, boot);
        neuron.sPas = sPas(i, boot);
        mapping = td(1).([array,'_naming']);
        neuron.mapName = mapping(find(mapping(:,1) == neuron.chan), 2);

        neuron = struct2table(neuron);
        neuron = insertMappingIntoNeuron(neuron, mappingLog);
        neurons{mon} = [neurons{mon};neuron];
        mappingGuide{mon}.sAct(i,boot) = sAct(i,boot);
        mappingGuide{mon}.sPas(i,boot) = sPas(i,boot);
        mappingGuide{mon}.sActPasDif(i, boot) = sActPasDif{mon}(boot,i); 
        if ~isempty(unit)
            mapped(i) = true;

            if any(ml(unit).spindle)
                spindle(i) = true;
            else
                spindle(i) = false;
            end
        else
            mapped(i) = false;
            spindle(i) = false;
        end
%         f1 = figure;
% 
%         plot(lmAct)
%         hold on
%         plot(lmPas)
%         title(['Elec ', num2str(guide(i,1)),'U',num2str(guide(i,2))])
%         saveas(f1, ['C:\Users\wrest\Pictures\ScatchFolder\', monkey, 'Elec', num2str(guide(i,1)),'U',num2str(guide(i,2)), '.png']);

    end
    if isMapped
        mGuide{mon} = guide(mapped);
        sAct(~mapped,:) = [];
        sPas(~mapped,:) = [];
        spindle = spindle(mapped);
    else
        mGuide{mon} = guide;
    end
    sensAct{mon}= sAct;
    sensPas{mon} = sPas;
%     actPasDif{mon} = 
    
    cnSAct = [cnSAct; sAct];
    cnSPas = [cnSPas; sPas];
    
    lmAll{mon} = fitlm(sAct(:,boot), sPas(:,boot), 'Intercept', false);
    slopeAll(mon) = lmAll{mon}.Coefficients.Estimate;
    slopeCI(mon,:) = coefCI(lmAll{mon});
    spindleLM{mon} = fitlm(sAct(spindle), sPas(spindle), 'Intercept', false);
    nSpindleLM{mon}= fitlm(sAct(~spindle), sPas(~spindle), 'Intercept', false);
    
    sActSpindleComb = [sActSpindleComb; sAct(spindle)];
    sPasSpindleComb = [sPasSpindleComb; sPas(spindle)];
    sActNSpindleComb = [sActNSpindleComb; sAct(~spindle)];
    sPasNSpindleComb = [sPasNSpindleComb; sPas(~spindle)];
    
    
    spindleSens(mon,1) = spindleLM{mon}.Coefficients.Estimate(1);
    tmp = coefCI(spindleLM{mon});
    spindleSens(mon,2:3) = tmp;
    nSpindleSens(mon,1) = nSpindleLM{mon}.Coefficients.Estimate(1);
    tmp = coefCI(nSpindleLM{mon});
    nSpindleSens(mon,2:3) = tmp;
    
    max1 = max([sAct; sPas]);
%     
%     figure
%     scatter(sAct(spindle), sPas(spindle),'r', 'filled')
%     hold on
%     scatter(sAct(~spindle'), sPas(~spindle),'b', 'filled')
%     plot([0, max1], [0, max1*slopeAll(mon)], 'k-')
%     legend({'Spindles', 'Non-spindles'})
%     plot([0, max1], [0,max1])
%     xlabel('Active sensitivity')
%     ylabel('Passive sensitivity')
%     title(['Act vs pas sensitivity',suffix])
%     for i = 1:length(sAct)
%         dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
%         text(sAct(i)+ dx, sPas(i) +dy, num2str(mGuide{mon}(i, 1)));
%     end
%     set(gca,'TickDir','out', 'box', 'off')
   if savePlots

    saveas(gca, [savePath, 'ActPasSensitivity', suffix, '.pdf']);
    saveas(gca, [savePath, 'ActPasSensitivity' ,suffix, '.png']);
   end
    else
        
    sAct = zeros(length(guide(:,1)),1);
    sPas = zeros(length(guide(:,1)),1);   
    for i = 1:length(guide(:,1))
        lmAct = fitlm(velAct, actFR(:,i));
        sAct(i) = norm(lmAct.Coefficients.Estimate(2:3));
        lmPas = fitlm(velPas, pasFR(:,i));
        sPas(i) = norm(lmPas.Coefficients.Estimate(2:3));
    end
    max1 = max([sAct; sPas]);
    
    linearModel1 = fitlm(sAct, sPas,'Intercept',false)
    meanLin(mon) = linearModel1.Coefficients.Estimate;
    lmCI(mon,:) = coefCI(linearModel1);
    
    sensAct{mon}(boot,:) = sAct;
    sensPas{mon}(boot,:) = sPas;
    sensActPasDif{mon}(boot,:) = sAct-sPas;
    
%     figure
%     scatter(sAct, sPas,'r', 'filled')
%     hold on
%     plot([0, max1], [0,max1])
%     plot([0, max1], [0, max1*meanLin(mon)])
%     xlabel('Active sensitivity')
%     ylabel('Passive sensitivity')
%     title(['Act vs pas sensitivity',suffix])
%     for i = 1:length(sAct)
%         dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
%         text(sAct(i)+ dx, sPas(i) +dy, num2str(guide(i)));
%     end
    set(gca,'TickDir','out', 'box', 'off')
   if savePlots

    saveas(gca, [savePath, 'ActPasSensitivity', suffix, '.pdf']);
    saveas(gca, [savePath, 'ActPasSensitivity' ,suffix, '.png']);
   end
    end

    end
end
save('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Compiled\Sensitivity\CompiledSensitivity.mat', 'sActSpindleComb', 'sPasSpindleComb',...
    'sActNSpindleComb','sActPasDif', 'sPasNSpindleComb', 'sensAct','sensPas',...
    'neurons','mappingGuide');
else
    load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Compiled\Sensitivity\CompiledSensitivity.mat')
end
%%
close all
colors = linspecer(3);
figure
for i = 1:5 
    if i~=4 & i~=5
    mappingGuideFilt{i} = mappingGuide{i}(logical(mappingGuide{i}.sameDayMap),:);
    mappingGuideFilt{i}(mappingGuideFilt{i}.distal | mappingGuideFilt{i}.handUnit,:) = [];
    mappingGuideProp{i} = mappingGuideFilt{i}(logical(mappingGuideFilt{i}.isProprioceptive),:);
    mappingGuideCut{i} = mappingGuideFilt{i}(logical(mappingGuideFilt{i}.cutaneous),:);
    maxSensTemp(i) = max(mean(mappingGuideFilt{i}.sAct,2));
    maxSensTemp2(i) = max(mean(mappingGuideFilt{i}.sPas,2));
    
    sActProp = mean(mappingGuideProp{i}.sAct,2);
    sPasProp = mean(mappingGuideProp{i}.sPas,2);
    sActCut = mean(mappingGuideCut{i}.sAct,2);
    sPasCut = mean(mappingGuideCut{i}.sPas,2);
%     keyboard
    sActPasDifProp = sort(mappingGuideProp{i}.sActPasDif,2);
    sActPasDifCut = sort(mappingGuideCut{i}.sActPasDif,2);
    
    propAct(i) = sum(sActPasDifProp(:,5)>0);
    propPas(i) = sum(sActPasDifProp(:,95)<0);
    propNoDif(i) = sum(sActPasDifProp(:,5)<0 & sActPasDifProp(:,95) >0);
    
    cutAct(i) = sum(sActPasDifCut(:,5) >0);
    cutPas(i) = sum(sActPasDifCut(:,95)<0);
    cutNoDif(i) = sum(sActPasDifCut(:,5)<0 & sActPasDifCut(:,95) >0);
    scatter(sPasProp, sActProp, 32, colors(i,:),  'o')
    hold on
    scatter(sPasCut, sActCut, 32, colors(i,:), 'filled', 'o')
    else
    actTemp = sensAct{i}';
    pasTemp = sensPas{i}';
    actMinPas = actTemp-pasTemp;
    sActMinPas = sort(actMinPas,2);
    s1Act(i-3) = sum(sActMinPas(:,5) >0);
    s1Pas(i-3) = sum(sActMinPas(:,95) <0);
    s1NoDif(i-3) = sum(sActMinPas(:,5) <0 & sActMinPas(:,95) >0);
%     keyboard
    end

end
% keyboard
cutAct = sum(cutAct);
cutPas = sum(cutPas);
cutNoDif = sum(cutNoDif);

propAct = sum(propAct);
propPas = sum(propPas);
propNoDif = sum(propNoDif);


maxVal = max([maxSensTemp, maxSensTemp2]);
plot([0,maxVal], [0, maxVal])
legend({'Butter', 'Crackle', 'Snap'})
set(gca,'TickDir','out', 'box', 'off')

%%
actCount = 0;
pasCount = 0;
noDif = 0;
ciAct = [];
ciPas = [];
close all
for i = 1:3
%     keyboard
    for j = 1:length(sActPasDif{i}(1,:))
    ciAct = [ciAct, range(sensAct{i}(j,:))/mean(sensAct{i}(j,:))];
    ciPas = [ciPas, range(sensPas{i}(j,:))/mean(sensPas{i}(j,:))];
    sorted1 = sort(sActPasDif{i}(:,j));
    if sorted1(5)> 0
        actCount =  actCount +1;
    elseif sorted1(end-5) <0 
        pasCount = pasCount +1;
    else
        noDif = noDif +1;
    end
    max1 = max(abs(sActPasDif{i}(:,j)));
%         figure
%     histogram(sActPasDif{i}(:,j))
%     xlim([-1*max1, max1])
    end
end
figure
histogram(ciAct)
hold on
histogram(ciPas)
legend('Active', 'Passive')
%%