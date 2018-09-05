function [td, cunFlag] = getTDCuneate(td, params)
    doCuneate = true;
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    monkey = td(1).monkey;
    if doCuneate
    for i = 1:length(td(1).cuneate_unit_guide(:,1))
        cunFlag(i) = ~getGracile(monkey, td(1).cuneate_naming(find(td(1).cuneate_naming(:,1)==td(1).cuneate_unit_guide(i,1)),2));
    end
    
    cunFlag = cunFlag';
    else
        cunFlag = ones(length(td(1).LeftS1_spikes(1,:)),1);
    end
    
%     td.cunFlag = repmat({cunFlag}, length(td),1);
end