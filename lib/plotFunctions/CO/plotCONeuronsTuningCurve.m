function fh1 = plotCONeuronsTuningCurve(neurons,color,  fh1)
    if nargin < 3, fh1 = figure; end % overwrite parameters
    hold on
    maxTuning = max(max(neurons.actTuningCurve.velCurveCIhigh));
    move_corr_num = find(~cellfun(@isempty, regexp(fieldnames(neurons.actPD(1,:)), '\w*PD')));
    fields = fieldnames(neurons.actPD);
    move_corr_temp = fields(move_corr_num(1));
    move_corr = move_corr_temp{1}(1:end-2);
    for i = 1:height(neurons)
        plotTuning(neurons.actPD(i,:), neurons.actTuningCurve(i,:), maxTuning,color, [], move_corr);
    end
    title('Red is Isometric, blue is kinematic')
end