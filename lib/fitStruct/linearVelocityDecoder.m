function [tdVel, modelInfo] = linearVelocityDecoder(td,paramDecode)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    flag = 1:length(td(1).cuneate_spikes(1,:));
    if nargin > 1, assignParams(who,paramDecode); end % overwrite parameters
    
    paramDecode.model_type    =  'linmodel';
    paramDecode.model_name    =  'velocityDecoding';
    paramDecode.in_signals    =  {'cuneate_spikes', flag};% {'name',idx; 'name',idx};
    paramDecode.out_signals   =  {'vel'};% {'name',idx};
    paramDecode.train_idx     =  1:length(td);

    [tdVel, modelInfo] = getModel(td, paramDecode);

    % Evaluate the model
    paramEval.model_type       =  'linmodel';
    paramEval.out_signals      =  ['vel'];
    paramEval.model_name       =  ['velocityDecoding'];
    paramEval.trial_idx        =  [1,length(td)];
    paramEval.eval_metric      =  'vaf';
    paramEval.block_trials     =  false;
    paramEval.num_boots        =  1;

    r2Vel = evalModel(tdVel, paramEval)

    vel = cat(1, tdVel.vel);
    pVel = cat(1, tdVel.linmodel_velocityDecoding);
    figure
    scatter(vel(:,1), pVel(:,1))
    figure
    scatter(vel(:,2), pVel(:,2))
end

