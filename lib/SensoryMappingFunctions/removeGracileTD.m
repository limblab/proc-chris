function [td] = removeGracileTD(td,params)
%REMOVEGRACILETD Summary of this function goes here
%   Detailed explanation goes here
    % now remove the bad cells
    array = 'cuneate';
    removeUnsorted= true;
    if nargin > 1, assignParams(who,params); end % overwrite defaults
    [~, bad_units] = getTDCuneate(td);
    bad_units = ~bad_units;
    bad_units = bad_units | td(1).([array, '_unit_guide'])(:,2) == 0;
    disp(['Removing ', num2str(sum(bad_units)), ' due to Gracile'])

    if sum(bad_units) > 0
        for trial = 1:length(td)
            temp = td(trial).([array '_spikes']);
            temp(:,bad_units) = [];
            td(trial).([array '_spikes']) = temp;
            temp = td(trial).([array '_unit_guide']);
            temp(bad_units,:) = [];
            td(trial).([array '_unit_guide']) = temp;
            temp = td(trial).([array '_ts']);
            temp(bad_units) = [];
            td(trial).([array '_ts']) = temp;
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

