function fh1 = plotRWNeuronsModDepth(neurons)
    fh1 = figure;
    move_corr_num = find(~cellfun(@isempty, regexp(fieldnames(neurons.PD(1,:)), '\w*PD')));
    fields = fieldnames(neurons.PD);
    move_corr_temp = fields(move_corr_num);
    move_corr = move_corr_temp{1}(1:end-2);
    histogram(neurons.PD.([move_corr, 'Moddepth'])*20);
    title([move_corr, 'modulation Depth histogram'])
 end