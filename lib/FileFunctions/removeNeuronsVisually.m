function td = removeNeuronsVisually(td, params)
array          =  'cuneate';
units1        =  [];
if nargin > 1, assignParams(who,params); end % overwrite defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isstruct(td), error('First input must be trial_data struct!'); end

bin_size        =  td(1).bin_size;
date = td(1).date;
monkey = td(1).monkey;


guide = td(1).([array,'_unit_guide']);

all_spikes = cat(1,td.([array '_spikes']));

bad_units = zeros(1,size(all_spikes,2));
[~,asdf] = intersect(guide,units1,'rows')
bad_units(asdf) = true;

disp(['Removing ', num2str(sum(bad_units)), ' due to sensory mapping'])
bad_units = logical(bad_units);
% now remove the bad cells
if sum(bad_units) > 0
    for trial = 1:length(td)
        temp = td(trial).([array '_spikes']);
        temp(:,bad_units) = [];
        td(trial).([array '_spikes']) = temp;
        temp = td(trial).([array '_unit_guide']);
        temp(bad_units,:) = [];
        td(trial).([array '_unit_guide']) = temp;
        if isfield(td(trial), [array, '_ts'])
            temp = td(trial).([array '_ts']);
            temp(bad_units) = [];
            td(trial).([array '_ts'])= temp;
        end
    end
    bad_units = find(bad_units);
else
    bad_units = [];
end
end