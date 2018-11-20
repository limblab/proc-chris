function td = linNonLinTimewarpTD(td, params)
    model_name    =  'default';
    in_signals    =  {};% {'name',idx; 'name',idx};
    out_signals   =  {};% {'name',idx};
    num_folds     =  20;
    plot_on       =  false;
    onlySorted    =  true;
    
    quest = 0;
    % Choose model for GLM
    model_num = 8; % 8 = basic, 10 = comprehensive without directional tuning, 11 = comprehensive

    % Choose properties of data to use
    FR_thresh_Hz = 2; 
    dt = .01;
    FR_thresh = FR_thresh_Hz*dt;

    real_data = 1; % 1 = real data from monkey; 0 = simulated data
    num_nrn_desired = 93;
    warp_type = 'strong'; % If using simulated data, selects data file. Use 'strong', 'weak', or 'none'.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin >1; assignParams(who,params);end % overwrite parameters
    
    [spikes_all_preselect, max_num_trials, movement_data_all, num_nrn, kinematics]= loadTimewarpData(td);
    transition_priors = [0 1; 0 1; 0 1]; 
    transition_prior_scale = 1; % Determines the relative weight of the prior relative to the neural data. Default 1. 
    transition_priors = transition_priors/sum(sum(transition_priors)); % Normalizes the transition matrix so that they sum to 1. 
    transition_priors = log(transition_priors); % Takes the log of the transition matrix; this is how it appears in the optimization equations.
    transition_priors = transition_prior_scale*transition_priors; 

    fit_method = 'lassoglm'; % GLM fitting method. Options: glmfit, lassoglm, glmnet. Default is lassoglm (regularized). Glmfit is unregularized. Glmnet is the fastest but requires downloading the package and can sometimes cause segfaults.
    num_CV = 2; % Number of trial-wise cross-validation folds. Default is 2.
    num_WV = 10; % Number of neuron-wise cross-validation folds. Default is 10.

    tol_type = 'relTol'; % Rule that the code uses to terminate alternation for fitting LNP+DTW model. Default is relative tolerance, 'relTol'. Options: 'relTol','absTol','maxIter'
    conv_thresh = 1e-4; % Tolerance for convergence detection when using 'relTol'. Equals dLLHD/LLHD. Default is 1e-4.

    max_iter = 10; % Max number of altnerating iterations. Default is 10.

    alpha = 0.01; % Regularization type (L1 vs L2). Alpha small = L2; alpha 1 = L1. Default is 0.01.
    lambda = 0.05; % Regularization strength. Default is 0.05.

    trials = 1:max_num_trials;
    neurons = 1:num_nrn;

    do_shuffle = 0; % Shuffle control: apply learned warps to wrong trials

    include_spk_history = 0; % Include spike history terms. This adds an extra iteration. 
    num_spk_history_bf = 5; % Number of temporal basis functions to use for spike history

    % Simulation parameters
    num_rep = 10; % Number of times to resample neurons and refit model. 
    % neurons = 1:num_nrn_desired; % For simulations

    % Some file save path initialization

    Results_fname_datatype = 'RealData';
    Results_fname_base = [Results_fname_datatype '_' num2str(num_nrn_desired) 'nrn_' num2str(length(trials)) 'tr'];


    Results_fpath = '.\results\';
    datetimestr = datestr(now,'mm-dd-yy--HH-MM');
    data_fname = 'ButterLNTWP03262018';
    initialize 

    %% Process

    process

    %% Fit model

    fit_model
    
    for i = 1:length(td)
        td(i).cuneate_spikes_warped = [spikes_warped{i, :,1}];
    end
end