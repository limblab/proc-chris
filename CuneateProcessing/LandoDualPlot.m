close all
window = [90,120];
t = ex.bin.data.t;
vx = ex.bin.data.vx;
vy = ex.bin.data.vy;
speed = sqrt(vx.^2 + vy.^2);
fx = ex.bin.data.fx;
fy = ex.bin.data.fy;
ax = ex.bin.data.ax;
ay = ex.bin.data.ay;
force = sqrt(fx.^2 + fy.^2);
dforce = diff(force);
accel = sqrt(ax.^2 + ay.^2);
names= ex.bin.data.Properties.VariableNames;
names = names(75:end);
unitNum = 234;
cuneateUnits = cds.units([strcmp({cds.units.array}, 'Cuneate')] & [cds.units.ID]>0 & [cds.units.ID]<255);
elec48unit3 = ex.bin.data.CuneateCH48ID3;
% for i = 1:length(names)
%     figure('Position', [50,50,1400,600])
%     unit = ex.bin.data.(names{i});
%     yyaxis left
%     %plot(t(2:end)-.025,dforce)
%     plot(t,force)
%     hold on
%     ylabel('Handle Force (Newtons)')
%     yyaxis right
%     plot(t, smooth(unit,3))
%     xlim(window)
%     ylabel('Firing Rate (hz)')
%     title(names{i})    
%     unitFiring = cds.units(unitNum).spikes.ts;
%     firstInWindow = find(unitFiring > window(1),1);
%     lastInWindow = find(unitFiring > window(2),1)-1;
%     for j = firstInWindow:lastInWindow
%         scatter([unitFiring(j), unitFiring(j)], [90, 95], 'k')
% 
%         hold on
%     end
% end

for i = 1:length(names)
    figure('Position', [50,50,1400,600])
    unit = ex.bin.data.(names{i});
    yyaxis left
    %plot(t(2:end)-.025,dforce)
    plot(t,speed)
    hold on
    ylabel('Handle Accel (cm/s^2)')
    yyaxis right
    plot(t, smooth(unit,3))
    xlim(window)
    ylabel('Firing Rate (hz)')
    title(names{i})
end