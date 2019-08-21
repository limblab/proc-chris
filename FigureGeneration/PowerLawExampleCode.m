x = 1:50;
y = x.^.25 + .5*rand(length(x),1)';

scatter(x,y, 16, 'filled')
set(gca,'TickDir','out', 'box', 'off')



