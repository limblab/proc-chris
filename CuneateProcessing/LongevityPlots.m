close all
plotNormalized = true;

daysLando1 = UnitLongevity1S2(:,3);
unitsLando1= UnitLongevity1S2(:,4);
unitsMaxLando = max(unitsLando1);
daysHan1= UnitLongevity1S2(:,7);
unitsHan1=UnitLongevity1S2(:,8);
unitsMaxHan = max(unitsHan1);
daysKramer1=UnitLongevity1S2(:,5);
unitsKramer1=UnitLongevity1S2(:,6);
unitsMaxKramer = max(unitsKramer1);
daysTequila1 = UnitLongevity1S2(:,1);
unitsTequila1 = UnitLongevity1S2(:,2);
unitsMaxTequila = max(unitsTequila1);
unitsOlive = 58;
daysOlive =  9;

if plotNormalized
    unitsLando1 = unitsLando1*100./96;
    unitsHan1 = unitsHan1*100/32;
    unitsKramer1 = unitsKramer1*100/32;
    unitsTequila1 = unitsTequila1*100/32;
    unitsOlive = 5800/96;
end
unitsTequila1 = unitsTequila1(~isnan(unitsTequila1));
daysTequila1 = daysTequila1(~isnan(daysTequila1));
unitsLando1 = unitsLando1(~isnan(unitsLando1));
daysLando1 = daysLando1(~isnan(daysLando1));
unitsKramer1 = unitsKramer1(~isnan(unitsKramer1));
daysKramer1 = daysKramer1(~isnan(daysKramer1));
unitsHan1 = unitsHan1(~isnan(unitsHan1));
daysHan1 = daysHan1(~isnan(daysHan1));
daysHan1(5:6) = [];
smoothparam = .00005;

landoFit = fit(daysLando1,unitsLando1,'smoothingspline', 'SmoothingParam', smoothparam);
scatter(daysLando1, unitsLando1, 'filled','k')
hold on
plot(landoFit, daysLando1, unitsLando1)

ylim([0,80])
xlabel('Days post implantation')
ylabel('# Units/ # Channels (%)')
set(gca,'TickDir','out')
title('Array Longevity')
hold on
scatter(daysHan1, unitsHan1,'filled', 'r')
hanFit = fit(daysHan1, unitsHan1,'smoothingspline', 'SmoothingParam', smoothparam);
plot(hanFit, daysHan1, unitsHan1)

scatter(daysTequila1,unitsTequila1, 'filled', 'b')
tequilaFit = fit(daysTequila1, unitsTequila1,'smoothingspline', 'SmoothingParam', smoothparam);
plot(tequilaFit,daysTequila1, unitsTequila1)

scatter(daysKramer1, unitsKramer1, 'filled', 'g')
kramerFit = fit(daysKramer1, unitsKramer1,'smoothingspline','SmoothingParam', smoothparam);
plot(kramerFit, daysKramer1, unitsKramer1)
scatter(daysOlive, unitsOlive, 'c', 'filled')
xlabel('Days post implantation')
ylabel('Num Units/ Total Channels')
set(gca,'TickDir','out')
title('Array Longevity')
legend('Lando', 'Han', 'Tequila', 'Kramer', 'Olive')

