clear all 
close all
monkey = 'Lando';
task = 'CO';
date = '20170917';

td = getTD(monkey, date, task, 1);
tdMove = td(~isnan([td.target_direction]));
tdBump1 = td(~isnan([td.bumpDir]));
tdBump1 = tdBump1(~isnan([tdBump1.idx_bumpTime]));

params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
tdMove = getMoveOnsetAndPeak(tdMove, params);

tdMove= trimTD(tdMove, 'idx_movement_on', {'idx_movement_on', 20});
tdBump1 = trimTD(tdBump1, 'idx_bumpTime', {'idx_bumpTime', 13});

moveMuscles = cat(3, tdMove.opensim);
bumpMuscles = cat(3, tdBump1.opensim);

%%
dirsM = unique([td.target_direction]);
dirsM = dirsM(~isnan(dirsM));


for i = 1:length(dirsM)
    tdDir{i} = tdMove([tdMove.target_direction] == dirsM(i));
    tdDir{i} = tdDir{i}(isnan([tdDir{i}.bumpDir]));
%     tdDir{i} = tdDir{i}([tdDir{i}.idx_endTime] - [tdDir{i}.idx_goCueTime] < 1/tdDir{i}(1).bin_size);
end
bumpTrials = tdBump1(~isnan([tdBump1.bumpDir])); 
dirsBump = unique([tdBump1.bumpDir]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));


for i = 1:length(dirsBump)
    tdBump{i}= tdBump1([tdBump1.bumpDir] == dirsBump(i));
end

%%
close all

colors = linspecer(length(dirsM));
for muscle = 6
    figure2();
    hold on
    title(tdDir{1}(1).opensim_names(muscle))
    for dir = 1:length(dirsM)
        for trial = 1:length(tdDir{dir})
            plot(tdDir{dir}(1).bin_size:.01: .01*length(tdDir{dir}(trial).pos(:,1)),tdDir{dir}(trial).opensim(:, muscle),'Color', colors(dir,:))
        end
    end
    
    figure2();
    hold on
    title([tdDir{1}(1).opensim_names(muscle), ' Mean Length'])
    for dir = 1:length(dirsM)
        opensim1 = cat(3, tdDir{dir}.opensim);
        opensimMuscle = squeeze(opensim1(:,muscle,:));
        opensimAvg = mean(opensimMuscle,2);
        plot(tdDir{dir}(1).bin_size:.01: .01*length(tdDir{dir}(1).pos(:,1)),opensimAvg,'Color', colors(dir,:))

    end
    legend({'Right', 'Up', 'Left', 'Down'})
end
%%
colors = linspecer(length(dirsBump));
for muscle = 6
    figure();
    hold on
    title([tdBump{1}(1).opensim_names(muscle), ' Bump'])
    for dir = 1:length(dirsBump)
        for trial = 1:length(tdBump{dir})
            plot(tdBump{dir}(1).bin_size:.01: .01*length(tdBump{dir}(trial).pos(:,1)),tdBump{dir}(trial).opensim(:, muscle),'Color', colors(dir,:))
        end
    end
    
    figure();
    hold on
    title([tdBump{1}(1).opensim_names(muscle), ' Bump'])
    for dir = 1:length(dirsBump)
        opensim1 = cat(3, tdBump{dir}.opensim);
        opensimMuscle = squeeze(opensim1(:,muscle,:));
        opensimAvg = mean(opensimMuscle,2);
        plot(tdBump{dir}(1).bin_size:.01: .01*length(tdBump{dir}(1).pos(:,1)),opensimAvg,'Color', colors(dir,:))

    end
    legend({'Right', 'Up', 'Left', 'Down'})
end