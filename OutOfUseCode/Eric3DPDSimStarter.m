%% Get B0, B1, B2, B3 from uniform distriubiton of PDs some assumptions for B0 term

%% Get reach speeds for each direction

%% Calcuate firing rates and simulate spiking
lambda = exp(b0 + b1*xdot + b2*ydot + b3*zdot);
spikes = poissrnd(lambda);

%% Fit models 
model = fitglm([xdot, ydot, zdot], spikes)

%% Calculate PDS and compare to input distribution