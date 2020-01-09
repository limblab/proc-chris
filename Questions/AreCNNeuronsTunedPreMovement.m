% clear all
close all
clearvars -except td1 td2 td3 td4 td5 sensAct sensPas mGuide
plotRasters = 1;
savePlots = 1;
isMapped = true;
savePDF = true;
smoothWidth = .01;
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


for mon = 3
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
                td1 = removeNeuronsBySensoryMap(td1, struct('rfFilter', {{'handUnit', true; 'distal', true; 'spindle', false}})); 
                td1 = removeNeuronsByNeuronStruct(td1, struct('flags', {{'~handPSTHMan'}}));
%                 td1(~isnan([td1.idx_bumpTime])) = [];
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
                td2 = removeNeuronsBySensoryMap(td2, struct('rfFilter', {{'handUnit', true; 'distal', true; 'spindle', false}})); 
                td2 = removeNeuronsByNeuronStruct(td2, struct('flags', {{'~handPSTHMan'}}));
                td2(~isnan([td2.idx_bumpTime])) = [];

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
                td3 = removeNeuronsBySensoryMap(td3, struct('rfFilter', {{'handUnit', true; 'distal', true; 'spindle', false}})); 
                td3 = removeNeuronsByNeuronStruct(td3, struct('flags', {{'~handPSTHMan'}}));
                td3(~isnan([td3.idx_bumpTime])) =[];
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
     
    guide = td(1).([array, '_unit_guide']);
    tdPre = trimTD(td, {'idx_goCueTime', -20}, {'idx_goCueTime', -15});
    tdAct = trimTD(td, {'idx_movement_on', -20}, {'idx_movement_on', -10});
    tdMove = trimTD(td, {'idx_movement_on', 0}, {'idx_movement_on', 30});
    
    dirsM = unique([td.target_direction]);
    dirsM(isnan(dirsM)) = [];
    dirsM(mod(dirsM, pi/4) ~=0) = [];
    
    dirsB = unique([td.bumpDir]);
    dirsB(isnan(dirsB)) = [];
    dirsB(mod(dirsB, 45) ~=0) = [];
    meanFRAct = zeros(length(dirsM), length(guide(:,1)));
    meanFRPre = zeros(length(dirsM), length(guide(:,1)));
    meanFRMove = zeros(length(dirsM), length(guide(:,1)));
    
    figure
    posPre = cat(1, tdPre.pos);
    posAct = cat(1, tdAct.pos);
    posMove =cat(1, tdMove.pos);
    
    scatter(posMove(:,1), posMove(:,2))
    hold on
    scatter(posAct(:,1), posAct(:,2))
    scatter(posPre(:,1),posPre(:,2))
    legend('Move', 'Early', 'Pre')
    xlim([-20,20])
    ylim([-50, -20])
    pause
    
    for i = 1:length(dirsM)
        [meanFRAct(i,:), meanFRActCI(i,:,:)] = getMeanTD(tdAct([tdAct.target_direction] == dirsM(i)), struct('signal', 'cuneate_spikes'));
        [meanFRPre(i,:), meanFRPreCI(i,:,:)] = getMeanTD(tdPre([tdPre.target_direction] == dirsM(i)), struct('signal', 'cuneate_spikes'));
        [meanFRMove(i,:), meanFRMoveCI(i,:,:)] = getMeanTD(tdMove([tdMove.target_direction] == dirsM(i)), struct('signal', 'cuneate_spikes'));
        
    end
    
    %%
    maxAct = zeros(length(meanFRAct(1,:)),1);
    maxPre = zeros(length(meanFRAct(1,:)),1);
    maxMove = zeros(length(meanFRAct(1,:)),1);
    
    for i = 1:length(meanFRAct(1,:))
        
        [frActMax(i), maxAct(i)] = max(meanFRAct(:,i));
        [frPreMax(i), maxPre(i)] = max(meanFRPre(:,i));
        [frMoveMax(i), maxMove(i)] = max(meanFRMove(:,i));
        
        difFR(i) = frActMax(i) - meanFRPre(maxAct(i),i);
        theta = linspace(0,2*pi, 9);
