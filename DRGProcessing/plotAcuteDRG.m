function fh1 =  plotAcuteDRG(cds, elbow, wrist,hand, tStartNeural, tStartIMU, tStart, tEnd)
    fh1 = figure;
    elbow = elbow(tStartIMU:end,:);
    wrist = wrist(tStartIMU:end,:);
    hand = hand(tStartIMU:end,:);
    subplot(2,1,2)
    hold on
    timeStamps = {cds.units([cds.units.ID ]>0).spikes};
    for i = 1:length(timeStamps)
        ts = timeStamps{i}.ts-tStartNeural;
        ts = ts(ts>tStart & ts< tEnd);
        for j = 1:length(ts)
            plot([ts(j), ts(j)], [i-.3, i+.5],'k')
        end
    end
    xlim([tStart, tEnd])
    timeVecIMU = linspace(0, .01*length(elbow), length(elbow));
    subplot(2,1,1)
    for k = 1:length(elbow(:,1))
        elbowAng(k,:) = atan2d(norm(cross(elbow(k,:),wrist(k,:))),dot(elbow(k,:),wrist(k,:)));
        shoulderFlex(k) = atan2d(norm(cross(elbow(k,:),[1,0,0])),dot(elbow(k,:),[1,0,0]));
        wristFlex(k) = atan2d(norm(cross(wrist(k,:),hand(k,:))),dot(wrist(k,:),hand(k,:)));     
    end
    plot(timeVecIMU, elbowAng)
    hold on
    plot(timeVecIMU, shoulderFlex)
    plot(timeVecIMU, wristFlex)
    legend('Elbow angle', 'Shoulder angle', 'wrist Angle')
    
    xlim([tStart, tEnd])
    
end