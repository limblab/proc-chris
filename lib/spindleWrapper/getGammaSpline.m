function [gammaDiff, gammaSpline] = getGammaSpline(gamma, binsUnPadded, useLin, padBins)
if nargin < 2
    useLin = false;
end
x = 1:length(gamma);
y = gamma;
xx = linspace(1, length(gamma), binsUnPadded);
if useLin
    yy = interp1q(x,y, xx);
else
    yy = spline(x, y, xx);% figure
end
gamma1 = [gamma(1)*ones(1,padBins), yy];
gammaDiff = [gamma(1), diff(gamma1)];
gammaSpline = gamma1(padBins+1:end);
end