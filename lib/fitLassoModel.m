function fitStruct = fitLassoModel(covar,response, params)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
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
        [b{i}, glm{i}] = lassoglm(covar, response, 'poisson', 'CV', numCV);
        
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
end

