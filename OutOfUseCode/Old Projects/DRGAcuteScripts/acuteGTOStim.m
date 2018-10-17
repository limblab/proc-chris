function stimmedMuscle = acuteGTOStim(amplitudes)
    channels = [3,1;5,7;9,11;2,4;6,8;10,12];
    numStims = 1200;
    r = randi([1,6], numStims,1);
    for i = 1:numStims
        acuteGTOStimPulse(channels(r(i),:), amplitudes(r(i)));
    end
    stimmedMuscle = r;
end