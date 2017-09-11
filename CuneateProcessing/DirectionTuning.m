   close all
   sigDif = zeros(19,1);
   vec = 1:19;
   noVec = [7, 10, 12, 14, 15, 16, 18]; 
for i = [1:6, 8, 9, 11, 13, 17, 19]
    temp =mean(shortRightBumpFiring{i});
    bootstatRight= bootstrp(1000, @mean, temp);
    temp =mean(shortLeftBumpFiring{i});
    bootstatLeft= bootstrp(1000, @mean, temp);
    temp =mean(shortDownBumpFiring{i});
    bootstatDown= bootstrp(1000, @mean, temp);
    temp =mean(shortUpBumpFiring{i});
    bootstatUp= bootstrp(1000, @mean, temp);
    f1 = figure('Position', [100, 100, 1200, 800]);
    sp1 = subplot(2,1,1);
    histogram(bootstatRight)
    hold on
    histogram(bootstatLeft)
    histogram(bootstatUp)
    histogram(bootstatDown)
    title1 = ['Electrode' num2str(td(1).RightCuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).RightCuneate_unit_guide(i,2)) ,' Bump Tuning'];
    title(title1)
    xlabel('Firing')
    legend('show')
    
    sortedRight = sort(bootstatRight);
    sortedLeft = sort(bootstatLeft);
    sortedUp = sort(bootstatUp);
    sortedDown = sort(bootstatDown);
    
    meanRight = mean(sortedRight);
    topRight = sortedRight(950);
    botRight = sortedRight(50);
    
    meanLeft = mean(sortedLeft);
    topLeft = sortedLeft(950);
    botLeft = sortedLeft(50);
    
    meanUp = mean(sortedUp);
    topUp = sortedUp(950);
    botUp = sortedUp(50);
    
    meanDown = mean(sortedDown);
    topDown = sortedDown(950);
    botDown = sortedDown(50);
    
    rightSig(i) = topRight<meanLeft | topRight<meanUp | topRight<meanDown | botRight > meanLeft | botRight >meanUp | botRight > meanDown;
    leftSig(i) = topLeft<meanRight | topLeft<meanUp | topLeft<meanDown | botLeft > meanRight | botLeft >meanUp | botLeft > meanDown;
    upSig(i) = topUp<meanRight | topUp<meanLeft | topUp<meanDown | botUp > meanRight | botUp >meanLeft | botUp > meanDown;
    downSig(i) = topDown<meanRight | topDown<meanUp | topDown<meanLeft | botDown > meanRight | botDown >meanUp | botDown > meanLeft;
    
    sigDifBump(i) = rightSig(i) | leftSig(i) | upSig(i) | downSig(i);
    %
    temp =mean(shortRightMoveFiring{i});
    bootstatRight= bootstrp(1000, @mean, temp);
    temp =mean(shortLeftMoveFiring{i});
    bootstatLeft= bootstrp(1000, @mean, temp);
    temp =mean(shortDownMoveFiring{i});
    bootstatDown= bootstrp(1000, @mean, temp);
    temp =mean(shortUpMoveFiring{i});
    bootstatUp= bootstrp(1000, @mean, temp);
    sp2= subplot(2,1,2);
    histogram(bootstatRight)
    hold on
    histogram(bootstatLeft)
    histogram(bootstatUp)
    histogram(bootstatDown)
    title1 = ['Electrode' num2str(td(1).RightCuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).RightCuneate_unit_guide(i,2)), '  Move Tuning'];
    title(title1)
    xlabel('Firing')
    legend('show')
    
    sortedRight = sort(bootstatRight);
    sortedLeft = sort(bootstatLeft);
    sortedUp = sort(bootstatUp);
    sortedDown = sort(bootstatDown);
    
    meanRight = mean(sortedRight);
    topRight = sortedRight(950);
    botRight = sortedRight(50);
    
    meanLeft = mean(sortedLeft);
    topLeft = sortedLeft(950);
    botLeft = sortedLeft(50);
    
    meanUp = mean(sortedUp);
    topUp = sortedUp(950);
    botUp = sortedUp(50);
    
    meanDown = mean(sortedDown);
    topDown = sortedDown(950);
    botDown = sortedDown(50);
    
    rightSig(i) = topRight<meanLeft | topRight<meanUp | topRight<meanDown | botRight > meanLeft | botRight >meanUp | botRight > meanDown;
    leftSig(i) = topLeft<meanRight | topLeft<meanUp | topLeft<meanDown | botLeft > meanRight | botLeft >meanUp | botLeft > meanDown;
    upSig(i) = topUp<meanRight | topUp<meanLeft | topUp<meanDown | botUp > meanRight | botUp >meanLeft | botUp > meanDown;
    downSig(i) = topDown<meanRight | topDown<meanUp | topDown<meanLeft | botDown > meanRight | botDown >meanUp | botDown > meanLeft;
    
    sigDifMove(i) = rightSig(i) | leftSig(i) | upSig(i) | downSig(i);
    linkaxes([sp1, sp2]);
    figTitle = ['Electrode' num2str(td(1).RightCuneate_unit_guide(i,1)), ' Unit ', num2str(td(1).RightCuneate_unit_guide(i,2)), '.png'];
    saveas(f1,figTitle);
    
    
end

pctSigBump = sum(sigDifBump)/12;
pctSigMove = sum(sigDifMove)/12;