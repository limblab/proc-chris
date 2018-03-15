close all
spikes = zeros(96, 1);
for i = 1:length(cds.units)
    if length(cds.units(i).label) ==6
        unitNum = str2num(cds.units(i).label(end-1:end));
    else 
        unitNum = str2num(cds.units(i).label(end));
    end
    spikes(unitNum) = height(cds.units(i).spikes(:,1));
end
spikes10 = log10(spikes);
spikes10(spikes10 == -Inf) = -1;
scatter(measuredImp', spikes10)
xlabel('Measured impedance (kOhms)')
ylabel('log10(Number of Spikes on channel)')
title('Relationship between impedance measured and spikes recorded on file')