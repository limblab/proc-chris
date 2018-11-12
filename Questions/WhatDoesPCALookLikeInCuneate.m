clear all
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\RW\Butter\20180405\TD\Butter_RW_20180405_TD.mat')
load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Butter\20180607\TD\Butter_CO_20180607_TD.mat')
tdButter= td;
array ='cuneate';
% load('C:\Users\wrest\Documents\MATLAB\MonkeyData\CO\Lando\20170320\TD\Lando_COactpas_20170320_TD.mat')
% array = 'LeftS1';
% tdLando = td;
td = removeBadTrials(td);
td = binTD(td, 5);
td = removeBadTrials(td);
[~, td1] = getTDidx(td, 'result', 'r');
td = trimTD(td, {'idx_movement_on', 0}, {'idx_movement_on',2});
tdBump = trimTD(td1, {'idx_bumpTime', 0}, {'idx_bumpTime', 2});


paramPCA = struct('signals', {{[array,'_spikes'], find(td(1).([array, '_unit_guide'])(:,2) >0)}}, 'do_plot', true);
dimsMove= estimateDimensionality(td, paramPCA);
[td, info_move] = dimReduce(td, paramPCA); 
td = smoothSignals(td, struct('signals', [array, '_pca']));
% td = trialAverage(td, 'target_direction');

dimsBump = estimateDimensionality(tdBump, paramPCA);
[tdBump, info_bump] = dimReduce(tdBump, paramPCA);
tdBump = smoothSignals(tdBump, struct('signals', [array,'_pca']));

dirsBump = unique([tdBump.bumpDir]);
dirs = unique([td.target_direction]);

[~,rightMove] = getTDidx(td, 'target_direction', dirs(1));
[~,upMove] = getTDidx(td, 'target_direction', dirs(2));
[~,leftMove] = getTDidx(td, 'target_direction',  dirs(3));
[~,downMove] = getTDidx(td, 'target_direction', dirs(4));

[~,rightBump] = getTDidx(tdBump, 'bumpDir', dirsBump(1));
[~,upBump] = getTDidx(tdBump, 'bumpDir', dirsBump(2));
[~,leftBump] = getTDidx(tdBump, 'bumpDir',  dirsBump(3));
[~,downBump] = getTDidx(tdBump, 'bumpDir', dirsBump(4));

cuneatePCARight = cat(1, rightMove.([array, '_pca']));
cuneatePCAUp = cat(1, upMove.([array, '_pca']));
cuneatePCALeft =cat(1,leftMove.([array, '_pca']));
cuneatePCADown = cat(1,downMove.([array, '_pca']));
colors =linspecer(4);

figure
plot3(cuneatePCARight(:,1), cuneatePCARight(:,2), cuneatePCARight(:,3), 'Color', colors(1,:))
hold on
plot3(cuneatePCAUp(:,1), cuneatePCAUp(:,2), cuneatePCAUp(:,3),'Color', colors(2,:))
plot3(cuneatePCALeft(:,1), cuneatePCALeft(:,2), cuneatePCALeft(:,3),'Color', colors(3,:))
plot3(cuneatePCADown(:,1), cuneatePCADown(:,2), cuneatePCADown(:,3),'Color', colors(4,:))

cuneatePCARightBump = cat(1, rightBump.([array, '_pca']));
cuneatePCAUpBump = cat(1, upBump.([array, '_pca']));
cuneatePCALeftBump =cat(1,leftBump.([array, '_pca']));
cuneatePCADownBump = cat(1,downBump.([array, '_pca']));
colorsBump =linspecer(4);

figure
plot3(cuneatePCARightBump(:,1), cuneatePCARightBump(:,2), cuneatePCARightBump(:,3), 'Color', colorsBump(1,:))
hold on
plot3(cuneatePCAUpBump(:,1), cuneatePCAUpBump(:,2), cuneatePCAUpBump(:,3),'Color', colorsBump(2,:))
plot3(cuneatePCALeftBump(:,1), cuneatePCALeftBump(:,2), cuneatePCALeftBump(:,3),'Color', colorsBump(3,:))
plot3(cuneatePCADownBump(:,1), cuneatePCADownBump(:,2), cuneatePCADownBump(:,3),'Color', colorsBump(4,:))

axis equal

