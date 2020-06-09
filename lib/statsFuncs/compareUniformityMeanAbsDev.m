function [tab] = compareUniformityMeanAbsDev(neurons1, neurons2)
numBoots = 10000;

if istable(neurons1)
    actAngs1 = [neurons1.pasPD.velPD];
else
    actAngs1 = neurons1;
end
if ~isempty(neurons2)
    actAngs2 = [neurons2.pasPD.velPD];
else
    actAngs2 = simInputs;
end

inds1 = randi(length(actAngs1), length(actAngs1), numBoots);
inds2 = randi(length(actAngs2), length(actAngs1), numBoots);
w = gausswin(2);
for i = 1:numBoots
    bootAngs1 = actAngs1(inds1(:,i));
    bootAngs2 = actAngs2(inds2(:,i));
    
    counts1 = histcounts(bootAngs1, -pi:pi/8:pi)/length(bootAngs1);
    counts2 = histcounts(bootAngs2, -pi:pi/8:pi)/length(bootAngs2);
    
%     counts1 = filter(w, 1, sort(counts1));
%     counts2 = filter(w, 1, sort(counts2));
    
    meanC1 = mean(counts1)*ones(length(counts1),1);
    meanC2 = mean(counts2)*ones(length(counts2),1);
    mad1(i) = norm(counts1 - meanC1');
    mad2(i) = norm(counts2 -meanC2');
    
%     figure
%     histogram(bootAngs1, -pi:pi/8:pi)
%     hold on
% %     plot([0, 2*pi],[meanC1,meanC1])
%     title(['CN dist ', num2str(mad1(i))])
%     figure
%     histogram(bootAngs2, -pi:pi/8:pi)
%     hold on
% %     plot([0, 2*pi],[meanC2,meanC2])
%     title(['S1 dist ', num2str(mad2(i))])
end

r1CI = quantile(mad1, [.05, .5, .95]);
r2CI = quantile(mad2, [.05, .5, .95]);


tab = table([r1CI(1); r2CI(1)],[r1CI(2);r2CI(2)], [r1CI(3); r2CI(3)], 'VariableNames', {'LowCI','mean','HighCI'});


end