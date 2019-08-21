%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function trial_data = getNorm(trial_data, params)
%
%   Takes the norm at each time point. Instead of params struct, can pass
% in signals.
%
% INPUTS:
%   trial_data : THE STRUCT
%   params     : parameter struct
%       .signals   : (string/cell) which signal(s) to use
%       .field_extra : (string/cell) field name to use for the stored norm.
%                      Default (empty) will just append '_norm'
%                      after the signal of interest. NOTE that if multiple
%                      signals are requested, this should be a cell array
%                      of names for each!
%                      
%   NOTE : can pass signals in as second input instead of params struct
%
% OUTPUTS:
%   trial_data : the struct (with added norm field)
%
% EXAMPLES:
%   To compute speed from velocity signals ('vel')
%       trial_data = getNorm(trial_data,struct('signals','vel','norm_name','speed');
%
% Written by Matt Perich. Updated October 2018.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trial_data  = getSpeed(trial_data,params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
signals      =  'vel'; % which signals to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some undocumented extra parameters
field_new  =  'speed';   % if empty, defaults to input field name(s)
verbose      =  false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin > 1
    assignParams(who,params);
end
if isempty(signals), error('Must  define signals!'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trial_data = check_td_quality(trial_data);
signals = check_signals(trial_data,signals);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% take norm for all trials and signals
for trial = 1:length(trial_data)
    for iSig = 1:size(signals,1)
        data = getSig(trial_data(trial),signals(iSig,:));
        n_time = size(data,1);
        new_data = zeros(n_time,1);
        for t = 1:n_time
            new_data(t) = norm(data(t,signals{iSig,2}));
        end
        
        trial_data(trial).([field_new]) = new_data;
    end
end