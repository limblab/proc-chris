function neurons1 = doOpensimEncoding(td, params)
    start_time = {'idx_movement_on', -10};
    end_time = {'idx_movement_on', 50};
    array = 'cuneate';
    powers = [.1:.05:1.1];
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
    
    params.signals = 'opensim';
    params.powers = powers;
    td = getPowerTD(td,params);
    for i = 1:length(params.powers)
        powerOnes = floor(params.powers(i));
        powerDec = num2str(mod(params.powers(i),1), '%.2f');
        strDec = powerDec(3:end);
        if isempty(strDec)
            strDec = '0';
        end
        powerVars{i} = [params.signals,'_', num2str(powerOnes), '_', strDec];
    end
    
    spikes = [array, '_spikes'];

    %% compute the GLMs and accuracies for move data
    

    tdLen = length(td);
   num_folds = 10;
   perms = randperm(length(td));
   guide = td(1).cuneate_unit_guide;
   encVars = {'handElb','jointAng', 'jointVel', 'muscleLen', 'muscleVel', 'joint', 'muscle', 'pos', 'vel', 'hand', powerVars{:}};
   
   
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
                      varInTemp = cat(1, td(trainInds{f}).(encVars{v}));
                      varIn = varInTemp(:,54:end);
                      varInTeTemp = cat(1, td(testInds{f}).(encVars{v}));
                      varInTe = varInTeTemp(:,54:end);
              end     
               lm1 = fitlm(varIn, fr(:,u));
               neurons(u).(encVars{v})(f) = lm1.Rsquared.Ordinary;
               neurons(u).(encVars{v})(f) = corr(predict(lm1, varInTe), frTe(:,u))^2; 
          end
      end
    disp(['done with ' num2str(u) ' of ' num2str(length(guide(:,1)))])
    end 
   
   neurons1 = struct2table(neurons);
   path = getPathFromTD(td);
   nPath = [path, filesep, 'neuronStruct', filesep, 'RefFrameEnc', filesep];
   name = [td(1).monkey, '_', td(1).date, '_', td(1).task, '_RefFrameEnc.mat'];
   mkdir(nPath)
   save([nPath,name], 'neurons1');
end