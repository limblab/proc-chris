clearvars -except td1 td2 td3 td4
close all
butterDate = '20181218';
snapDate = '20190829';
crackleDate = '20190418';
hanDate = '20171122';
array = 'cuneate';

beforeBump = .3;
afterBump = .3;
beforeMove = .3;
afterMove = .3;
postBins = 12;

neuronsCombined = [];
if ~exist('td1')
     monkey= 'Butter';
     date = butterDate;
     number= 1;
     td1 = getTD(monkey, date, 'CO',number);
     td1 = tdToBinSize(td1,10);
   
     monkey = 'Snap';
     date = snapDate;
     number =2;
     td2 = getTD(monkey, date, 'CO',number);
      td2 = tdToBinSize(td2,10);

     
      monkey = 'Crackle';
    date = crackleDate;
    number =1;
    td3 = getTD(monkey, date, 'CO', number);
     td3 = tdToBinSize(td3,10);

     monkey = 'Han';
    date = hanDate;
    number = 1;
    td4 = getTD(monkey,date,'COactpas', number);
    td4 = tdToBinSize(td4,10);
end
for i = 1:4
%     if ~exist('td')
    switch i
        case 1
           monkey= 'Butter';
            date = butterDate;

            td = td1;
            array = 'cuneate';
        case 2
            monkey = 'Snap';
            td = td2;
            date = snapDate;
%            
        case 3
            monkey = 'Crackle';
            td = td3;
            date= crackleDate;
        case 4
            monkey = 'Han';
            date= hanDate;
            td = td4;
            array = 'LeftS1Area2';

    end

    if ~isfield(td, 'idx_movement_on')
        td = getSpeed(td);
        params.start_idx =  'idx_goCueTime';
        params.end_idx = 'idx_endTime';
        td = getMoveOnsetAndPeak(td, params);
    end
%     end
    td = removeUnsorted(td);
    if i ~=4
        mapping = getSensoryMappings(monkey);
    else
        mapping = [];
    end
    if ~isfield(td, 'speed')
        td = getSpeed(td);
    end
    dirsM = unique(round([td.target_direction],3));
    dirsM(isnan(dirsM)) =[];
    
    dirsB = unique(round([td.bumpDir],3));
    dirsB(isnan(dirsB)) =[];
    dirsB(abs(dirsB)>360) = [];
    
    tdMove = td(~isnan([td.idx_movement_on]));
    tdBump = td(~isnan([td.idx_bumpTime]));
    
    preBump = trimTD(tdBump, {'idx_bumpTime', -10}, {'idx_bumpTime', -5});
    preMove = trimTD(tdMove, {'idx_movement_on', -10}, {'idx_movement_on', -5});
    
    pMFir = mean(cat(1, preMove.([array ,'_spikes']))).*(1/td(1).bin_size);
    pBFir = mean(cat(1, preBump.([array ,'_spikes']))).*(1/td(1).bin_size);
    
    guide = td(1).([array, '_unit_guide']);
    num_units = length(guide(:,1));

    neurons{i} = table(repmat(monkey, num_units,1), repmat(date, num_units,1),guide(:,1), guide(:,2),'VariableNames', {'monkey', 'date', 'chan', 'ID'});
    
    neurons{i} = mapFromChan(neurons{i});
    neurons{i} = insertMappingsIntoNeuronStruct(neurons{i}, mapping);
    tdMove = trimTD(tdMove, 'idx_movement_on', {'idx_movement_on', postBins});
    tdBump = trimTD(tdBump, 'idx_bumpTime', {'idx_bumpTime',postBins});
    
    mFBump = zeros(postBins +1, num_units, length(dirsM));
    mFMove = zeros(postBins +1, num_units, length(dirsM));
    
    mSBump = zeros(postBins +1, length(dirsM));
    mSMove = zeros(postBins +1, length(dirsB));
    
    sensBump = zeros(postBins +1, num_units, length(dirsM));
    sensMove = zeros(postBins +1, num_units, length(dirsM));

    mmFBump = zeros(num_units, length(dirsM));
    mmFMove = zeros(num_units, length(dirsM));
    
    mmSBump = zeros(length(dirsM),1);
    mmSMove = zeros(length(dirsM),1);
    mSensBump = zeros(num_units, length(dirsM));
    mSensMove = zeros(num_units, length(dirsM));
    for j = 1:length(dirsM)
        tdBump1 = tdBump(round([tdBump.bumpDir],3) == dirsB(j));
        tdMove1 = tdMove(round([tdMove.target_direction],3) == dirsM(j));
        fBump = cat(3, tdBump1.([array ,'_spikes'])).*(1/td(1).bin_size);
        fMove = cat(3, tdMove1.([array ,'_spikes'])).*(1/td(1).bin_size);

        sBump = cat(2, tdBump1.speed);
        sMove = cat(2, tdMove1.speed);

        mFBump(:,:,j) = mean(fBump,3) - repmat(pMFir, [postBins+1, 1]);
        mFMove(:,:,j) = mean(fMove,3) - repmat(pBFir, [postBins+1, 1]);

        mSBump(:,j) = mean(sBump,2);
        mSMove(:,j) = mean(sMove,2);
        
        sensBump(:,:,j) =  bsxfun(@rdivide, mFBump(:,:,j), mSBump(:,j));
        sensMove(:,:,j) =  bsxfun(@rdivide, mFMove(:,:,j), mSMove(:,j));
        
        mmFBump(:,j) = mean(mFBump(:,:,j));
        mmFMove(:,j) = mean(mFMove(:,:,j));
        
        mmSBump(j) = mean(mSBump(:,j));
        mmSMove(j) = mean(mSMove(:,j));
        
        mSensBump(:,j) = mmFBump(:,j)./mmSBump(j);
        mSensMove(:,j) = mmFMove(:,j)./mmSMove(j);
    end
    if i~=4
        flag = neurons{i}.sameDayMap & neurons{i}.isCuneate & neurons{i}.isSpindle;
    else 
        flag = logical(ones(height(neurons{i}),1));
    end
    figure
    scatter(max(abs(mmFBump(flag,:))'), max(abs(mmFMove(flag,:))'))
    hold on
    plot([0, 70], [0, 70], 'r--','LineWidth', 3)
    title(['Max abs Change in FR in Passive vs. Active ', monkey])
    xlabel('Bump change in FR (Hz)')
    ylabel('Move change in FR (Hz)')
    
    mdl1{i} = fitlm(max(abs(mmFBump(flag,:))'), max(abs(mmFMove(flag,:))'));
    tmp = coefCI(mdl1{i});
    absFCI(i,:) = tmp(2,:);
    figure
    scatter(max(abs(mSensBump(flag,:))'), max(abs(mSensMove(flag,:))'))
    hold on
    title(['Max sensitivity Passive vs. Max sensitivity Active', monkey])
    xlabel('Change in FR (Hz/cm/s), Passive')
    ylabel('Change in FR (Hz/cm/s), Active')
    plot([0, 2.5], [0,2.5],'r--', 'LineWidth', 3)
    mdl2{i} = fitlm(max(abs(mSensBump(flag,:))'), max(abs(mSensMove(flag,:))'));
    tmp = coefCI(mdl2{i});
    sensFCI(i,:) = tmp(2,:);

end