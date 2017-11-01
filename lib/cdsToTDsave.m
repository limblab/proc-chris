function [td ] = cdsToTDsave( cds )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    params.include_ts = true;
    params.event_list = {'bumpTime';'bumpDir'; 'ctrHold'; 'goCueTime';'ctrHoldBump'};
    td = parseFileByTrial(cds, params);

end

