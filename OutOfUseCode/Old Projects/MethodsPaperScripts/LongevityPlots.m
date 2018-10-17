daysLando1 =daysLando(2:end);
unitsLando1= unitsLando(2:end);
daysHan1= daysHan(2:end);
unitsHan1=unitsHan(2:end);
daysKramer1=daysKramer(2:end);
unitsKramer1=unitsKramer(2:end);
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

