function [td] = rectifyTDSignal(td,params)
signals         =  []; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some extra parameters that aren't documented in the header
field_extra     =  '';   % if empty, defaults to input field name(s)
rect_type    =  'fw'; % will just return trial_data if this is false

if nargin > 1, assignParams(who,params); end % overwrite defaults
if isempty(field_extra)
    field_extra= ['_', rect_type];
end
td = check_td_quality(td);
bin_size = td(1).bin_size;
% make sure the signal input formatting is good
signals = check_signals(td(1),signals);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check output field addition
field_extra  = check_field_extra(field_extra,signals);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
for trial = 1:length(td)
    for iSig = 1:size(signals,1)
        data = getSig(td(trial),signals(iSig,1));
        if strcmp(rect_type, 'fw')
            data = abs(data);
        elseif strcmp(rect_type, 'hw')
            data(data<0) = 0;
        else
            error('Not a recognized rectification')
        end
        td(trial).([signals{iSig,1} field_extra{iSig}]) = data;
    end
end

end

