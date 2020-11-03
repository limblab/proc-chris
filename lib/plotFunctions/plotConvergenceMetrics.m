function [maD, major, angles] = plotConvergenceMetrics(pdDist,params)
   
plotNums = [1:10];
numBins = 18;

if nargin > 1, assignParams(who,params); end % overwrite parameters
pdDist = cat(3, pdDist{:});
for boot = 1:length(pdDist(1,1,:))
    for i = plotNums  
        ph1 = polarhistogram(pdDist(i,:, boot), numBins, 'FaceColor', 'b', 'FaceAlpha', 1);
        edges = ph1.BinEdges;
        edgeCenters = (edges(2:end)+edges(1:end-1))/2;
        rho = ph1.BinCounts;

        maD(i,boot) = norm((rho-mean(rho))/mean(rho),1);
        [xCart, yCart] = pol2cart(edgeCenters, rho);
        ell{i} = fit_ellipse(xCart, yCart);
        if ~isempty(ell{i}) & ~isempty(ell{i}.long_axis)
            major(i, boot) = ell{i}.long_axis;
            minor(i, boot) = ell{i}.short_axis;
            angles(i,boot) = rad2deg(ell{i}.phi);
        end
    end
end
gangles = -1*angles +90;
figure
shadedErrorBar(plotNums, maD', {@mean, @std})
ylabel('Mean Abs Dev. from Uniformity')
yyaxis right
shadedErrorBar(plotNums, gangles', {@mean, @std})
xlabel('Number of Muscles')
ylabel('Major axis angle (deg)')
end