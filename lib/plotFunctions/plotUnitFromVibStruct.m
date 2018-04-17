function [ fh ] = plotUnitFromVibStruct( vibStruct, params )
% plotUnitFromVibStruct:
% This function serves as a way to plot units that weren't initially
% included in the units that I was looking at. This can show taht other
% units are active when vibrating a muscle. The code is pretty self
% explanatory.
        figure
        unitNum = 1;
        if nargin > 1 && ~isempty(params)
        assignParams(who,params); % overwrite parameters
        end
        
        plot(vibStruct.vibOn.t, vibStruct.vibOn.flag)
        ylim([-.1,1.2])
        hold on
        yyaxis right
        plot(vibStruct.otherUnits.t, smooth(vibStruct.otherUnits.firing(:,unitNum)))

end