%         figure
%         polarplot(theta, plotAct)
%         hold on
%         polarplot(theta, plotPre)
%         polarplot(theta, plotMove)
%         title(['E ', num2str(guide(i,1)), ' U ', num2str(guide(i,2))])
%         pause
    end 
    %%
    t1 = theta(1:end-1);
    figure
    angAct = t1(maxAct);
    angMove = t1(maxMove);
    angDif1 = angleDiff(angAct, angMove, true, false);
    histogram(angDif1, 8)
    guideFlip{mon} = guide(angDif1>pi/2,:);
    for i = 1:length(angDif1)
        if angDif1(i)
        plotAct = [meanFRAct(:,i); meanFRAct(1,i)];
        plotPre=  [meanFRPre(:,i); meanFRPre(1,i)];
        plotMove = [meanFRMove(:,i); meanFRMove(1,i)];
        actLow = [squeeze(meanFRActCI(:,1,i)); squeeze(meanFRActCI(1,1,i))];
        actHigh = [squeeze(meanFRActCI(:,2,i)); squeeze(meanFRActCI(1,2,i))];
        preLow = [squeeze(meanFRPreCI(:,1,i)); squeeze(meanFRPreCI(1,1,i))];
        preHigh = [squeeze(meanFRPreCI(:,2,i)); squeeze(meanFRPreCI(1,2,i))];
        moveLow = [squeeze(meanFRMoveCI(:,1,i)); squeeze(meanFRMoveCI(1,1,i))];
        moveHigh = [squeeze(meanFRMoveCI(:,2,i)); squeeze(meanFRMoveCI(1,2,i))];
        
        figure
        polarplot(theta, plotAct, 'Color', 'r')
        hold on
        polarplot(theta, plotPre, 'Color', 'g')
        polarplot(theta, plotMove, 'Color', 'b')
        
        polarplot(theta, moveLow, 'Color', 'b')
        polarplot(theta, moveHigh, 'Color', 'b')
        
        polarplot(theta, preLow, 'Color', 'g')
        polarplot(theta, preHigh, 'Color', 'g')
        
        polarplot(theta, actLow, 'Color', 'r')
        polarplot(theta, actHigh, 'Color', 'r')
        
        title([monkey, ' E ', num2str(guide(i,1)), ' U ', num2str(guide(i,2))])
        title1 = [monkey, 'E', num2str(guide(i,1)), 'U', num2str(guide(i,2)), '.png'];
        legend('Early', 'Pre', 'Move')
        saveas(gca, ['C:\Users\wrest\Pictures\GammaDriveEvidence\', title1])
%         pause
        end  
    end

end
%%
figure
flag1 = [4 7 11 13 18 19 20 23 25];
guide(:,3) = difFR';
guideSens = mGuide{3};
guide(:,4) = sensAct{mon};
guide(:,5) = sensPas{mon};
th1 = atan2(sensPas{mon}, sensAct{mon});
len1 = rownorm(guide(:,4:5))';
%%
for i = 1:length(guide(:,1))
%     keyboard
    x = sensAct{mon}(i);
    y = sensPas{mon}(i);
    v = [x,y];
    vM = dot(v,[1/sqrt(2), 1/sqrt(2)])/sqrt(2);
    vm1 = [vM, vM];
    d(i) = norm(v-vM);
    if y>x
        d(i) = d(i)*-1;
    end
end

guide(:,6)=  d;
%%
figure
scatter(guide(:,3), guide(:,6))
fitlm(guide(:,3), guide(:,6))
set(gca,'TickDir','out', 'box', 'off')

xlabel('Premovement FR change in antiPD')
ylabel('Sensitivity Change (+ is more sensitive in active)')
%%
% keyboard
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
