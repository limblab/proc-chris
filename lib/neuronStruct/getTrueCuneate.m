function trueCuneateFlag = getTrueCuneate(td, params)
%%%%%%
%   The purpose of this function is to generate a flag which only includes
%   units that are from 'CUNEATE' proper. EG, it segregates based on which
%   units fall into the area of the array that is primarily gracile versus
%   the cuneate array. 
%   Inputs
%   td: (which must be computed so that there are electrode names, and p
%   params: which are 
%       .array: the array name (RightCuneate typically)
%       .cutoff: where the end of the cuneate is. For the default, any
%       channels less than 40 Lando's array were pretty much gracile.


cutoff = 40;
    array = 'cuneate';
    
    if nargin > 1, assignParams(who,params); end % overwrite parameters

    trueCuneateFlag = zeros(length(td(1).([array, '_spikes'])(1,:)),1);
    naming = td(1).([array, '_naming']);
    screenName = naming(:,2);
    compName = naming(:,1);
    for  i = 1:length(td(1).([array, '_spikes'])(1,:))
        temp=td(1).([array, '_unit_guide'])(i);
        num = screenName(compName==temp);
        
        if num>cutoff
            trueCuneateFlag(i,1) = 1;
        end
    end
end

