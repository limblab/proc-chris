function [fh1] = plotHandSpeed(td, fh1)
    fh1 = figure;
    velSpace1 = cat(1, td.vel);
    [theta, mag] = cart2pol(velSpace1(:,1), velSpace1(:,2));
    theta= rad2deg(theta);
    mean1 = circ_mean(theta, mag);
    increment  = 30;

    [smoothed, edges] = smoothCircle(theta, mag, increment);
    meanSpeed = mean(smoothed);
    plot(deg2rad(edges), smoothed, 'LineWidth', 2)
    circ = 0:.01:2*pi;
    hold on
    plot(-pi:.01:pi, meanSpeed*ones(length(circ),1), 'LineWidth', 2)
    xlim([-pi, pi])
end