close all
arrayMap = [0,89,90,91,92,93,94,95,96,0;...
            79,80,81,82,83,84,85,86,87,88;...
            69,70,71,72,73,74,75,76,77,78;...
            59,60,61,62,63,64,65,66,67,68;...
            49,50,51,52,53,54,55,56,57,58;...
            39,40,41,42,43,44,45,46,47,48;...
            29,30,31,32,33,34,35,36,37,38;...
            19,20,21,22,23,24,25,26,27,28;...
            9, 10,11,12,13,14,15,16,17,18;...
            0, 1, 0, 3, 4, 5, 6, 7, 8, 2];
        
tonicTuning = zeros(10);
hasUnits = zeros(10);
for i = 1:length(td(1).Cuneate_spikes(1,:))
    chanList = td(1).Cuneate_unit_guide(:,1);
    ind = find(arrayMap == chanList(i));
    hasUnits(ind) = 1;
    pvalInv = 1/bestMoveP(i);
    if pvalInv > tonicTuning(ind)
        tonicTuning(ind) = log10(pvalInv);
    end
end
figure
imagesc(tonicTuning)
colorbar
title('Movement Tuning Significance')

bumpTuning = zeros(10);
for i = 1:length(chanList)
    chanList = td(1).Cuneate_unit_guide(:,1);
    ind = find(arrayMap == chanList(i));
    pvalInv = 1/bestBumpP(i);
    if pvalInv > bumpTuning(ind)
        bumpTuning(ind) = log10(pvalInv);
    end
end
bumpTuning(bumpTuning == max(bumpTuning)) = 25;
figure
imagesc(bumpTuning)
colorbar
title('Bump Tuning Significance')

figure
imagesc(hasUnits)
title('Channels with Units')