% clear all
close all
clear all
% % 
% date = '20190418';
% monkey = 'Crackle';
date = '20190829';
monkey = 'Snap';
unitNames = 'cuneate';
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
% date = '20171122';
% monkey = 'Han';
% unitNames = 'LeftS1Area2';

% date = '20190822';
% monkey = 'Snap';
% unitNames= 'cuneate';

% mappingLog = getSensoryMappings(monkey);

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive

beforeBump = .1;
afterBump = .3;
beforeMove = .1;
afterMove = .3;

td =getTD(monkey, date, 'CO',2);
td = getSpeed(td);

target_direction = 'target_direction';
if length(td) == 1
    disp('Splitting')
    td = splitTD(td, struct('split_idx_name', 'idx_startTime', 'linked_fields', {{'bumpDir', 'ctrHold', 'ctrHoldBump', 'result', 'tgtDir', 'trialID'}} ));
    target_direction = 'tgtDir';
    params.start_idx =  'idx_goCueTime';
    params.end_idx = 'idx_endTime';
    [~, td] = getTDidx(td, 'result' ,'R');
    td = getMoveOnsetAndPeak(td, params);
    td = removeBadTrials(td);
else
end
params.start_idx =  'idx_goCueTime';
params.end_idx = 'idx_endTime';
td = getNorm(td,struct('signals','vel','field_extra','speed'));


if td(1).bin_size ==.001
    td = binTD(td, 10);
end
td = getMoveOnsetAndPeak(td,params);
neurons = getNeurons(monkey, date, 'CObump','cuneate',[windowAct; windowPas]);

td = td(~isnan([td.idx_movement_on]));
td = removeNeuronsFlag(td, neurons, {'isSorted', 'isCuneate', 'sameDayMap','~distal', '~handUnit'});

td = removeBadNeurons(td, struct('remove_unsorted', false));
% td = smoothSignals(td, struct('signals', [unitNames, '_spikes'], 'calc_rate',true, 'width', .03));

unitGuide = [unitNames, '_unit_guide'];
unitSpikes = [unitNames, '_spikes'];
savePath = [getBasePath(), getGenericTask(td(1).task), filesep,td(1).monkey,filesep date, filesep, 'plotting', filesep, 'rawAlignedPlots',filesep];

w = [.0439; .4578;1;.4578;.0439];
w = w/sum(w);


dirsM = unique([td.(target_direction)]);
dirsM = dirsM(~isnan(dirsM));
dirsM(mod(dirsM, pi/8) ~= 0) = [];
td = removeUnsorted(td);
td = getTDCuneate(td);
%%
for i = 1:length(dirsM)
    tdDir{i} = td([td.(target_direction)] == dirsM(i));
    tdDir{i} = trimTD(tdDir{i}, {'idx_movement_on', -1*beforeMove*100}, {'idx_movement_on', afterMove*100});
    tdMax{i} = trimTD(td([td.(target_direction)] == dirsM(i)), 'idx_movement_on', {'idx_movement_on', 20});
    firingMax = cat(1,tdMax{i}.([unitNames, '_spikes']));
    fMax(i,:) = mean(firingMax);
    moveSpikes{i} = cat(3, tdDir{i}.([unitNames, '_spikes']));
    meanSpikes(:,:,i) = squeeze(mean(moveSpikes{i},3));
    speeds(i,:) = mean(squeeze(cat(3,tdDir{i}.speed)),2);
    pos(i,:,:) = squeeze(mean(cat(3, tdDir{i}.pos),3));
end
bumpTrials = td(~isnan([td.bumpDir])); 
dirsBump = unique([td.bumpDir]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));


for i = 1:length(dirsBump)
    tdBump{i}= td([td.bumpDir] == dirsBump(i));
    tdBump{i} = trimTD(tdBump{i}, {'idx_bumpTime', -1*beforeBump*100}, {'idx_bumpTime', afterBump*100});
    bumpSpikes{i} = cat(3, tdBump{i}.([unitNames, '_spikes']));
    meanBSpikes(:,:,i) = squeeze(mean(bumpSpikes{i},3));
    speedsB(i,:) = mean(squeeze(cat(3,tdBump{i}.speed)),2);
    posB(i,:,:) = squeeze(mean(cat(3, tdBump{i}.pos),3));

end
maxSpeed = max(max([speedsB, speeds]))+5;
%%
close all
for i = 1:length(meanSpikes(1,:,1))
    [~, sInds(i,:)] = sort(fMax(:,i));
    max1 = max(max([squeeze(meanSpikes(:,i,:)); squeeze(meanBSpikes(:,i,:))]));
    normFR(:,i,:) = meanSpikes(:,i,:)/max1;
    normBFR(:,i,:) = meanBSpikes(:,i,:)/max1;
end
[sd,fSort] = sort(sInds(:,end));
normFR = normFR(:,fSort,:);
normBFR = normBFR(:,fSort,:);
figure
for i = 1:length(dirsM)
    normFR1 = normFR(:,:,:);
    subplot(12,1,i+4)

    imagesc(normFR1(:,:,i)')
    if i ~=8
        set(gca,'xtick',[],'ytick',[])
    else
        set(gca, 'ytick',[])
%         colorbar
        xticklabels({'-50', '0', '50', '100', '150', '200', '250', '300'}) 
    end
    hold on
    yyaxis right
    plot(speeds(i,:),'k', 'LineWidth', 2)
    ylim([0, maxSpeed])
    set(gca,'TickDir','out', 'box', 'off')

end
pos1 = reshape(pos, length(dirsM)*length(pos(1,:,1)),2);
posR = reshape(pos(:, 1:23,:), length(dirsM)*length(pos(1,1:23,1)),2);
subplot(12,1,1:4)
scatter(pos1(:,1), pos1(:,2),'k')
hold on
scatter(posR(:,1), posR(:,2), 'r')
xlim([-10,10])
ylim([-45,-25])
set(gca,'TickDir','out', 'box', 'off')

suptitle('Move Figure')

figure
for i = 1:length(dirsBump)
    normBFR1 = normBFR(:,:,:);
    subplot(12,1,i+4)
    imagesc(normBFR1(:,:,i)')
    
    if i ~=8
        set(gca,'xtick',[],'ytick',[])
    else
        set(gca, 'ytick',[])
%         colorbar
        xticklabels({'-50', '0', '50', '100', '150', '200', '250', '300'}) 

    end
    hold on
    hold on
    yyaxis right
    plot(speedsB(i,:),'k', 'LineWidth', 2)
    ylim([0, maxSpeed])

    set(gca,'TickDir','out', 'box', 'off')
    yticklabels({''}) 

end
posB1 = reshape(posB, length(dirsM)*length(posB(1,:,1)),2);
posRB1 = reshape(posB(:, 1:23,:), length(dirsM)*length(posB(1,1:23,1)),2);

subplot(12,1,1:4)
scatter(posB1(:,1), posB1(:,2),'k')
hold on
scatter(posRB1(:,1), posRB1(:,2), 'r')
set(gca,'TickDir','out', 'box', 'off')

xlim([-10,10])
ylim([-45,-25])
suptitle('Bump Figure')