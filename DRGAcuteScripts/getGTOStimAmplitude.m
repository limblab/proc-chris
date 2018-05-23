function correctAmp =  getGTOStimAmplitude(channels)
correctAmp = inf;
stim_pw = .5;
stim_freq = 200;
nbr_pulses= 4;
mode = 'bi';

sp                      = stim_params_defaults();
sp.serial_string = 'COM7';

sp.tl                   = 1000/stim_freq*nbr_pulses;
sp.freq                 = stim_freq;
sp.comm_timeout_ms = 50;     
sp.pw                   = stim_pw;

sp.elect_list   = channels;
sp.pol          = [1 0];

 

for ampl = 2:2:8     
    sp.amp                  = round(ampl/4) ...
                            * ones(1,numel(sp.elect_list))/1000;
             
    ezstim(sp); 
    if strcmp(input('Was there a twitch?', 's'), 'y')
        correctAmp = ampl;
        break
    end
end
end