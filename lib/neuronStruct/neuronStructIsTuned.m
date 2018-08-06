function tuned = neuronStructIsTuned(neurons, params)
    cutoff = pi/4;
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    move_corr_num = find(~cellfun(@isempty, regexp(fieldnames(neurons.PD(1,:)), '\w*PD')));
    fields = fieldnames(neurons.PD);
    move_corr_temp = fields(move_corr_num);
    move_corr = move_corr_temp{1}(1:end-2);
    tuned = isTuned(neurons.PD.([move_corr, 'PD']), neurons.PD.([move_corr, 'PDCI']), cutoff);
end