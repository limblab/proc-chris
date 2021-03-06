function td = removeNeuronsBySensoryMap(td, params)
array          =  'cuneate';
rfFilter        =  {};
daysDiffCutoff        = 1;
if nargin > 1, assignParams(who,params); end % overwrite defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isstruct(td), error('First input must be trial_data struct!'); end

bin_size        =  td(1).bin_size;
date1 = td(1).date;
monkey = td(1).monkey;
map = getSensoryMappings(monkey);
for i = 1:length(map)
    if isempty(map(i).elec)
        map(i).elec = -1;
    end
end
guide = td(1).([array,'_unit_guide']);

all_spikes = cat(1,td.([array '_spikes']));

bad_units = zeros(1,size(all_spikes,2));

bad_units = [td(1).([array, '_unit_guide'])(:,2) == 0]';

for j = 1:length(guide(:,1))
    mapsUnit = map([map.elec] == guide(j,1))
    
    daysDiff = days(datetime(date1, 'InputFormat', 'MM-dd-yyyy') - datetime(string({mapsUnit.date}), 'InputFormat', 'yyyyMMdd'));
    [daysDiffMin, ddInd] = min(abs(daysDiff));
        
    map1 = mapsUnit(ddInd,:);
    if daysDiffMin > daysDiffCutoff
        map1 = [];
    end
    if length(map1)>1
        map1(1).mapped = true;
        temp = join(horzcat(map1.desc));
        mapComp(j,:) = map1(1,:);
        mapComp(j).desc = temp;
    elseif ~isempty(map1)
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

for i = 1:length(mapComp)
    map1 = mapComp(i,:);
    gracile = getGracile(monkey, map1.chan);
    mapComp(i,:).isGracile = gracile;
    mapComp(i,:).isCuneate = ~gracile;
end

for i = 1:length(rfFilter(:,1))
    flag1 = [mapComp.(rfFilter{i,1})] == rfFilter{i,2};% | ~[mapComp.mapped];
    bad_units = bad_units | flag1;
end

disp(['Removing ', num2str(sum(bad_units)), ' due to sensory mapping'])
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
        if isfield(td(trial), [array, '_mapping_guide'])
            temp = td(trial).([array '_mapping_guide']);
            temp(bad_units,:) =[];
            td(trial).([array '_mapping_guide']) = temp;
        end
    end
    bad_units = find(bad_units);
else
    bad_units = [];
end
end