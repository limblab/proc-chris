function [ td ] = easyTD(cds, params)
% easyTD Function to run through all needed analysis and save TD file with
% everything together.
%   Detailed explanation goes here

include_ts = true;
include_start = true;
include_naming = true;
extra_time = [.4, .6];
extraEvents = {};
if nargin > 1, assignParams(who,params); end % overwrite defaults

params.motionTrack = motionTrack;
params.include_ts = include_ts;
params.include_start = include_start;
params.include_naming = include_naming;
params.extra_time = extra_time;
params.extraEvents= extraEvents;
td = parseFileByTrial(cds, params);
end

