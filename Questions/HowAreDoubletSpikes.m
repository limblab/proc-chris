close all
clear all
windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
plotPath = 'D:\Figures\ISIHist\';
for i = 1
    cds = getPaperFilesCDS(i);
    neurons = getPaperNeurons(i, windowAct, windowPas);
    monkey = neurons.monkey(1);
    date = neurons.date(1);
    units = cds.units;
    units([units.ID] ==0 | [units.ID] ==255) =[];
    for j = 31:96
        close all
        unitElec =units([units.chan] == j);
        figure
        hold on
        colors = linspecer(length(unitElec));
        disp(num2str(length(unitElec)))
        for k = 1:length(unitElec)
            waveshapes = unitElec(k).spikes.wave;
            plot(repmat([1/30:1/30:48/30], length(waveshapes(:,1)),1)', waveshapes', 'Color',colors(k,:))
        
        end
        legend('on')
        title(['Elec ', num2str(j)])
        xlabel('Time (ms)')
        ylabel('Voltage (microvolts)')
        disp('Press button to move on')
        if length(unitElec)>1
        offsets = crosscorrelogram(unitElec(1).spikes.ts, unitElec(2).spikes.ts, [-.1, .1]);
        figure
        histogram(offsets)
        end
        pause
    end
end