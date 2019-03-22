function vidPath = cdsVibrationToVideo(videoPath, cds, params)
    vibStarts = [1];
    v = VideoReader(videoPath);
    if nargin > 2, assignParams(who,params); end % overwrite parameters
    if isempty(vibStarts)
        error('No vibration start times')
    end
    %% Align video and cds
    
    %% Generate audio file
    
    %% Write to video
    fileDur = cds.meta.duration;
    units = cds.units([cds.units.ID] >0 & [cds.units.ID]<255);
    vec = 1/1000:1/1000:fileDur;
    rates = histcounts(units(6).spikes.ts, [0,vec]);
%     rates = rates>0;
    audiowrite('firingAudio1.wav', rates, 1000);
end