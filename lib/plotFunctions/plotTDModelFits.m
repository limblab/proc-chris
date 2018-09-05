function fh1 = plotTDModelFits(td, params)
    models = 'glm';
    output = 'cuneate_spikes';
    array = 'cuneate';
    outputNum = 4;
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    fn = fieldnames(td);
    pat = models;
    model_fields = find(~cellfun(@isempty, strfind(fn, pat)));
    figure
    act = cat(1, td.([array, '_spikes']));
    plot(td(1).bin_size:td(1).bin_size:td(1).bin_size*length(act(:,1)), smooth(act(:,outputNum)))
    hold on
    for i = 1:length(model_fields)
        pred = cat(1, td.(fn{model_fields(i)}));
        plot(td(1).bin_size:td(1).bin_size:td(1).bin_size*length(act(:,1)), pred(:,outputNum))
        hold on
    end
    xlim([20,30])
    legend({'Actual firing', fn{model_fields}})
end