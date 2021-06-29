function neurons = doNeuronsIncreaseAllDirs(neurons, td, params)

windowAct= []; %Default trimming windows active
windowPas =[]; % Default trimming windows passive

if nargin > 2, assignParams(who,params); end % overwrite parameters

td = tdToBinSize(td,10);

filds = fieldnames(td);
array = filds(contains(filds, '_spikes'),:);
array = array{1}(1:end-7);
arr_spikes = [array, '_spikes'];

dirsMCN = unique([td.target_direction]);
dirsMCN(isnan(dirsMCN)) = [];

guideCN = td.([array, '_unit_guide']);

firingCN = zeros(length(dirsMCN), length(guideCN(:,1)));

tdPre = trimTD(td,  {'idx_movement_on', -10}, {'idx_movement_on', -5});

pre = mean(cat(1,tdPre.(arr_spikes)));



for i = 1:length(dirsMCN)
    tdDirCN{i} = td([td.target_direction]==dirsMCN(i));
    tdDirCN{i} = tdDirCN{i}(isnan([tdDirCN{i}.idx_bumpTime]));
    
    tdCNMove = trimTD(tdDirCN{i}, 'idx_movement_on', {'idx_movement_on', 30});
        
    firingCN(i,:) = mean(cat(1,tdCNMove.(arr_spikes))); 
    
    
end
%%
plotting = false;
firDifCN = zeros(size(firingCN));
for i = 1:length(firingCN(1,:))
    if plotting
        figure
        plot(firingCN(:,i))
        hold on
        plot([0,9],[pre(i), pre(i)], 'r')
        title(['Cuneate Elec ', num2str(guideCN(i,1)), ' Unit ' , num2str(guideCN(i,2)),' ', nCN(i,:).desc])
    end
    firDifCN(:,i) = firingCN(:,i) - repmat(pre(i), length(firingCN(:,i)),1);
    neurons.firingChangeMove(i,:) = firDifCN(:,i)';
    neurons.increaseAllDirs(i) = all(firDifCN(:,i) >0);
end
%%


end