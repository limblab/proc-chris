
for i = 2:12
    td = getPaperFiles(i,10);
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td);
    td = removeUnsorted(td);
    tdAct = trimTD(td, 'idx_movement_on', {'idx_movement_on', 13});
    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, 'idx_bumpTime', {'idx_bumpTime', 13});
    array = getArrayName(td);
    guide = td(1).([array, '_unit_guide']);
    params = struct('out_signals', [array, '_spikes'],'out_signal_names',guide,  'in_signals', 'vel', 'num_boots', 100);
    pdAct{i} = getTDPDs(tdAct, params);
    pdPas{i} = getTDPDs(tdPas, params);

    actTuned{i} = isTuned(pdAct{i}.velPD, pdAct{i}.velPDCI, pi/2);
    pasTuned{i} = isTuned(pdPas{i}.velPD, pdPas{i}.velPDCI, pi/2);
end
%%
close all
% keyboard
for i =1:12
    actPDs = pdAct{i}.velPD;
    temp = pdAct{i};
    monkey = temp.monkey(1);
    pasPDs = pdPas{i}.velPD;
    actPDs(~actTuned{i})=[];
    pasPDs(~pasTuned{i})=[];
    figure
    polarhistogram(actPDs, 0:pi/8:2*pi)
    title([monkey, ' Act ', num2str(i)])
    figure
    polarhistogram(pasPDs, 0:pi/8:2*pi)
    
    title([monkey, ' Pas ', num2str(i)])
end