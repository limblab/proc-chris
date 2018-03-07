function datasetPath =  saveLFADSdatasets(td, params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
condition = 'NA';
monkey = 'NA';
date = 'NA';
runName = 'NA'
if nargin > 1, assignParams(who,params); end % overwrite defaults

td = td(~isnan([td.target_direction]));
td = getMoveOnsetAndPeak(td);
tdGo = trimTD(td, {'idx_goCueTime', -20}, {'idx_goCueTime', 40});
tdMove = trimTD(td, {'idx_movement_on', -10}, {'idx_movement_on', 30});
tdPeak = trimTD(td, {'idx_peak_speed', -20}, {'idx_peak_speed', 20});
tdEnd = trimTD(td, {'idx_endTime', -50}, {'idx_endTime', 0});

filename = [monkey, '_',date, '_td_'];

td = tdGo;
save(['/media/chris/HDD/Data/MonkeyData/LFADSData/' , filename, 'goCue.mat'] , 'td')
td = tdMove;
save(['/media/chris/HDD/Data/MonkeyData/LFADSData/' , filename, 'moveOn.mat'], 'td')
td = tdPeak;
save(['/media/chris/HDD/Data/MonkeyData/LFADSData/' , filename, 'peak.mat'], 'td')
td = tdEnd;
save(['/media/chris/HDD/Data/MonkeyData/LFADSData/' ,monkey, filesep, date,filesep, filename, 'endTime.mat'], 'td')

datasetPath = ['/media/chris/HDD/Data/MonkeyData/LFADSData/', runName, filesep];
end

