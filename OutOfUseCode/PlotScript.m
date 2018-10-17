close all
opensim =  cat(1, td.opensim);
spiking = cat(1, td.RightCuneate_spikes);
spikingS1 = cat(1,td.LeftS1_spikes);

bicepsLen = opensim(:,3);
bicepsVel = gradient(bicepsLen, .05);
brachialisLen = opensim(:,5);
brachialisVel = gradient(brachialisLen, .05);
ecrLen = opensim(:,12);
ecrVel = gradient(ecrLen, .05);
elecNames1 = {'65', '81', '91'};
muscleStimd = {'Biceps', 'Brachialis', 'ECR'};
titles = {'Biceps Responsive Spindle during movement', 'Brachialis Reponsive Neuron During Movement', 'ECR responsive neuron during movement'};
handleKin = cat(1, td.vel);
handleSpeed = sqrt(sum(abs(handleKin).^2,2));

times = linspace(0,.05*length(ecrLen), length(ecrLen));
count = 0;
for i = [2,7,9]
    count = count +1;
    if i ==2
        muscle = bicepsVel;
    elseif i ==7
        muscle = brachialisVel;
    elseif i ==9
        muscle = ecrVel;
    else 
        muscle = bicepsVel;
    end
    firing = spiking(:,i);
    figure
    sp1 = subplot(3,1,1);
    plot(times, muscle);
    title('Muscle Velocity')
    sp2 = subplot(3,1,3);
    plot(times, smooth(firing));
    title('Firing Rate')
    sp3 = subplot(3,1,2);
    plot(times, handleSpeed);
    title('Handle Speed')
    linkaxes([sp1, sp2, sp3], 'x')
    xlim([50, 60])
    suptitle(titles{count})
end

% for i = 1:length(spiking(1,:))
%     firing = spikingS1(:,i);
%     figure
%     sp1 = subplot(2,1,1);
%     plot(bicepsVel);
%     sp2 = subplot(2,1,2);
%     plot(smooth(firing,3));
%     linkaxes([sp1, sp2], 'x')
%     xlim([2400, 2800])
%     suptitle(['S1 Unit', num2str(i)])
% end
%% Spectrogram
