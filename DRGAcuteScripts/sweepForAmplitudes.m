function amplitudes = sweepForAmplitudes()
    channels = [1,3;5,7;9,11;2,4;6,8;10,12];
    for i = 1:length(channels(:,1))
        amplitudes(i) = getGTOStimAmplitude(channels(i,:));
    end
end