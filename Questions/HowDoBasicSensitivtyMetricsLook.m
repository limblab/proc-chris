% clear all
close all
clearvars -except td1 td2 td3 td4 td5
plotRasters = 1;
savePlots = false;
isMapped = false;
savePDF = false;
smoothWidth = .02;
windowInds = true;
savePath = 'C:\Users\wrest\Pictures\ActPasDomainComparison\';

monkey1 = 'Butter'; date1 = '20190129'; task1 = 'CO'; num1 = 2;

monkey2 = 'Snap'; date2 = '20190829'; task2 = 'CO'; num2 = 2;

monkey3 = 'Crackle'; date3 = '20190418'; task3 = 'CO'; num3 = 1;

monkey4 = 'Han'; date4 = '20171122'; task4 = 'COactpas'; num4 = 1;

monkey5 = 'Duncan'; date5 = '20190710'; task5 = 'CObumpmove'; num5 = 1;

monkey6 = 'Butter'; date6 = '20180607'; task6 = 'CO'; num6 = 1;

monkey7 = 'Crackle'; date7 = '20190327'; task7 = 'CO'; num7 = 1;

monkey8 = 'Crackle'; date8 = '20190213'; task8 = 'CO'; num8 = 1;

monkey9 = 'Snap'; date9 = '20190806'; task9 = 'CO'; num9 = 1;


monkeyArray = {monkey1, date1, task1, num1;...
               monkey2, date2, task2, num2;...
               monkey3, date3, task3, num3;...
               monkey4, date4, task4, num4;...
               monkey5, date5, task5, num5;...
               monkey6, date6, task6, num6;...
               monkey7, date7, task7, num7;...
               monkey8, date8, task8, num8;...
               monkey9, date9, task9, num9};



sActSpindleComb =[];
sPasSpindleComb = [];

sActNSpindleComb =[];
sPasNSpindleComb =[];

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .6;


cnSAct = [];
cnSPas = [];

windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

neuronsB = getNeurons('Butter', date1,'CObump','cuneate',[windowAct; windowPas]);
neuronsS = getNeurons('Snap', date2, 'CObump','cuneate',[windowAct; windowPas]);
neuronsC = getNeurons('Crackle', date3, 'CObump','cuneate',[windowAct; windowPas]);
neuronsH = getNeurons('Han', date4,'COactpas', 'LeftS1Area2',[windowAct; windowPas]);
neuronsD = getNeurons('Duncan', date5,'CObump','leftS1', [windowAct;windowPas]);

neuronsB2 = getNeurons('Butter', '20180607','CObump', 'cuneate', [windowAct;windowPas]);

neuronsS2 = getNeurons('Snap', '20190806', 'CObump','cuneate',[windowAct; windowPas]);

neuronsC2 = getNeurons('Crackle', '20190327', 'CObump','cuneate',[windowAct; windowPas]);
neuronsC3 = getNeurons('Crackle', '20190213', 'CObump','cuneate',[windowAct; windowPas]);



%% Split based on tuning curve
close all
vecStr = 'bimodProjMan';

cutoffMan = .93;
cutoffMean = .955;

neuronsS.handPSTHMan = [neuronsS.bimodProjMan] < cutoffMan;
neuronsB.handPSTHMan = [neuronsB.bimodProjMan] < cutoffMan;
neuronsC.handPSTHMan = [neuronsC.bimodProjMan] < cutoffMan;

neuronsS.handPSTHMean = [neuronsS.bimodProjMean] < cutoffMean;
neuronsB.handPSTHMean = [neuronsB.bimodProjMean] < cutoffMean;
neuronsC.handPSTHMean = [neuronsC.bimodProjMean] < cutoffMean;

neuronsCombined = [neuronsB; neuronsS; neuronsC];
neuronsS1 = [neuronsD;neuronsH];

for mon = 2
    
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
                
