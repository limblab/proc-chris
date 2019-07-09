%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [trial_data,model_info] = getCVModelParams(trial_data,params)
%
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cv, model_info] = getCVModelParams(trial_data,params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT PARAMETERS
model_type    =  '';
model_name    =  'default';
in_signals    =  {};% {'name',idx; 'name',idx};
out_signals   =  {};% {'name',idx};
train_idx     =  1:length(trial_data);
num_folds     =  5;

% GLM-specific parameters
do_lasso      =  false;
lasso_lambda  =  0;
lasso_alpha   =  0;
nn_params = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here are some parameters that you can overwrite that aren't documented
add_pred_to_td       =  true;        % whether to add predictions to trial_data
glm_distribution     =  'poisson';   % which distribution to assume for GLM
td_fn_prefix         =  '';  % name prefix for trial_data field
b                    =  [];          % b and s identify if model_info was
s                    =  [];          %    provided as a params input

layer_sizes = [10,10];
train_func = 'trainlm';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assignParams(who,params); % overwrite parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process inputs
if isempty(model_type), error('Must specify what type of model to fit'); end
if isempty(in_signals) || isempty(out_signals)
    error('input/output info must be provided');
end
if isempty(td_fn_prefix), td_fn_prefix = model_type; end
in_signals = check_signals(trial_data(1),in_signals);
out_signals = check_signals(trial_data(1),out_signals);
if iscell(train_idx) % likely to be meta info
    train_idx = getTDidx(trial_data,train_idx{:});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(b)  % fit a new model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % build inputs and outputs for training
    xAll = get_vars(trial_data(train_idx),in_signals);
    yAll = get_vars(trial_data(train_idx),out_signals);
    
    c = cvpartition(length(xAll(:,1)),'kfold', num_folds);

    for i = 1:num_folds
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fit GLMs
        x = xAll(training(c, i),:);
        y = yAll(training(c, i),:);
        
        xTest = xAll(test(c,i), :);
        yTest = yAll(test(c,i), :);
        
        b{i} = zeros(size(x,2)+1,size(y,2));
        switch lower(model_type)
            case 'glm'
                for iVar = 1:size(y,2) % loop along outputs to predict
                    if do_lasso % not quite implemented yet
                        % NOTE: Z-scores here!
                        [b_temp,s_temp] = lassoglm(zscore(x),y(:,iVar),glm_distribution,'lambda',lasso_lambda,'alpha',lasso_alpha);
                        b{i}(:,iVar) = [s_temp.Intercept; b_temp];
                    else
                        [b{i}(:,iVar),~,s_temp] = glmfit(x,y(:,iVar),glm_distribution);
                    end
                    if isempty(s)
                        s{i} = s_temp;
                    else
                        s{i}(iVar) = s_temp;
                    end
                    yPred{i} = glmval(b{i}(:,iVar), xTest, 'log'); 
                    cv(i,iVar) = get_metric(yTest(:,iVar), yPred{i}, 'pr2', 1);
                end
            case 'linmodel'
                for iVar = 1:size(y,2) % loop along outputs to predict
                    b{i}(:,iVar) = [ones(size(x,1),1), x]\y(:,iVar);
                    yPred{i} = [ones(size(xTest,1),1), xTest]*b{i}(:,iVar);
                    cv(i, iVar) = 1-norm(yPred{i}-yTest(:,iVar))/norm(mean(yTest(:, iVar))-yTest(:, iVar));
                end
            case 'nn'
                net = feedforwardnet(layer_sizes, train_func);
                net{i} = train(net, x', y');
                b{i} = net;
                yPred{i}  = net(xTest');
        end
    end

else % use an old GLM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % these parameters should already be assigned from assignParams
%     fn = fieldnames(params);
%     for i = 1:length(fn)
%         assignin('caller',fn{i},params.(fn{i}));
%     end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Package up outputs
switch lower(model_type)
    case 'glm'
        if strcmpi(model_type,'glm') && ~do_lasso
            if isfield(s,'resid')
                s = rmfield(s,{'resid','residp','residd','resida','wts'});
            end
        end
        model_info = struct( ...
            'model_type',   model_type, ...
            'model_name',   model_name, ...
            'in_signals',   {in_signals}, ...
            'out_signals',  {out_signals}, ...
            'train_idx',    train_idx, ...
            'b',            b, ...
            's',            s, ...
            'do_lasso',     do_lasso, ...
            'lasso_lambda', lasso_lambda, ...
            'lasso_alpha',  lasso_alpha);
        
    case 'linmodel'
        model_info = struct( ...
            'model_type',   model_type, ...
            'model_name',   model_name, ...
            'in_signals',   {in_signals}, ...
            'out_signals',  {out_signals}, ...
            'train_idx',    train_idx, ...
            'b',            b);
    case 'nn'
        model_info = struct(...
            'model_type',   model_type, ...
            'model_name',   model_name, ...
            'in_signals',   {in_signals}, ...
            'out_signals',  {out_signals}, ...
            'train_idx',    train_idx, ...
            'b',            b);
end
end

