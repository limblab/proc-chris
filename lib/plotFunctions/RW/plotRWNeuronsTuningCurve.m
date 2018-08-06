function fh1 = plotRWNeuronsTuningCurve(neurons,color,  fh1)
    if nargin < 3, fh1 = figure; end % overwrite parameters
    hold on
    maxTuning = max(max(neurons.tuningCurve.velCurveCIhigh));
    move_corr_num = find(~cellfun(@isempty, regexp(fieldnames(neurons.PD(1,:)), '\w*PD')));
    fields = fieldnames(neurons.PD);
    move_corr_temp = fields(move_corr_num);
    move_corr = move_corr_temp{1}(1:end-2);
    for i = 1:height(neurons)
        plotTuning(neurons.PD(i,:), neurons.tuningCurve(i,:), maxTuning,color, [], move_corr);
    end
    title('Red is Isometric, blue is kinematic')
end