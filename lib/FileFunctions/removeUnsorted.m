%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [trial_data,bad_units] = removeBadNeurons(trial_data,params)
% 
%   Checks for shunts or duplicate neurons based on coincidence, and also
% removes low-firing cells.
%
% INPUTS:
%   trial_data : the struct
%   params     : parameter struct
%     .arrays         : list of arrays to work on
%     .do_shunt_check : flag to look for coincident spiking
%     .prctile_cutoff : value (0-100) for empirical test distribution
%     .do_fr_check    : flag to look for minimum firing rate
%     .min_fr         : minimum firing rate value to be a good cell
%     .fr_window      : when during trials to evaluate firing rate
%                           {'idx_BEGIN',BINS_AFTER;'idx_END',BINS_AFTER}
%     .use_trials     : can only use a subset of trials if desired
%
% OUTPUTS:
%   trial_data : the struct with bad_units removed
%   bad_units  : list of indices in the original struct that are bad
%
% Written by Matt Perich. Updated Feb 2017.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trial_data,bad_units] = removeUnsorted(trial_data,params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT PARAMETERS
arrays          =  [];
use_trials      =  1:length(trial_data);
if nargin > 1, assignParams(who,params); end % overwrite defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isstruct(trial_data), error('First input must be trial_data struct!'); end

bin_size        =  trial_data(1).bin_size;
if iscell(use_trials) % likely to be meta info
    use_trials = getTDidx(trial_data,use_trials{:});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(arrays) % get all spiking arrays
    arrays = getTDfields(trial_data,'spikes');
    for a = 1:length(arrays)
        arrays{a} = strrep(arrays{a},'_spikes','');
    end
else
    if ~iscell(arrays), arrays = {arrays}; end
end

for a = 1:length(arrays)
    array = arrays{a};
    
    all_spikes = cat(1,trial_data(use_trials).([array '_spikes']));
    
    bad_units = zeros(1,size(all_spikes,2));
    
    bad_units = [trial_data(1).([array, '_unit_guide'])(:,2) == 0]';
    
    disp([arrays{a} ': found ' num2str(sum(bad_units)) ' bad units.']);
    
    % now remove the bad cells
    if sum(bad_units) > 0
        for trial = 1:length(trial_data)
            temp = trial_data(trial).([array '_spikes']);
            temp(:,bad_units) = [];
            trial_data(trial).([array '_spikes']) = temp;
            temp = trial_data(trial).([array '_unit_guide']);
            temp(bad_units,:) = [];
            trial_data(trial).([array '_unit_guide']) = temp;
%             temp = trial_data(trial).([array '_ts']);
%             temp(bad_units) = [];
%             trial_data(trial).([array '_ts'])= temp;
        end
        bad_units = find(bad_units);
    else
        bad_units = [];
    end
end

end


