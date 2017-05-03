daysLando1 =daysLando;
unitsLando1= unitsLando;
daysHan1= daysHan;
unitsHan1=unitsHan;
daysKramer1=daysKramer;
unitsKramer1=unitsKramer;
daysTequila1 = daysTequila;
unitsTequila1 = unitsTequila;
unitsOlive = 58;
daysOlive =  9;


scatter(daysLando1, unitsLando1, 'filled','k')
landoFit = fitlm(daysLando1, unitsLando1);

ylim([0,65])
xlabel('Days post implantation')
ylabel('Number of observed units')
set(gca,'TickDir','out')
title('Lando Array Longevity')
hold on
plot(landoFit)
scatter(daysHan1, unitsHan1,'filled', 'r')
hanFit = fitlm(daysHan1, unitsHan1);
plot(hanFit)
scatter(daysTequila1,unitsTequila, 'filled', 'b')
tequilaFit = fitlm(daysTequila1, unitsTequila);
plot(tequilaFit)
scatter(daysKramer1, unitsKramer1, 'filled', 'g')
kramerFit = fitlm(daysKramer1, unitsKramer1);
plot(kramerFit)
scatter(daysOlive, unitsOlive, 'c', 'filled')
xlabel('Days post implantation')
ylabel('Number of observed units')
set(gca,'TickDir','out')
title('Lando Array Longevity')
legend('Lando', 'Han', 'Tequila', 'Kramer', 'Olive')

