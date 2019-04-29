function fh1 = plotTDConditions(td, params)

cond = 'target_direction';
xVar = {'speed'};
yVar = {'cuneate_spikes', 1};

if nargin > 1, assignParams(who,params); end % overwrite defaults

td = td(~isnan([td.(cond)]));
condsUnique = unique([td.(cond)]);
numConds = length(condsUnique);
colors = linspecer(numConds);
for j = 1:length(yVar{2})

    figure();
    hold on
    for c = 1:length(condsUnique)
        tdCond = td([td.(cond)] == condsUnique(c));
        xTD = getSig(tdCond, xVar);
        yTD = getSig(tdCond, yVar);
        scatter(xTD, yTD(:,j), 16, colors(c, :), 'filled')
        hold on
    end

end
end