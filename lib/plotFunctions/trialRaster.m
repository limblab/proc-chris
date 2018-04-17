function fhRaster = trialRaster(trial,params)
%     params.figureHandle;
%     cla(gca);
    barX = 0;
    bumpTime = -10000;
    moveTime = -10000;
    goTime = -10000;
    array = 'cuneate';
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    binWidth = trial.bin_size;
    numUnits =  length(trial.([array, '_spikes'])(1,:));
    figure
    hold on
    count = 0;
    subplot(5,1,4:5)
    hold on
%     plot([barX, barX], [0, numUnits+1], 'r', 'LineWidth', 2)
    if length(bumpTime) ~= 1
        rectangle('Position', [binWidth*bumpTime(1), 0, binWidth*13, numUnits+1])
    end
    plot([moveTime*binWidth, moveTime*binWidth], [0, numUnits+1], 'r')
    plot([goTime*binWidth, goTime*binWidth], [0, numUnits+1], 'b')
    for neuron = 1:numUnits
        count =count +1;
       for spike = 1:length(trial.([array, '_ts']){neuron})
           plot([trial.([array, '_ts']){neuron}(spike), trial.([array, '_ts']){neuron}(spike)], [count, count+.8], 'k')
       end
    end
    xlim([-.4,binWidth*(length(trial.pos(:,1))-40)])
    ylim([0,count+1])
    
    subplot(5,1,3)
    clist1= colormap(parula(length(trial.pos(:,1))));
    scatter(linspace(-.4,binWidth*(length(trial.pos(:,1))-40), length(trial.pos(:,1))) , rownorm(trial.vel),[], clist1)
    xlim([-binWidth*trial.idx_startTime,binWidth*(length(trial.pos(:,1))-trial.idx_startTime)])
    
    subplot(5,1,1:2)
    clist = colormap(parula(length(trial.pos(:,1))));
    scatter(trial.pos(:,1), trial.pos(:,2),[], clist)
    ylim([-50, -20])
    xlim([-15,15])
    fhRaster = gca;
end

