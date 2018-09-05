function [smoothed, edges] = smoothCircle(theta, rho, increment)
    edges = -180:increment:180;
    [bins, edges, inds] = histcounts(theta, edges);
    for i = 1:length(bins)
        smoothed(i) = mean(rho(inds==i));
    end
    smoothed(i+1) = smoothed(1);
end