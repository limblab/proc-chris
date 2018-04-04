% hasanDriver.m
%
% Created 2013/06 by Kyle P. Blum
% Modified 2017/05 by Kyle P. Blum
% 1) Added in descriptions of parameters and organized code into sections
%
% This script initializes simulations for the Hasan 1983 muscle spindle
% model. There are 4 models outlined in the Hasan 1983 paper: 1) Primary
% ending with dynamic gamma, 2) Primary ending with static gamma, 3)
% Secondary deeferented ending, and 4) Primary deeferented ending. 



modelflag = 1;


models = {'Triangle Response Model','Primary Dynamic Gamma'...
    'Primary Static Gamma','Secondary Deefferented',...
    'Primary Deefferented'};
perts = {'Ramp & Hold Pert'};





%% PERTURBATION SETUP %%


% Ramp, hold, and return
        dt = 0.001;
        x0 = 10;                       % Initial Length of sensory + nonsensory ending
        stretch_amp = 5;               % mm
        max_len = x0 + stretch_amp;    % 
        max_vel = 20;                   % mm/s
        max_acc = 1000;              % mm/s^2
        rampdown = 1;
        [t_x,~,dxdt,x] = rampandhold(max_len,max_vel,max_acc,x0,dt,rampdown);


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

[t,mu,dmudt,rBrach1] = hasan(a,b,c,h,p,g,offset,linspace(0, 50*length(brachialisVel), length(brachialisVel)),brachialisVel*1000,brachialisLength*1000);

