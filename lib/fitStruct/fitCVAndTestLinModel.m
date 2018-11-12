function [cvTrained, cvUnseen , yPredOld, yPredNew, errorContrib, errorContribNew] = fitCVAndTestLinModel(td1, td2, params)
    model_name    =  'default';
    in_signals    =  {};% {'name',idx; 'name',idx};
    out_signals   =  {};% {'name',idx};
    train_idx     =  1:length(td1);
    num_folds     =  20;
    plot_on       =  false;
    onlySorted    =  true;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    assignParams(who,params); % overwrite parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Process inputs
    if isempty(in_signals) || isempty(out_signals)
        error('input/output info must be provided');
    end
    if onlySorted
        in_signals = {in_signals, find(td1(1).cuneate_unit_guide(:,2)>0)};
    end
    in_signals = check_signals(td1,in_signals);
    out_signals = check_signals(td1,out_signals);
    if iscell(train_idx) % likely to be meta info
        train_idx = getTDidx(trial_data,train_idx{:});
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % build inputs and outputs for training
    xAll = get_vars(td1(train_idx),in_signals);
    yAll = get_vars(td1(train_idx),out_signals);

    xNew = get_vars(td2, in_signals);
    yNew = get_vars(td2, out_signals);
    
    c = cvpartition(length(xAll(:,1)),'kfold', num_folds);

    for i = 1:num_folds
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fit GLMs
        x = xAll(training(c, i),:);
        y = yAll(training(c, i),:);

        xTest = xAll(test(c,i), :);
        yTest = yAll(test(c,i), :);

        b{i} = zeros(size(x,2)+1,size(y,2));
        for iVar = 1:size(y,2) % loop along outputs to predict
            b{i}(:,iVar) = [ones(size(x,1),1), x]\y(:,iVar);
            yPred{i}(:,iVar) = [ones(size(xTest,1),1), xTest]*b{i}(:,iVar);
            yPredNew{i}(:, iVar) = [ones(size(xNew,1),1), xNew]*b{i}(:,iVar);
            plot(yPred{i})
            hold on
            plot(yTest(:,iVar))
            
            R1{i} = corrcoef(yPred{i}(:,iVar), yTest(:,iVar));
            R2{i} = corrcoef(yPredNew{i}(:,iVar), yNew(:,iVar));
            r21(i) = R1{i}(1,2)^2;
            r22(i) = R2{i}(1,2)^2;
            cv(i, iVar) = r21(i);
            cvNew(i, iVar) = r22(i);
            if plot_on 
               figure 
               scatter(yPred{i}(:,iVar), yTest(:,iVar))
               hold on
               plot([-50, 50], [-50, 50])
               scatter(yPredNew{i}(:,iVar), yNew(:,iVar))
               pause
            end

            
        end  
        for j = 1:length(x(1,:))
            errorContrib(i, j) = sum(yTest - yPred{i})*2*b{i}(j+1,:)';
            errorContribNew(i, j) = sum(yNew - yPredNew{i})*2*b{i}(j+1,:)';

        end
    end
    cvTrained = cv;
    cvUnseen = cvNew;
    yPredOld = yPred;
    yPredNew = yPredNew;
end