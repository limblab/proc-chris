clear all
close all
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Lando\20170917\TD\Lando_CO_20170917_001_TD_spindleModel.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180326\TD\Butter_CO_20180326_TD_001.mat')
array = 'cuneate';

td = removeBadNeurons(td, struct('remove_unsorted', true, 'min_fr',.01));
td = getNorm(td,struct('signals','vel','norm_name','speed'));
td = normalizeTDLabels(td);

td = getMoveOnsetAndPeak(td, struct('start_idx', 'idx_goCueTime', 'end_idx', 'idx_endTime'));
[~, td] = getTDidx(td, 'result', 'R');
% td = td(~isnan([td.idx_bumpTime]));
% td = trimTD(td, 'idx_bumpTime',{'idx_bumpTime', 12});
td = trimTD(td, {'idx_movement_on',-30}, {'idx_movement_on', 80});
td = smoothSignals(td, struct('signals', 'cuneate_spikes'));

td = binTD(td, 5);

dirsM = unique([td.target_direction]);
for muscleNum = 1:length(td(1).opensim(1,:))
    fh1 = figure;
    for dir = 1:length(dirsM)
         tdDir = td([td.target_direction] == dirsM(dir));
        switch dirsM(dir)
            case 0
                subplot(3,3,6)
            case pi/4
                subplot(3,3,3)
            case pi/2
                subplot(3,3,2)
            case 3*pi/4
                subplot(3,3,1)
            case pi
                subplot(3,3,4)
            case 5*pi/4
                subplot(3,3,7)
            case 3*pi/2
                subplot(3,3,8)
            case 7*pi/4
                subplot(3,3,9)
        end
        muscleAll = cat(3, tdDir.opensim);
        muscle = squeeze(muscleAll(:, muscleNum, :));
        plot(linspace(-.3, .8, length(muscle(:,1))), mean(muscle,2))
        hold on
%         plot(linspace(-.3, .3, length(muscle)), muscle, 'r')
    end
    suptitle(td(1).opensim_names(muscleNum))
    pause
    

end