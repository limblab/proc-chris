% clear all
close all
clear all
% % 
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

beforeBump = .3;
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
neurons = getNeurons('Snap', '20190829', 'CObump','cuneate');

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
end
bumpTrials = td(~isnan([td.bumpDir])); 
dirsBump = unique([td.bumpDir]);
dirsBump = dirsBump(abs(dirsBump)<361);
dirsBump = dirsBump(~isnan(dirsBump));


for i = 1:length(dirsBump)
    tdBump{i}= td([td.bumpDir] == dirsBump(i));
    tdBump{i} = trimTD(tdBump{i}, {'idx_bumpTime', -1*beforeBump*100}, {'idx_bumpTime', afterBump*100});
    moveSpikes{i} = cat(3, tdDir{i}.([unitNames, '_spikes']));
end

%%
for i = 1:length(meanSpikes(1,:,1))
    [~, sInds(i,:)] = sort(fMax(:,i));
    normFR(:,i,:) = meanSpikes(:,i,:)/max(max(meanSpikes(:,i,:)));
end
[sd,fSort] = sort(sInds(:,end));
normFR = normFR(:,fSort,:);
figure
for i = 1:length(dirsM)
    normFR1 = normFR(:,:,:);
    subplot(8,1,i)
    imagesc(normFR1(:,:,i)')
    set(gca,'TickDir','out', 'box', 'off')
    if i ~=8
        set(gca,'xtick',[],'ytick',[])
    else
        set(gca, 'ytick',[])
        xticklabels({'-200', '-100', '0', '100', '200', '300','400', '500', '600'})
%         colorbar

    end
end