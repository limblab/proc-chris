% clear all
close all
clearvars -except td1 td2 td3 td4 td5
plotRasters = 1;
savePlots = false;
isMapped = true;
savePDF = false;
smoothWidth = .01;
windowInds = true;
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
    
                td1 = removeBadNeurons(td1, struct('remove_unsorted', false));
                td1 = removeUnsorted(td1);
                td1 = removeGracileTD(td1);
                td1 = removeNeuronsBySensoryMap(td1, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
                td1 = removeNeuronsByNeuronStruct(td1, struct('flags', {{'~handPSTHMan'}}));
                
            end
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

                td2 = removeBadNeurons(td2, struct('remove_unsorted', false));
                td2 = removeUnsorted(td2);
                td2 = removeGracileTD(td2);
                td2 = removeNeuronsBySensoryMap(td2, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
                td2 = removeNeuronsByNeuronStruct(td2, struct('flags', {{'~handPSTHMan'}}));

            end
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
    
                td3 = removeBadNeurons(td3, struct('remove_unsorted', false));
                td3 = removeUnsorted(td3);
                td3 = removeGracileTD(td3);
                td3 = removeNeuronsBySensoryMap(td3, struct('rfFilter', {{'handUnit', true, 'distal', true}})); 
                td3 = removeNeuronsByNeuronStruct(td3, struct('flags', {{'~handPSTHMan'}}));

            end
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
    


    for win = 1:10
    guide = td(1).([array, '_unit_guide']);
    td([td.idx_peak_speed]< [td.idx_movement_on])=[];
    tdAct = trimTD(td, {'idx_peak_speed',-20+ win}, {'idx_peak_speed', -7+win});
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
    sAct = zeros(length(ml),1);
    sPas = zeros(length(ml),1);   
    mapped = false(length(guide(:,1)),1);
    for i = 1:length(guide)
        unit = find([ml.elec] == guide(i,1));
        if ~isempty(unit)
            mapped(i) = true;
            lmAct = fitlm(velAct, actFR(:,i));
            sAct(i) = norm(lmAct.Coefficients.Estimate(2:3));
            lmPas = fitlm(velPas, pasFR(:,i));
            sPas(i) = norm(lmPas.Coefficients.Estimate(2:3));

            if ml(unit).spindle
                spindle(i) = true;
%                 figure
%                 plot(lmAct)
%                 hold on
%                 plot(lmPas)
%                 title(['Elec ', num2str(guide(i,1))])
            else
                spindle(i) = false;
            end
        else
            sAct(i) = 0;
            sPas(i) = 0;
            mapped(i) = false;
        end
    end
    mGuide{mon} = guide(mapped);
    sAct = sAct(mapped);
    sPas = sPas(mapped);
    spindle = spindle(mapped);
    sensAct{mon}= sAct;
    sensPas{mon} = sPas;
    lmAll{mon} = fitlm(sAct, sPas, 'Intercept', false)
    slopeAll(mon,win) = lmAll{mon}.Coefficients.Estimate;
    slopeCI(mon,win,:) = coefCI(lmAll{mon});
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
    
    figure
    scatter(sAct(spindle), sPas(spindle),'r', 'filled')
    hold on
    scatter(sAct(~spindle'), sPas(~spindle),'b', 'filled')
    plot([0, max1], [0, max1*slopeAll(mon)], 'k-')
    legend({'Spindles', 'Non-spindles'})
    plot([0, max1], [0,max1])
    xlabel('Active sensitivity')
    ylabel('Passive sensitivity')
    title(['Act vs pas sensitivity',suffix])
    for i = 1:length(sAct)
        dx = -.01; dy = 0.01; % displacement so the text does not overlay the data points
        text(sAct(i)+ dx, sPas(i) +dy, num2str(mGuide{mon}(i)));
    end
    set(gca,'TickDir','out', 'box', 'off')
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
    vec1 = [sensAct{1}, sensPas{1}];
    pSim(mon,win) = doNonParametricForUnityLine(100000, vec1);
    nAct = sum(vec1(:,1) >vec1(:,2));

    pBer(mon,win) = binopdf(nAct, length(vec1(:,1)), .5);

    end
end
%%
spindleM = fitlm(sActSpindleComb, sPasSpindleComb, 'Intercept', false)
nSpindleM = fitlm(sActNSpindleComb, sPasNSpindleComb, 'Intercept', false)

sSlope(1) = spindleM.Coefficients.Estimate(1);
cSlope(1) = nSpindleM.Coefficients.Estimate(1);

sSlope(2:3) = coefCI(spindleM);
cSlope(2:3) = coefCI(nSpindleM);
%%
but = [sensAct{1}, sensPas{1}];
cra = [sensAct{2}, sensPas{2}];
snap = [sensAct{3}, sensPas{3}];
han = [sensAct{4}, sensPas{4}];
dun = [sensAct{5}, sensPas{5}];

p4 = doNonParametricForUnityLine(1000000, han);
p5 = doNonParametricForUnityLine(1000000, dun);
p1 = doNonParametricForUnityLine(1000000, but);
p2 = doNonParametricForUnityLine(1000000, cra);
p3 = doNonParametricForUnityLine(1000000, snap);

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


