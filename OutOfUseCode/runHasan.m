function [ t,mu,dmudt,firing ] = runHasan(muscle, muscleVel, modelflag )
%Hasan model for spindle output estimation
% CASES:
% CASE 1: Primary Ending with Dynamic Gamma
% CASE 2: Primary Ending with Static Gamma
% CASE 3: Secondary Deefferented
% CASE 4: Primary Deefferented


%% MODEL PARAMETER SETUP %%

    switch modelflag
        
        case 1 % Primary ending w/ Dynamic Gamma
            a = 0.1;   % mm/s
            b = 125;   % unitless
            c = -15;   % change from maximum in situ length, mm
            h = 250;   % Linear gain, spikes/(s*mm)
            p = 0.1;   % Derivative gain, s
            g = 1;     % Length gain (not in original model)
            offset = 0;% Not included in Hasan model, but mentioned in 1983 paper
        case 2 % Primary ending w/ Static Gamma
            a = 100;
            b = 100;
            c = -25;
            h = 200;
            p = 0.01;
            g = 1;
            offset = 0;
        case 3 % Secondary Deeferented
            a = 50;
            b = 250;
            c = -20;
            h = 80;
            p = 0.1;
            g = 1;
            offset = 0;
        case 4 % Primary Deeferented
            a = 0.3;
            b = 250;
            c = -15;
            h = 350;
            p = 0.1;
            g = 1;
            offset = 0;
    end




%% RUN HASAN MODEL %%

[t,mu,dmudt,firing] = hasan(a,b,c,h,p,g,offset,linspace(0, 50*length(muscle), length(muscle)),muscleVel,muscle);



end

