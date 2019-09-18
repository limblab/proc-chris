filepath = 'C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Snap\20190823\NEV\Snap_20190823_CO_cuneate_001.ns5';
nevPath = 'C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Snap\20190823\NEV\Sorted\Snap_20190823_CO_cuneate_001-sorted.nev';


fl = 250;
fc = 1000; % Cut off frequency
fs = 30000; % Sampling rate

nev = openNEV(nevPath);
%%
lowThresholds = [nev.ElectrodesInfo.LowThreshold];
highThresholds = [nev.ElectrodesInfo.HighThreshold];

for i= 1:length(lowThresholds)
    if lowThresholds(i) ==0
        thresholds(i) = highThresholds(i);
    else
        thresholds(i)= lowThresholds(i);
    end
end
%%
s1.TimeStamp =[];
s1.Electrode = [];
s1.Waveform = [];
s1.WaveformUnit = 'raw';
s1.Unit= [];
for i = 1:96
    close all
    threshold = double(thresholds(i));
    chan = ['c:',num2str(i)];
    
    disp(chan)
    disp(num2str(threshold))
    nsxChan = openNSx(filepath, chan, 'precision','double');

    x = nsxChan.Data;
    ns1 = nsxChan;
    [b,a] = butter(4,[fl, 5000]/(fs/2)); % Butterworth filter of order 6
    x = filter(b,a,x(1,:)); % Will be the filtered signal]
    x1 = x(end/2:end);
    
%     plot(1/fs:1/fs:length(x1)*1/fs,x1)
%     hold on 
%     scatter(row/fs, x1(row))
%     pause
    
    ns1.Data = x;
    
    s = findSpikes(ns1, 'threshold', threshold);
    s1.TimeStamp = [s1.TimeStamp,s.TimeStamp'];
    s1.Electrode = [s1.Electrode,i*ones(1, length(s.TimeStamp))];
    s1.Waveform = [s1.Waveform, s.Waveform];
    s1.WaveformUnit = 'raw';
    s1.Unit = [s1.Unit, zeros(1,length(s.TimeStamp))];
end
nev.Data.Spikes = s1;
saveNEV(nev)