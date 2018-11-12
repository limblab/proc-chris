close all
v=  VideoWriter('RandomWalk20180405RightCuneate.avi');
open(v)
fig1 = figure;
xmin = -15;
xmax =  15;
ymin = -50;
ymax = -18;
sortedIndex = [cds.units.ID]>-1;
invalidIndex = [cds.units.ID]<255;
cuneateIndex = strcmp({cds.units.array}, 'cuneate');
unitList = cds.units(sortedIndex & invalidIndex & cuneateIndex);
spikeIndex = 0;
tStartVid = 1;
for i = tStartVid:height(cds.force)-1000
    time = i*.01;
    sp1 = subplot(3,1,1:2);
    scatter(cds.kin.x(i), cds.kin.y(i));
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    drawnow
    title(i)
    if spikeIndex ==0 | spikeIndex > 500
        if spikeIndex >500
            subplot(3,1,3, 'replace')
            spikeIndex = 1;
        end
        sp2 = subplot(3,1,3);
        hold on
        for j = 1:length(unitList)
            spikesInWindow = unitList(j).spikes.ts((i*.01)<[unitList(j).spikes.ts] & (i*.01 + 5)>[unitList(j).spikes.ts]);
            for k = 1:length(spikesInWindow)
                modTime = mod(spikesInWindow(k),5);
                plot([modTime, modTime], [j+.5, j-.5], 'k')
            end
        end
        xlim([0,5])
        ylim([-1, length(unitList)])
        hold off
        drawnow;
    end
    spikeIndex = spikeIndex+1;
    subplot(3,1,3)
    hold on
    h1 = plot(.01*[mod(i, 500), mod(i,500)], [0, length(unitList)], 'r');
    hold off

%     
%     if time > tStartVid
%         subplot(3, 1, 3)
%         timeDif = tStartVid - tStartNeural;
%         shiftedTimes = times-timeDif;
%         corRow = find(shiftedTimes > time & shiftedTimes < time+.01);
%         scatter3(all_medians(1,1,corRow), all_medians(1,2,corRow), all_medians(1,3,corRow), 'g')
%         hold on
%         scatter3(all_medians(2,1,corRow), all_medians(2,2,corRow), all_medians(2,3,corRow), 'b')
%         scatter3(all_medians(3,1,corRow), all_medians(3,2,corRow), all_medians(3,3,corRow), 'r')
%         scatter3(all_medians(4,1,corRow), all_medians(4,2,corRow), all_medians(4,3,corRow), 'y')     
%         scatter3(all_medians(5,1,corRow), all_medians(5,2,corRow), all_medians(5,3,corRow), 'g')
%         scatter3(all_medians(6,1,corRow), all_medians(6,2,corRow), all_medians(6,3,corRow), 'g')
%         scatter3(all_medians(7,1,corRow), all_medians(7,2,corRow), all_medians(7,3,corRow), 'b')
%         scatter3(all_medians(8,1,corRow), all_medians(8,2,corRow), all_medians(8,3,corRow), 'r')
%         scatter3(all_medians(9,1,corRow), all_medians(9,2,corRow), all_medians(9,3,corRow), 'g')
%         scatter3(all_medians(10,1,corRow), all_medians(10,2,corRow), all_medians(10,3,corRow), 'r')
%         view(2)
%     end
    drawnow
    frame = getframe(fig1);
    
    writeVideo(v, frame);
    delete(h1)        
end
close(v)