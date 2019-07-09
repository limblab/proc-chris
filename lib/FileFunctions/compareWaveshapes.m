function [bestMatch, sse] = compareWaveshapes(monkey,task, date1, date2)
    cds1= getCDS(monkey, task, date1);
    units1 = cds1.units;
    units1 = units1([units1.ID] >0);
    clear cds1
    cds2 = getCDS(monkey,task, date2);
    units2 = cds2.units;
    units2 = units2([units2.ID] >0);

    clear cds2
    
    for i = 1:length(units1)
      unitsT = units2(units1(i).chan == [units2.chan]);
      wave1 = mean(units1(i).spikes.wave);
      close all
      figure
      plot(wave1)
      hold on
      bestMatch(i) = 0;
       for j = 1:length(unitsT)
           
           wave2 = mean(unitsT(j).spikes.wave);
           plot(wave2)
           waveComp{i}(j) = sum(rownorm([wave1', wave2']));
       end
       [~,bestMatch(i)] = min(waveComp{i});
    end
    sse = waveComp;
end