%             td1 = removeBadNeurons(td1, struct('remove_unsorted', false));
%             td1 = removeUnsorted(td1);
%             td1 = removeGracileTD(td1);
%             td1 = removeNeuronsBySensoryMap(td1, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
%             td1 = removeNeuronsByNeuronStruct(td1, struct('flags', {{'~handPSTHMan'}}));
            td = td1;
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

%             td2 = removeBadNeurons(td2, struct('remove_unsorted', false));
%             td2 = removeUnsorted(td2);
%             td2 = removeGracileTD(td2);
%             td2 = removeNeuronsBySensoryMap(td2, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
%             td2 = removeNeuronsByNeuronStruct(td2, struct('flags', {{'~handPSTHMan'}}));

            td = td2;
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
%             td3 = removeBadNeurons(td3, struct('remove_unsorted', false));
%             td3 = removeUnsorted(td3);
%             td3 = removeGracileTD(td3);
%             td3 = removeNeuronsBySensoryMap(td3, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
%             td3 = removeNeuronsByNeuronStruct(td3, struct('flags', {{'~handPSTHMan'}}));

            td = td3;
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
%             td4 = removeUnsorted(td4);
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
%             td5 = removeUnsorted(td5);
            td5(isnan([td5.idx_movement_on]))= [];
            td = td5;
        case 6
            array = 'cuneate';

            if ~exist('td6')
                td6 = getTD(monkey, date, task,num);
                for i = 1:length(td6)
                    td6(i).opensim = [];
                end
                if td6(1).bin_size ==.001
                    td6 = binTD(td6, 10);
                end
                td6 = getSpeed(td6);
                td6 = smoothSignals(td6, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td6 = getNorm(td6,struct('signals','vel','field_extra','speed'));
                td6 = getMoveOnsetAndPeak(td6,params);
                td6 = td6(~isnan([td6.idx_movement_on]));
    

            end
            
            td6(isnan([td6.idx_movement_on]))= [];
            td = td6;
        case 7
            array = 'cuneate';

            if ~exist('td7')
                td7 = getTD(monkey, date, task,num);
                for i = 1:length(td7)
                    td7(i).opensim = [];
                end
                if td7(1).bin_size ==.001
                    td7 = binTD(td7, 10);
                end
                td7 = getSpeed(td7);
                td7 = smoothSignals(td7, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td7 = getNorm(td7,struct('signals','vel','field_extra','speed'));
                td7 = getMoveOnsetAndPeak(td7,params);
                td7 = td7(~isnan([td7.idx_movement_on]));
    

            end
            td7(isnan([td7.idx_movement_on]))= [];
            td = td7;
        case 8
            array = 'cuneate';

            if ~exist('td8')
                td8 = getTD(monkey, date, task,num);
                for i = 1:length(td8)
                    td8(i).opensim = [];
                end
                if td8(1).bin_size ==.001
                    td8 = binTD(td8, 10);
                end
                td8 = getSpeed(td8);
                td8 = smoothSignals(td8, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td8 = getNorm(td8,struct('signals','vel','field_extra','speed'));
                td8 = getMoveOnsetAndPeak(td8,params);
                td8 = td8(~isnan([td8.idx_movement_on]));
    

            end
            td8(isnan([td8.idx_movement_on]))= [];
            td = td8;
        case 9
            array = 'cuneate';

            if ~exist('td9')
                td9 = getTD(monkey, date, task,num);
                for i = 1:length(td9)
                    td9(i).opensim = [];
                end
                if td9(1).bin_size ==.001
                    td9 = binTD(td9, 10);
                end
                td9 = getSpeed(td9);
                td9 = smoothSignals(td9, struct('signals', ['cuneate_spikes'], 'calc_rate',true, 'width', smoothWidth));

                target_direction = 'target_direction';

                params.start_idx =  'idx_goCueTime';
                params.end_idx = 'idx_endTime';
                td9 = getNorm(td9,struct('signals','vel','field_extra','speed'));
                td9 = getMoveOnsetAndPeak(td9,params);
                td9 = td9(~isnan([td9.idx_movement_on]));
    

            end
            td9(isnan([td9.idx_movement_on]))= [];
            td = td9;
    end
    if windowInds
        suffix = ['WindowedMatch', monkey];
    else
        suffix = ['FullData', monkey];
    end
    


    td = getSpeed(td);
    guide = td(1).([array, '_unit_guide']);
    td([td.idx_peak_speed]< [td.idx_movement_on])=[];
    tdAct = trimTD(td, {'idx_movement_on',0}, {'idx_movement_on', 13});
    if mon ~=1
        tdAct(~isnan([tdAct.bumpDir]))=[];
    end
    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, 'idx_bumpTime', {'idx_bumpTime', 13});
    
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
    vec = -60:10:60;
    logMatX = getIndicesInsideEdge(velAct(:,1), vec); 
    logMatY = getIndicesInsideEdge(velAct(:,2), vec);
    
    logMatXPas = getIndicesInsideEdge(velPas(:,1),vec);
    logMatYPas = getIndicesInsideEdge(velPas(:,2),vec);
    
    frAct = zeros(12,12, length(guide(:,1)));
    frPas = zeros(12,12, length(guide(:,2)));
    for i = 1:12
        for j = 1:12
            indMat = squeeze(logMatX(i,:) & logMatY(j,:));
            indMatPas = squeeze(logMatXPas(i,:) & logMatYPas(j,:));
            if sum(indMat) ~=1
                frAct(i,j,:) = mean(actFR(indMat,:));
                meanVel(i,j,:) = mean(velAct(indMat,:));

            else
                frAct(i,j,:) = actFR(indMat,:);
                meanVel(i,j,:) = velAct(indMat,:);
                
            end
            if sum(indMatPas) ~=1
                frPas(i,j,:) = mean(pasFR(indMatPas,:));
                meanVelPas(i,j,:) = mean(velPas(indMatPas,:));

            else
                frPas(i,j,:) = pasFR(indMatPas,:);
                meanVelPas(i,j,:) = mean(velPas(indMatPas,:));
            end

        end
    end

    mvXAct = meanVel(:,:,1);
    mvYAct = meanVel(:,:,2);
    
    mvAct = [mvXAct(:), mvYAct(:)];
    
    mvXPas = meanVelPas(:,:,1);
    mvYPas = meanVelPas(:,:,2);
    
    mvPas = [mvXPas(:), mvYPas(:)];
    s1Act = zeros(length(guide(:,1)),1);
    s1Pas = zeros(length(guide(:,1)),1);
    for i = 1:length(guide(:,1))
        temp = frAct(:,:,i);
        temp2 = frPas(:,:,i);
        
        frMAct = fitlm(mvAct, temp(:));
        s1Act(i) = norm(frMAct.Coefficients.Estimate(2:3));
        
        frMPas = fitlm(mvPas, temp2(:));
        s1Pas(i) = norm(frMPas.Coefficients.Estimate(2:3));
    end
    figure
    scatter(s1Act, s1Pas)
    hold on
    plot([0, max([s1Act, s1Pas])], [0, max([s1Act, s1Pas])])
    title(['Tuning Surface fits ', suffix])
    xlabel('Active')
    ylabel('Passive')
   for i = 1:length(s1Act)
        dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
        text(s1Act(i)+ dx, s1Pas(i) +dy, num2str(guide(i)));
   end
   set(gca,'TickDir','out', 'box', 'off')
   
   if savePlots
   
   saveas(gca,[savePath,'TuningSurface',suffix,'.png'])
   saveas(gca,[savePath,'TuningSurface',suffix,'.pdf'])
   end
   
   gridMdl =  fitlm(s1Act, s1Pas, 'Intercept', false)
   gridCoef(mon) = gridMdl.Coefficients.Estimate;
   gridCI(mon,:) = coefCI(gridMdl);
%     for i = 1:length(frAct(1,1,:))
%         maxFR1 = max(max(max(frAct(:,:,i))),max(max(frPas(:,:,i))));
%         maxFR1 = max(maxFR1,.0001);
%         figure
%         imagesc(flipud(frAct(:,:,i)'), [0,  maxFR1])
%         title(['Unit ', num2str(guide(i,1)), ' Active'])
%         colorbar
%         
%         figure
%         imagesc(flipud(frPas(:,:,i)'),  [0,  maxFR1])
%         title(['Unit ', num2str(guide(i,1)), ' Passive'])
%         colorbar
%     end
    
    figure
    scatter(velAct(:,1), velAct(:,2))
    hold on
    scatter(velPas(:,1), velPas(:,2))
    xlim([-60, 60])
    ylim([-60, 60])
    title(['Hand Vel', suffix])
    axis square
    set(gca,'TickDir','out', 'box', 'off')
   if savePlots

    saveas(gca,[savePath,'HandVelocity',suffix,'.png'])
    saveas(gca,[savePath,'HandVelocity',suffix,'.pdf'])
% %    
   end
    if ~isempty(mappingLog)
    if ~contains(mappingLog(1).date, '/')
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'yyyyMMdd')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    else
        ml = mappingLog(datetime({mappingLog.date}, 'InputFormat', 'MM/dd/yyyy')== datetime( date, 'InputFormat' , 'yyyyMMdd'));
    end

    sAct = zeros(length(guide),1);
    sPas = zeros(length(guide),1);   
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
        sAct(i) = norm(lmAct.Coefficients.Estimate(2:3));
        lmPas = fitlm(velPas, pasFR(:,i));
        sPas(i) = norm(lmPas.Coefficients.Estimate(2:3));
        neuron.sAct = sAct(i);
        neuron.sPas = sPas(i);
        mapping = td(1).([array,'_naming']);
        neuron.mapName = mapping(find(mapping(:,1) == neuron.chan), 2);

        neuron = struct2table(neuron);
        neuron = insertMappingIntoNeuron(neuron, mappingLog);
        neurons{mon} = [neurons{mon};neuron];
        
        if ~isempty(unit)
            mapped(i) = true;

            if any([ml(unit).spindle])
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
        sAct = sAct(mapped);
        sPas = sPas(mapped);
        spindle = spindle(mapped);
    else
        mGuide{mon} = guide;
    end
    sensAct{mon}= sAct;
    sensPas{mon} = sPas;
    
    cnSAct = [cnSAct; sAct];
    cnSPas = [cnSPas; sPas];
    
    lmAll{mon} = fitlm(sAct, sPas, 'Intercept', false)
    slopeAll(mon) = lmAll{mon}.Coefficients.Estimate;
    slopeCI(mon,:) = coefCI(lmAll{mon});
%     spindleLM{mon} = fitlm(sAct(spindle), sPas(spindle), 'Intercept', false);
%     nSpindleLM{mon}= fitlm(sAct(~spindle), sPas(~spindle), 'Intercept', false);
%     
    sActSpindleComb = [sActSpindleComb; sAct(spindle)];
    sPasSpindleComb = [sPasSpindleComb; sPas(spindle)];
    sActNSpindleComb = [sActNSpindleComb; sAct(~spindle)];
    sPasNSpindleComb = [sPasNSpindleComb; sPas(~spindle)];
    
    
%     spindleSens(mon,1) = spindleLM{mon}.Coefficients.Estimate(1);
%     tmp = coefCI(spindleLM{mon});
%     spindleSens(mon,2:3) = tmp;
%     nSpindleSens(mon,1) = nSpindleLM{mon}.Coefficients.Estimate(1);
%     tmp = coefCI(nSpindleLM{mon});
%     nSpindleSens(mon,2:3) = tmp;
    
    max1 = max([sAct; sPas]);
    
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
    
    sensAct{mon}= sAct;
    sensPas{mon} = sPas;
    
    figure
    scatter(sAct, sPas,'r', 'filled')
    hold on
    plot([0, max1], [0,max1])
    plot([0, max1], [0, max1*meanLin(mon)])
    xlabel('Active sensitivity')
    ylabel('Passive sensitivity')
    title(['Act vs pas sensitivity',suffix])
    for i = 1:length(sAct)
        dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
        text(sAct(i)+ dx, sPas(i) +dy, num2str(guide(i)));
    end
    set(gca,'TickDir','out', 'box', 'off')
   if savePlots

    saveas(gca, [savePath, 'ActPasSensitivity', suffix, '.pdf']);
    saveas(gca, [savePath, 'ActPasSensitivity' ,suffix, '.png']);
   end
    end

    
end
%%
spindleM = fitlm(sActSpindleComb, sPasSpindleComb, 'Intercept', false)
nSpindleM = fitlm(sActNSpindleComb, sPasNSpindleComb, 'Intercept', false)

figure

sSlope(1) = spindleM.Coefficients.Estimate(1);
cSlope(1) = nSpindleM.Coefficients.Estimate(1);

sSlope(2:3) = coefCI(spindleM);
cSlope(2:3) = coefCI(nSpindleM);
%%
% close all
but = [sensAct{1}, sensPas{1}];
cra = [sensAct{3}, sensPas{3}];
snap = [sensAct{2}, sensPas{2}];
han = [sensAct{4}, sensPas{4}];
dun = [sensAct{5}, sensPas{5}];

but1 = [sensAct{6}, sensPas{6}];
cra1 = [sensAct{7}, sensPas{7}];
cra2 = [sensAct{8}, sensPas{8}];
snap1 = [sensAct{9}, sensPas{9}];

neuronsB.lmActSens = but(:,1);
neuronsB.lmPasSens = but(:,2);
neuronsC.lmActSens = cra(:,1);
neuronsC.lmPasSens = cra(:,2);
neuronsS.lmActSens = snap(:,1);
neuronsS.lmPasSens = snap(:,2);

neuronsH.lmActSens = han(:,1);
neuronsH.lmPasSens = han(:,2);
neuronsD.lmActSens = dun(:,1);
neuronsD.lmPasSens = dun(:,2);

neuronsB2.lmActSens= but1(:,1);
neuronsB2.lmPasSens = but1(:,2);
neuronsC2.lmActSens = cra1(:,1);
neuronsC2.lmPasSens = cra1(:,2);
neuronsC3.lmActSens = cra2(:,1);
neuronsC3.lmPasSens = cra2(:,2);

neuronsS2.lmActSens = snap1(:,1);
neuronsS2.lmActSens = snap1(:,2);

butComp = [but; but1];
snapComp = [snap;snap1];
craComp = [cra;cra1;cra2];

colors = linspecer(3);
maxSens = max(max([butComp; craComp; snapComp]));
figure
scatter(butComp(:,2), butComp(:,1), 32,colors(1,:), 'filled')
hold on
scatter(craComp(:,2), craComp(:,1),32,colors(2,:), 'filled')
scatter(snapComp(:,2), snapComp(:,1),32,colors(3,:), 'filled')
plot([0, maxSens], [0, maxSens], 'k-')
set(gca,'TickDir','out', 'box', 'off')
leg = legend('Bu', 'Cr', 'Sn');
title(leg, 'Monkey')

maxSens1 = max(max([han; dun]));
figure
scatter(han(:,1), han(:,2), 'r', 'filled')
hold on
scatter(dun(:,1), dun(:,2), 'b', 'filled')
plot([0, maxSens1], [0, maxSens1], 'k-')
set(gca,'TickDir','out', 'box', 'off')
leg = legend('Ha', 'Du');
title(leg, 'Monkey')

% p4 = doNonParametricForUnityLine(10000, han);
% p5 = doNonParametricForUnityLine(10000, dun);
% p1 = doNonParametricForUnityLine(10000, but);
% p2 = doNonParametricForUnityLine(10000, cra);
% p3 = doNonParametricForUnityLine(10000, snap);


nBut = sum(but(:,1) >but(:,2));
nSnap = sum(snap(:,1) >snap(:,2));
nCra = sum(cra(:,1) >cra(:,2));
nHan = sum(han(:,1) >han(:,2));
nDun = sum(dun(:,1) >dun(:,2));

pB1 = binopdf(nBut, length(but(:,1)), .5);
pB2 = binopdf(nCra, length(cra(:,1)), .5);
pB3 = binopdf(nSnap, length(snap(:,1)), .5);
pB4 = binopdf(nHan, length(han(:,1)), .5);
pB5 = binopdf(nDun, length(dun(:,1)), .5);

pBB1 = myBinomTest(nBut, length(but(:,1)), .5, 'one')
pBCr1 = myBinomTest(nCra, length(cra(:,1)), .5, 'one');
pBSn1 = myBinomTest(nSnap, length(snap(:,1)), .5, 'one')
pBHa1 = myBinomTest(nHan, length(han(:,1)), .5, 'one')
pBD1 = myBinomTest(nDun, length(dun(:,1)), .5, 'one')

%%
neurons1 = [neurons{1};neurons{2};neurons{3}];
neurons1(strcmp(neurons1.desc, '?'),:) =[];
mapped1 = neurons1(logical(neurons1.sameDayMap),:);
%%
noDist = mapped1(~logical(mapped1.distal),:);

spindles1 = noDist(logical(noDist.isSpindle),:);
cut = noDist(logical(noDist.cutaneous),:);
prox = noDist(logical(noDist.proximal),:);

actAll = sum(neurons1.sAct > neurons1.sPas)/ height(neurons1);

actCut = sum(cut.sAct > cut.sPas)/ height(cut);
actSpindles = sum(spindles1.sAct > spindles1.sPas)/ height(spindles1);
actProx = sum(prox.sAct > prox.sPas)/height(prox);
