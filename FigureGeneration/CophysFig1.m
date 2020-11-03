clear all
close all
crackleDate = '20190418';
windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
array = 'cuneate';
monkey = 'Crackle';
folderPath = 'D:\Figures\CophysFigs\';
i = 3;
% load('D:\MonkeyData\CO\Butter\20180403\TD\Butter_CO_20180403_TD_001')
% td = binTD(td,10);
[td, date] = getPaperFiles(i, 10);
neurons = getNeurons('Crackle', crackleDate, 'CObump','cuneate',[windowAct; windowPas]);

% params = struct('flags', {{'~isCuneate', 'distal'}});
% td = removeNeuronsByNeuronStruct(td, params);
td = removeUnsorted(td);
td = smoothSignals(td, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .02));
td = getSpeed(td);
td = getMoveOnsetAndPeak(td);

guide = td(1).cuneate_unit_guide;
tdMove = td(isnan([td.bumpDir]));
tdMove = trimTD(td, {'idx_movement_on',-20}, {'idx_movement_on', 20});
tdMove = tdMove(isnan([tdMove.bumpDir]));
tdBump = td(~isnan([td.idx_bumpTime]));
tdBump = trimTD(tdBump, {'idx_bumpTime', -20}, {'idx_bumpTime',20});

moveVel = cat(1,tdMove.vel);
bumpVel = cat(1,tdBump.vel);

moveFiring = cat(1, tdMove.cuneate_spikes);
bumpFiring = cat(1, tdBump.cuneate_spikes);
%%
dirsM = unique([td.target_direction]);
dirsM(isnan(dirsM)) =[];

dirsB = unique([td.bumpDir]);
dirsB(isnan(dirsB)) =[];

for i = 1:length(dirsM)
    tdMoveDir{i} = tdMove([tdMove.target_direction] == dirsM(i));
    temp = cat(2, tdMoveDir{i}.speed);
    meanMoveSpeed(i,:) = squeeze(mean(temp'));
    temp = cat(3, tdMoveDir{i}.cuneate_spikes);
    meanMoveFR(i,:,:) = mean(temp, 3);
    
end

for i = 1:length(dirsB)
    tdBumpDir{i} = tdBump([tdBump.bumpDir] == dirsB(i));
    temp = cat(2, tdBumpDir{i}.speed);
    meanBumpSpeed(i,:) = squeeze(mean(temp'));
    temp = cat(3, tdBumpDir{i}.cuneate_spikes);
    meanBumpFR(i,:,:) = mean(temp,3);
    
end

for i = 1:length(guide(:,1))

    for j = 1
        fh1= figure;
        subplot(2,1,1)
        plot(-220:10:180,meanMoveSpeed(j,:))
        hold on
        plot(-200:10:200,meanBumpSpeed(j,:))
        set(gca,'TickDir','out', 'box', 'off')
        set(gca,'xtick',[])
        ylabel('Hand Speed (cm/s)')

        subplot(2,1,2)
        plot(-220:10:180,squeeze(meanMoveFR(j, :,i)))
        hold on
        plot(-200:10:200,squeeze(meanBumpFR(j,:,i)))
        xlabel('Time Relative To Onset')
        ylabel('Firing Rate (Hz)')
        set(gca,'TickDir','out', 'box', 'off')
        legend('Active', 'Passive')
        ylim([0, 1.1*max([squeeze(meanMoveFR(j,:,i)), squeeze(max(meanBumpFR(j,:,i)))])+.001])
        suptitle([monkey, 'Elec ', num2str(guide(i,1)), 'Unit ', num2str(guide(i,2)), 'Dir ', num2str(j)])
        saveas(fh1, [folderPath,monkey, 'Dir', num2str(j),'Elec',num2str(guide(i,1)), 'Unit', num2str(guide(i,2)), '.pdf'])
    end
    
    
end