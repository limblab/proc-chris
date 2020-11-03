close all
clear all
windowAct= {'idx_movement_on', 0; 'idx_movement_on',40}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
plotPath = 'D:\Figures\ISIHist\';
for i = 1:3
    cds = getPaperFilesCDS(i);
    neurons = getPaperNeurons(i, windowAct, windowPas);
    monkey = neurons.monkey(1);
    date = neurons.date(1);
    units = cds.units;
    units([units.ID] ==0 | [units.ID] ==255) =[];
    for j = 1:length(units)
        close all
        unit =units(j);
        neuron = neurons([neurons.chan] == unit.chan & [neurons.ID] == unit.ID, : );
        isiHist{i,j} = diff(units(j).spikes.ts);
        f1 = figure;
        histogram(isiHist{i,j}*1000, 0:5:200,'Normalization', 'probability')
        xlabel('Interspike Interval (ms)')
        ylabel('% of spikes')
        temp = string([monkey, date, 'Chan', num2str(neuron.chan), 'ID', num2str(neuron.ID),  neuron.desc, num2str(neuron.daysDiff)]);
        title(strjoin(temp,' '))
        temp1= [monkey, date, 'Chan', num2str(neuron.chan), 'ID', num2str(neuron.ID)];
        saveas(f1, [plotPath, strjoin(temp1, '_'), '.png'])
    end
end