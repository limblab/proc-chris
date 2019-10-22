function hrStat = hermansRasson(alphas)
    n = length(alphas);
    sum1 = 0;
    for i = 1:n
        for j = 1:n
            sum1 = sum1 + abs(abs(alphas(i) - alphas(j))-pi/2) -2.895*(abs(sin(alphas(i) - alphas(j)))- (2/pi));
        end
    end
    hrStat = sum1/n;
end