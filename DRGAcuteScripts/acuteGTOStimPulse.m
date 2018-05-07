function acuteGTOStimPulse(channel,amplitude)
    
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

    sp.elect_list   = channel;
    sp.pol          = [1 0];

    sp.amp                  = round(amplitude/4) ...
                            * ones(1,numel(sp.elect_list))/1000;

    ezstim(sp); 

end

