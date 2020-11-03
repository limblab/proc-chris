function fig = plotMeanAbsUniformityVsCutoff(pds)
    pis = [pi:-pi/16:0];
    for i = 1:length(pis)
        flag(i,:) = isTuned(pds.velPD, pds.velPDCI, pis(i));
        counts1 = histcounts(pds(flag(i,:),:).velPD, -pi:pi/8:pi)/(sum(flag(i,:)));
        meanC1 = mean(counts1)*ones(length(counts1),1);
        mad1(i) = norm(counts1 - meanC1');
        figure
        polarhistogram(pds(flag(i,:),:).velPD,16)
        title(num2str(i))
    end
    nums = sum(flag');
    figure
    plot(pis, mad1)
    ylabel('Nonuniformity of PD distribution')
    yyaxis right
    plot(pis, nums)
    hold on
    plot([pi/4,pi/4], [0,max(nums)])
    ylabel('Number of included neurons')
    xlabel('Increasing Stringence of Inclusion Criteria')
    set(gca, 'XDir','reverse')

end