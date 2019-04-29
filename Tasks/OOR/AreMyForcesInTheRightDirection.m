%% Load the td
close all
clear all

plotTrajectories = false;
plotForceReach = false;

monkey = 'Butter';
date = '20190129';
% mappingLog = getSensoryMappings(monkey);
td =getTD(monkey, date, 'CO',2);

td(mod([td.bumpDir], 45)~=0) = [];
array = getTDfields(td, 'arrays');
array_spikes = [array{1}, '_spikes'];
array_unit_guide = [array{1}, '_unit_guide'];
reachWindow = {{'idx_bumpTime', 0}, {'idx_bumpTime', 125}};

labels = {'$\rightarrow$', '$\nearrow$', '$\uparrow$', '$\nwarrow$', '$\leftarrow$', '$\swarrow$','$\downarrow$', '$\searrow$'};
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'ForceVelPDs',filesep];
mkdir(savePath);

td1 = trimTD(td, {'idx_bumpTime', 50}, {'idx_bumpTime', 125});
td1 = binTD(td1, 10);

forceDirVec = [];

dirsAct = unique([td1.bumpDir]);
% dirsForce = unique([td1.forceDir]);
dirsAct = dirsAct(~isnan(dirsAct));
% dirsForce= dirsForce(~isnan(dirsForce));
colors = linspecer(8);
%%
f1 = figure2();
hold on

for i = 1:length(dirsAct)
   f1;
   tdReachForce = td1([td1.bumpDir] == dirsAct(i));
   force = cat(1, tdReachForce.force);
   vel = cat(1, tdReachForce.vel);
   scatter(vel(:,1), vel(:,2),36, colors(i,:), 'filled')
   
%    figure2();
%    hold on
%    for j = 1:length(dirsAct)
%        tdAct = tdReachForce([tdReachForce.tgtDir] == dirsAct(j));
%        forceAct = mean(cat(1, tdAct.force));
%        scatter(forceAct(:,1), forceAct(:,2), 36, colors(j,:), 'filled')
%    end
%    legend('0','45', '90', '135', '180', '225', '270', '315')
% 
%    pause
end
%%
f1;
legend('0','45', '90', '135', '180', '225', '270', '315')
title('Vel')

f2 = figure2();
hold on
for i = 1:length(dirsAct)
   f1;
   tdReachForce = td1([td1.bumpDir] == dirsAct(i));
   force = cat(1, tdReachForce.force);
   vel = cat(1, tdReachForce.vel);
   scatter(force(:,1), force(:,2),36, colors(i,:), 'filled')
   

end
legend('0','45', '90', '135', '180', '225', '270', '315')
title('Force')
%%

