function [cost, rOut, rd, rs] = optimizeGamma(firingRate, len, spindleParams, gamma, params)
    symFlag = false;
    useLin = false;
    plotResult = false;
    binSize = .005;
    padLen = .1;
    gammaReg = 0;
    coupledGamma = true;
    numSpline = 4;

    if nargin > 4, assignParams(who,params); end % overwrite defaults
    len1 = length(len(:,1));
    conds = length(len(1,:));
    cost = 0;
    for i = 1:conds
    t = linspace(binSize, binSize*length(len(:,1))+ padLen, len1+padLen/binSize);
    t = (t - t(1))';
    resampT =  binSize:binSize:t(end);
    
    prependLen = [len(1,i)*ones(floor((padLen/binSize)), 1) ; len(:,i)];
    % Normalize length to mean muscle length
    normLen = prependLen;
   resampLen = interp1(t, normLen, resampT);

    diffLen = diff(resampLen)*1300;
    diffLen = [resampLen(1) diffLen];
    if coupledGamma
    [gammaS, gS] = getGammaSpline(gamma(numSpline*(i-1)+ 2: numSpline*i +1), len1, useLin, padLen/binSize);
    [gammaD, gD] = getGammaSpline(gamma(numSpline*(i-1)+ 2: numSpline*i +1 ), len1, useLin, padLen/binSize);
    else
    [gammaS, gS] = getGammaSpline(gamma(numSpline*(i-1)+ 2: numSpline*i +1), len1, useLin, padLen/binSize);
    [gammaD, gD] = getGammaSpline(gamma(numSpline*(i)+ 2: numSpline*(i+1) +1 ), len1, useLin, padLen/binSize);
    end

%     figure
%     plot(resampT)
%     title('resampT')
%     figure
%     plot(gammaD)
%     hold on
%     plot(gammaS)
%     title('Gamma')
%     
%     figure
%     plot(diffLen)
%     title('DiffLen')
    
    [~, dataB, ~, dataC] = sarcSimDriver(resampT, gammaD, gammaS, diffLen, symFlag); 
%     
%     figure
%     plot(dataB.f_activated)
%     title('fAct')
    
    [r, rs, rd] = sarc2spindle(dataB, dataC,spindleParams(1),spindleParams(2),spindleParams(3),spindleParams(4), spindleParams(5));
 
    r = r(floor(padLen/binSize):end);
    rd = rd(floor(padLen/binSize):end);
    rs = rs(floor(padLen/binSize):end);
    

    cost = cost + sum((gamma(1)*r- firingRate(:,i)').^2) + gammaReg*(norm(gS)+ norm(gD));  
%     cost1 = corr([(r./mean(r))', firingRate./mean(firingRate)]);
%     cost = -1*cost1(1,2);
    rOut(i,:) = r;
        if plotResult
        
        figure
        plot(r./max(r))
        hold
        plot(firingRate./max(firingRate))
        legend('r', 'real')
    end
    end


end