function [td] = removeGracileTD(td,params)
%REMOVEGRACILETD Summary of this function goes here
%   Detailed explanation goes here
    % now remove the bad cells
    array = 'cuneate';
    
    if nargin > 1, assignParams(who,params); end % overwrite defaults
    [~, bad_units] = getTDCuneate(td);
    bad_units = ~bad_units;
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
        end
        bad_units = find(bad_units);
    else
        bad_units = [];
    end
end

