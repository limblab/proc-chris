function fitStruct = fitLassoModel(covar,response, params)
%%% Function fitLassoModel
%%% The purpose of this function is to fit a cross-validated Lasso GLM
%%% model to the data fed in. Its inputs are the x-values of the fit, the
%%% response variable, and a params structure, which gives information
%%% about the run. The reason for all of this meta information is that the
%%% fits take a long time, so this reduces the need to re-run in case you
%%% have to stop working, etc.
%%% Inputs:
%%% covar: the x values 
%%%     Rows: time points
%%%     Cols: features
%%% response: the y values
%%%     rows must equal rows of x
%%% params
%%%     .plotLambda: whether to plot the deviance as a function of the
%%%     regularization
%%%     .
%%%     .plotPredicted: Whether to plot the predicted reponse to get a
%%%     sense of where the model does well/ where it does poorly
%%%     
%%%     .numCV: number of cross-validation splits to do (default 10)
%%% 
%%%     .covar_names: names of columns of x inputs
%%%
%%%     .window_start: metadata about trial. What portion of trial are oyu
%%%     including at start
%%%
%%%     .window_end: more metadata
%%%
%%%     .comments: Anything you want to save for posterity
%%%
%%%     .monkey/.date/.task: metadata
%%%

%%% Output structure fields:
%%%    fitStruct.monkey
% % % fitStruct.date 
% % % fitStruct.task 
% % % fitStruct.covar
% % % fitStruct.response
% % % fitStruct.model_type
% % % fitStruct.regularizer
% % % fitStruct.fit_metric
% % % fitStruct.fit_score
% % % fitStruct.num_units
% % % fitStruct.models
% % % fitStruct.best_model
% % % fitStruct.comments 
% % % fitStruct.covar_names 
% % % fitStruct.weights 
% % % fitStruct.window_start
% % % fitStruct.window_end
% % % fitStruct = findSigParamsLasso(fitStruct); Function to pull together
% all relevant info needed to easily see what params are retained
% % % fitStruct = getMinModelLasso(fitStruct); Pulls together all info
% about minimal model (1SE from best)
% % % fitStruct = getBestModelLasso(fitStruct); Pulls together all info
% about lowest deviance model ('best')


    plotLambda = false;
    plotPredicted= false;
    numCV = 10;
    covar_names = {};
    window_start = '';
    window_end = '';
    comments = '';
    monkey= '';
    date= '';
    task = '';
    
    if nargin > 2 && ~isempty(params)
        assignParams(who,params); % overwrite parameters
    else
        params = struct();
    end
    for i = 1:length(response(1,:))
        disp(['Working on unit ' num2str(i), ' of ', num2str(length(response(1,:)))])
        [b{i}, glm{i}] = lassoglm(covar, response(:,i), 'poisson', 'CV', numCV);
        
        bestDeviance(i) =glm{i}.Deviance(glm{i}.IndexMinDeviance);
        nullDeviance(i) =glm{i}.Deviance(end);
        pR2(i) = 1- bestDeviance(i)/nullDeviance(i);
        if plotLambda
            lassoPlot(b{i}, glm{i}, 'PlotType', 'CV')
            title(['GLM CV Plot Active Electrode ', num2str(elec(i)), ' Unit ' num2str(unitN(i))])
        end
        
        [b_best{i}, glm_best{i} ] = lassoglm(covar, response(:,i), 'poisson', 'Lambda', glm{i}.LambdaMinDeviance, 'PredictorNames', covar_names);
        factors{i} = glm_best{i}.PredictorNames(b_best{i}~=0);

        [b_Minimal{i}, glm_Minimal{i}] = lassoglm(covar, response(:,i), 'poisson', 'Lambda', glm{i}.Lambda1SE, 'PredictorNames', covar_names);
        factors_Minimal{i} = glm_Minimal{i}.PredictorNames(b_Minimal{i}~=0);
        
        if plotPredicted
            fit1{i} = glmval(b_best{i}, covar, 'log', 'constant', 'off');
            figure

            yyaxis right
            plot(smooth(response(:,i)))
            yyaxis left
            plot(fit1{i})
        end
    end
    fitStruct.monkey = monkey;
    fitStruct.date = date;
    fitStruct.task = task;
    fitStruct.covar = covar;
    fitStruct.response = response;
    fitStruct.model_type = 'Poisson GLM';
    fitStruct.regularizer = 'L1';
    fitStruct.fit_metric = 'PseudoR2';
    fitStruct.fit_score = pR2;
    fitStruct.num_units = length(response(1,:));
    fitStruct.models = glm;
    fitStruct.best_model = glm_best;
    fitStruct.comments = 'Window set for entirity of active trials. Speed included as covariate';
    fitStruct.covar_names = covar_names;
    fitStruct.weights = b;
    fitStruct.window_start = window_start;
    fitStruct.window_end = window_end;
    fitStruct = findSigParamsLasso(fitStruct);
    fitStruct = getMinModelLasso(fitStruct);
    fitStruct = getBestModelLasso(fitStruct);
end

