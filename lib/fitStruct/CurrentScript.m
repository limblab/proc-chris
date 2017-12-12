function fitStruct =getBestModelLasso(fitStruct)
    for i=1:length(fitStruct)
        param_names = fitStruct(i).covar_names;
        for j = 1:length(fitStruct(i).models)
            best_lambda_ind = fitStruct(i).models{j}.IndexMinDeviance;
            temp_struct.Intercept = fitStruct(i).models{j}.Intercept(best_lambda_ind);
            temp_struct.Lambda =fitStruct(i).models{j}.Lambda(best_lambda_ind);
            temp_struct.Alpha =1;
            temp_struct.DF =fitStruct(i).models{j}.DF(best_lambda_ind);
            temp_struct.Deviance =fitStruct(i).models{j}.Deviance(best_lambda_ind);
            
            sig_param_flag = fitStruct(i).weights{j}(:, best_lambda_ind)~=0;
            sig_params = param_names(sig_param_flag);
            
            min_deviance = fitStruct(i).models{j}.Deviance(best_lambda_ind);
            null_deviance = fitStruct(i).models{j}.Deviance(end);
            pR2 = 1- min_deviance/null_deviance;

            
            temp_struct.PredictorNames = sig_params;
            temp_struct.FitMetric = 'PseudoR2';
            temp_struct.FitVal = pR2;
            temp_struct.Weights = fitStruct(i).weights{j}(:, best_lambda_ind);
            fitStruct(i).min_model{j}=temp_struct;
            
        end

    end
end
