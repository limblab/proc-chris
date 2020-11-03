function [td]  = getHandleVib( td )
    debug = false;
    for i = 1:length(td)
        force1 = rownorm(td(i).force);
        
        [a,b,c,ps] = spectrogram(force1,40);
        vec0 = log10(ps(50:65,:));
        tmp = ps;
        tmp(50:65,:) = [];
        vecNeg = mean(log10(tmp));
        ratio1 = mean(vec0)./vecNeg;
        vec1 = ratio1<1;
        vec2 = resample(double(vec1), length(force1), length(vec1));
        td(i).vibOn = [vec2>.2]';
        
        
        if debug
        figure
        imagesc(log10(ps));
        

        figure
        subplot(4,1,1)
        plot(1:length(force1),force1)
        title('force')
        
        subplot(4,1,2)
        plot(1:length(mean(vec0)),mean(vec0))
        title('frequency in band')
        
        subplot(4,1,3)
        plot(1:length(ratio1),ratio1)
        title('frequency in exclusion band')
        
        subplot(4,1,4)
        plot(1:length(td(i).vibOn),td(i).vibOn)
        title('vibOn flag')
        end
        
    end

end