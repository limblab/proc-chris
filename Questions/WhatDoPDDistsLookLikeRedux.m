
monkVec = [13:19];
for i = 7
    monkNum = monkVec(i);
    td = getPaperFiles(monkNum,10);
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td);
    td = getMoveOnsetAndPeakBackTrace(td);
    td = removeUnsorted(td);
    td = removeGracileTD(td);
    tdAct = trimTD(td, 'idx_movement_on_min', {'idx_movement_on_min', 40});
    tdPas = td(~isnan([td.idx_bumpTime]));
    tdPas = trimTD(tdPas, 'idx_bumpTime', {'idx_bumpTime', 13});
    array = getArrayName(td);
    guide = td(1).([array, '_unit_guide']);
    params = struct('out_signals', [array, '_spikes'],'out_signal_names',guide,  'in_signals', 'vel', 'num_boots', 100);
    pdAct{i} = getTDPDs(tdAct, params);
    pdPas{i} = getTDPDs(tdPas, params);

end
%%
close all
% keyboard
actPDsComb = [];
pasPDsComb = [];
for i =1:7
    
    actTuned{i} = isTuned(pdAct{i}.velPD, pdAct{i}.velPDCI, pi/3);
    pasTuned{i} = isTuned(pdPas{i}.velPD, pdPas{i}.velPDCI, pi/3);
    actPDs = pdAct{i}.velPD;
    temp = pdAct{i};
    monkey = temp.monkey(1);
    pasPDs = pdPas{i}.velPD;
    actPDs(~actTuned{i} | ~pasTuned{i})=[];
    pasPDs(~actTuned{i} | ~pasTuned{i})=[];
    figure
    polarhistogram(actPDs, -pi:pi/8:pi)
    title([monkey, ' Act ', num2str(i)])
    figure
    polarhistogram(pasPDs, -pi:pi/8:pi)
    
    title([monkey, ' Pas ', num2str(i)])
    
    figure
    scatter(actPDs, pasPDs)
    hold on
    plot([-pi, pi], [-pi, pi])
    title([monkey, ' ActvsPas'])
    
    actPDsComb = [actPDsComb; actPDs];
    pasPDsComb = [pasPDsComb; pasPDs];
    
end
%%
figure
scatter(actPDsComb, pasPDsComb)
hold on
plot([-pi, pi], [-pi, pi])
title([monkey, ' ActvsPas'])

figure
polarhistogram(actPDsComb,  -pi:pi/8:pi)
title('Active')
figure
polarhistogram(pasPDsComb,  -pi:pi/8:pi)
title('Passive')

