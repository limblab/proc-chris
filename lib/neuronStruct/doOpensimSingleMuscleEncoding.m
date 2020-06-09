function neurons1 = doOpensimSingleMuscleEncoding(td, params)
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
    
    spikes = [array, '_spikes'];

    %% compute the GLMs and accuracies for move data
    

   tdLen = length(td);
   num_folds = 5;
   perms = randperm(length(td));
   guide = td(1).cuneate_unit_guide;
   encVars = {'handElb','jointAng','pos','joint', 'vel','hand','muscle', 'jointVel', 'muscleLen', 'muscleVel', singMuscVar{:}};
   
   
   for u = 1:num_folds
       temp = 1:tdLen;
       testInds{u} = perms(floor((u-1)*tdLen/num_folds) +1: floor(u*tdLen/num_folds));
       temp(testInds{u})= [];
       trainInds{u} = temp;
   end
   
   
    for u = 1:length(td(1).cuneate_unit_guide(:,1))
      disp(['Unit ', num2str(u), ' of ', num2str(length(td(1).cuneate_unit_guide(:,1)))])
      
      neurons(u).monkey = td(1).monkey;
      neurons(u).date = td(1).date;
      neurons(u).chan = guide(u,1);
      neurons(u).ID = guide(u,2);
      mapping = td(1).([array,'_naming']);
      neurons(u).mapName = mapping(find(mapping(:,1) == neurons(u).chan), 2);
      for f = 1:num_folds
          disp(['Fold Number ', num2str(f)])
          
          muscNames = td(1).opensim_names(15:53);
          
          fr = cat(1,td(trainInds{f}).(spikes));

          pos = cat(1,td(trainInds{f}).pos);
          vel = cat(1,td(trainInds{f}).vel);
          os = cat(1,td(trainInds{f}).opensim);
          mark = cat(1,td(trainInds{f}).markers);
          
          jointAngs = os(:,1:7);
          jointVel = os(:,7:14);
          muscLen = os(:, 15:53);
          muscVel = os(:, 54:92);
          handMark = mark(:,22:24);
          elbMark = mark(:,4:6);
          handMarkVel = [gradient(handMark')]';
          elbMarkVel = [gradient(elbMark')]';
          
          frTe = cat(1,td(testInds{f}).(spikes));

          posTe = cat(1,td(testInds{f}).pos);
          velTe = cat(1,td(testInds{f}).vel);
          osTe = cat(1,td(testInds{f}).opensim);
          markTe = cat(1, td(testInds{f}).opensim);
          
          
          jointAngsTe = osTe(:,1:7);
          jointVelTe = osTe(:,7:14);
          muscLenTe = osTe(:, 15:53);
          muscVelTe = osTe(:, 54:92);
          handMarkTe = markTe(:,22:24);
          elbMarkTe = markTe(:,4:6);
          handMarkVelTe = [gradient(handMarkTe')]';
          elbMarkVelTe = [gradient(elbMarkTe')]';
          
          c1 = 0;
          for v = 1:length(encVars)

%               disp(['Working on', encVars{v}])         
              switch encVars{v}
                case 'jointAng'
                    varIn = jointAngs;
                    varInTe = jointAngsTe;
                case 'jointVel'
                    varIn = jointVel;
                    varInTe = jointVelTe;
                case 'muscleLen'
                    varIn = muscLen;
                    varInTe = muscLenTe;
                case 'muscleVel'
                    varIn = muscVel;
                    varInTe = muscVelTe;
                case 'joint'
                    varIn = [jointAngs, jointVel];
                    varInTe = [jointAngsTe, jointVelTe];
                case 'muscle'
                    varIn = [muscLen, muscVel];
                    varInTe = [muscLenTe, muscVelTe];
                case 'pos'
                    varIn = pos;
                    varInTe = posTe;
                case 'vel'      
                    varIn = vel;
                    varInTe = velTe;
                case 'hand'
                    varIn = [pos, vel];
                    varInTe = [posTe, velTe];
                case 'handElb'
                    varIn = [handMark, elbMark, handMarkVel, elbMarkVel];
                    varInTe = [handMarkTe, elbMarkTe, handMarkVelTe, elbMarkVelTe];
                      
                  otherwise
                      c1 = c1+1;
                    varIn = [muscLen(:,c1), muscVel(:,c1)];
                    varInTe = [muscLenTe(:,c1), muscVelTe(:,c1)];
              end     
               lm1 = fitlm(varIn, fr(:,u));
%                neurons(u).(encVars{v})(f) = lm1.Rsquared.Ordinary;
%                neurons(u).(encVars{v})(f) = corr(predict(lm1, varInTe), frTe(:,u))^2;
               ssRes = sum((frTe(:,u) - predict(lm1, varInTe)).^2);
               ssTot = sum((frTe(:,u) - mean(frTe(:,u))).^2);
               neurons(u).(encVars{v})(f) = 1 - ssRes/ssTot;
          end
      end
    disp(['done with ' num2str(u) ' of ' num2str(length(guide(:,1)))])
    end 
   
   neurons1 = struct2table(neurons);
   path = getPathFromTD(td);
   nPath = [path, filesep, 'neuronStruct', filesep, 'RefFrameSingleMuscleEnc', filesep];
   name = [td(1).monkey, '_', td(1).date, '_', td(1).task, '_RefFrameSingleMuscleEnc.mat'];
   mkdir(nPath)
   save([nPath,name], 'neurons1');
end