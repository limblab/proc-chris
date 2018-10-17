
plotRasters = 1;
savePlots = 1;
params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
params.extra_time = [.4,.6];
td = parseFileByTrial(cds, params);
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getMoveOnsetAndPeak(td, params);
tdBump = td(~isnan([td.idx_bumpTime]));
%%
totalMove = cat(1, td.vel);
totalFiring = cat(1,td.RightCuneate_spikes);
curve = getTuningCurves(totalMove, totalFiring(:,4));
fr = curve.binnedFR;
theta = linspace(0,2*pi, 9);
rho = [fr, fr(1)];



%% Move
close all
for unitNum = 1:length(td(1).RightCuneate_spikes(1,:))
    xVel = [];
    cNeuronsActive = [];
    for i = 1:length(td)
        xVel = [xVel; td(i).vel(td(i).idx_movement_on: td(i).idx_movement_on + 10,:)];
        cNeuronsActive = [cNeuronsActive; td(i).RightCuneate_spikes(td(i).idx_movement_on: td(i).idx_movement_on + 10,:)];
    end
    [curveActive, bins] = getTuningCurves(xVel, cNeuronsActive(:,unitNum));
    fr = curveActive.binnedFR;
    theta = [bins, bins(1)];
    rho = [fr, fr(1)];


    %% Bump
    xVel = [];
    cNeuronsPassive = [];
    for i = 1:length(tdBump)
        xVel = [xVel; tdBump(i).vel(tdBump(i).idx_bumpTime: tdBump(i).idx_bumpTime + 10,:)];
        cNeuronsPassive = [cNeuronsPassive; tdBump(i).RightCuneate_spikes(tdBump(i).idx_bumpTime: tdBump(i).idx_bumpTime + 10,:)];
    end
    %%
    cNeurons1 = cNeuronsPassive(:,unitNum);
    cNeuronsPassiveSamp= cNeurons1(ind);
    curvePassive = getTuningCurves(xVelSamp, cNeurons1);
    curvePassive.bins = bins;
    curveActive.bins = bins;
    curvePassive.unit_ids= td(1).RightCuneate_unit_guide(unitNum,:);
    curveActive.unit_ids= td(1).RightCuneate_unit_guide(unitNum,:);
    [figHandles,output] = rotate_tuning_curves(curvePassive, curveActive);
end
%%

