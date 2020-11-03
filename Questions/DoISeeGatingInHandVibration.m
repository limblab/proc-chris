clearvars -except td
monkey = 'Rocket';
date = '20200722';
num = 1;
task = 'COhandlevib';

if ~exist('td')
    td = getTD(monkey, date, task, num);
    td([td.idx_endTime]>7000) = [];
    td = getHandleVib(td);
    td = binTD(td, 5);
    td = getSpeed(td);
    td = getMoveOnsetAndPeak(td);
    td  = smoothSignals(td, struct('signals', 'cuneate_spikes', 'calc_rate', true));
    td = removeUnsorted(td);
end
%% Figure out which neurons respond to vibration
guide = td(1).cuneate_unit_guide;
firing = cat(1,td.cuneate_spikes);
vibOn = logical(cat(1,td.vibOn));
vibOff = ~vibOn;
speed = cat(1,td.speed);
vel = cat(1,td.vel);
velOn = vel(vibOn,:);
velOff = vel(vibOff,:);
speedOn = speed(vibOn);
speedOff = speed(vibOff);
figure
histogram(speedOn)
hold on
histogram(speedOff);

for i = 1:length(guide(:,1))
    nFir = firing(:,i);
    firingOn = nFir(vibOn);
    firingOff = nFir(vibOff);
    
    
    
    
    onLM = fitlm(velOn, firingOn);
    offLM = fitlm(velOff, firingOff);
    
    
    
    figure
    plot(onLM)
    hold on
    plot(offLM)
    title(['Elec ', num2str(guide(i,1)), ' Unit ', num2str(guide(i,2))])


end