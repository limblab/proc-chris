function neurons1 = doOpensimLassoEncoding(td, params)
    start_time = {'idx_movement_on', 0};
    end_time = {'idx_endTime', 0};
    array = 'cuneate';
    powers = [.5];
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    td = removeBadOpensim(td);

    td = tdToBinSize(td, 10);

    td = smoothSignals(td, struct('signals', [array, '_spikes'], 'calc_rate',true, 'width', .03));

    if ~isfield(td, 'idx_movement_on')
        td = getSpeed(td);
        params.start_idx =  'idx_goCueTime';
        params.end_idx = 'idx_endTime';
        td = getMoveOnsetAndPeak(td, params);
    end
    td = trimTD(td, start_time, end_time);
    td = tdToBinSize(td, 50);
    opensim_names = td(1).opensim_names;
    params.signals = 'opensim';
    count = 0;
    for i = 1:length(opensim_names)
        
        if strcmp(opensim_names{i}(end-3:end), '_len')
            count = count+1;
            singMuscVar{count} = opensim_names{i}(1:end-4);
        end
    end
    count = 0;
    for i = 1:length(singMuscVar)-1
       for j = i+1:length(singMuscVar)
           count = count +1;
           twoMuscVar{count} = [singMuscVar{i},'X',singMuscVar{j}];
       end
    end
    spikes = [array, '_spikes'];

    %% compute the GLMs and accuracies for move data
    

   tdLen = length(td);
   num_folds = 5;
   perms = randperm(length(td));
   guide = td(1).cuneate_unit_guide;
   encVars = {'handElb','jointAng','pos','joint', 'vel','hand','muscle', 'jointVel', 'muscleLen', 'muscleVel', twoMuscVar{:}};
   handVel = cat(1,td.pos);
   handPos = cat(1,td.vel);
   fr = cat(1,td.(spikes));
   os = cat(1,td.opensim);
   muscVel = os(:, 54:92);

   
   
   
    for u = 1:length(td(1).cuneate_unit_guide(:,1))
      disp(['Unit ', num2str(u), ' of ', num2str(length(td(1).cuneate_unit_guide(:,1)))])
      
      neurons(u).monkey = td(1).monkey;
      neurons(u).date = td(1).date;
      neurons(u).chan = guide(u,1);
      neurons(u).ID = guide(u,2);
      mapping = td(1).([array,'_naming']);
      neurons(u).mapName = mapping(find(mapping(:,1) == neurons(u).chan), 2);
      [bLas{u}, fitInfo{u}] = lasso(muscVel, fr(:,u), 'CV',5);
      handLM{u} = fitlm([handPos, handVel], fr(:,u));

  end
    disp(['done with ' num2str(u) ' of ' num2str(length(guide(:,1)))])

   for i = 1:length(neurons)
       neurons(i).fitInfo = fitInfo{i};
       neurons(i).handFit = handLM{i};
       neurons{i}.weights = bLas{i};
   end
   neurons1 = struct2table(neurons);
   path = getPathFromTD(td);
   nPath = [path, filesep, 'neuronStruct', filesep, 'RefFrameLassoMuscleEnc', filesep];
   name = [td(1).monkey, '_', td(1).date, '_', td(1).task, '_RefFrameLassoMuscleEnc.mat'];
   mkdir(nPath)
   save([nPath,name], 'neurons1');
end