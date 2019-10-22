function td = removeNeuronsBySensoryMap(td, params)
array          =  'cuneate';
rfFilter        =  {};
if nargin > 1, assignParams(who,params); end % overwrite defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isstruct(td), error('First input must be trial_data struct!'); end

bin_size        =  td(1).bin_size;
date = td(1).date;
monkey = td(1).monkey;
map = getSensoryMappings(monkey);


guide = td(1).([array,'_unit_guide']);

all_spikes = cat(1,td.([array '_spikes']));

bad_units = zeros(1,size(all_spikes,2));

bad_units = [td(1).([array, '_unit_guide'])(:,2) == 0]';

for j = 1:length(guide(:,1))
    map1 = map([map.elec] == guide(j,1) & datetime(date, 'InputFormat', 'MM-dd-yyyy') == datetime(string({map.date}), 'InputFormat', 'yyyyMMdd'));
    if ~isempty(map1)
        map1.mapped = true;
        mapComp(j,:) = map1;
    else
        map1(1).mapped = false;
        map1(1).date  ='na';
        map1(1).chan = 0;
        map1(1).id = 0;
        map1(1).pc = '?';
        map1(1).desc = 'na';
        map1(1).spindle = false;
        map1(1).handUnit= false;
        map1(1).proximal = false;
        map1(1).midArm =false;
        map1(1).distal = false;
        map1(1).cutaneous = false;
        map1(1).proprio= false;
        map1(1).row = 0;
        map1(1).col = 0;
        map1(1).elec = 0;
        mapComp(j,:) = map1;
    end
end
    

for i = 1:length(rfFilter(:,1))
    flag1 = [mapComp.(rfFilter{i,1})] == rfFilter{i,2} | ~[mapComp.mapped];
    bad_units = bad_units | flag1;
end

disp(['Removing ', num2str(sum(bad_units))])
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