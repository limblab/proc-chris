%%
clear all 
close all
date = '20171116';
monkey = 'Han';
array = 'S1';

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;

td =getTD(monkey, date, 'CO');
td = normalizeTDLabels(td);
%%
if ~isfield(td, 'idx_movement_on')
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    td = getMoveOnsetAndPeak(td, params);
end

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
param.arrays = {array};
param.in_signals = {'vel'};
param.train_new_model = true;

params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
param.windowAct= windowAct;
param.windowPas =windowPas;
param.date = date;
if td(1).bin_size == .001
    td=binTD(td, 10);
    td = getMoveOnsetAndPeak(td,params);
    td = td(~isnan([td.idx_movement_on]));
end
%%
