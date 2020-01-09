function td = removeNeuronsByNeuronStruct(td, params)
flags = {'handPSTHMan'};
windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
array = 'cuneate';

if nargin > 1, assignParams(who,params); end % overwrite defaults
if ~isstruct(td), error('First input must be trial_data struct!'); end
neurons = getNeurons(td(1).monkey, dateToLabDate(td(1).date),td(1).task, array,[windowAct; windowPas]);
guide = td(1).cuneate_unit_guide;
bad_units = false(length(guide(:,1)),1);

for i = 1:length(guide(:,1))
    for j = 1:length(flags)
       flag1 = flags{j};
       elec = guide(i,1);
       unit = guide(i,2);
       neuron = neurons([neurons.chan] == elec & [neurons.ID] == unit,:);
       if strcmp(flag1(1), '~')
           bad_units(i) = bad_units(i) | ~neuron.(flag1(2:end));
       else
           bad_units(i) = bad_units(i) | neuron.(flag1); 
       end
    end
end



disp(['Removing ', num2str(sum(bad_units)), ' due to neuron struct'])
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