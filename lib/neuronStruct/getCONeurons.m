function [ neuronStruct] = getCONeurons( td, params )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    arrays = {'area2', 'cuneate'};
    date = '';
    task = 'CO';
    monkey =  'Lando';
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    params.move_corr =  've';
    
    out_signals      =  [];
    out_signal_names = {};
    use_trials        =  1:length(trial_data);
    move_corr      =  'vel';
    num_bins     = 4;
    
    [tuningCurves, bins] = getTuningCurves(td, params);
    
    pdFits = getTDPDs(td, params);
    
end

