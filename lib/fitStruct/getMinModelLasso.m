function fitStruct =getMinModelLasso(fitStruct)

    %%% Collects all of the data from the minimum model for each model type
    %%% and for each neuron in the fitStruct
    %%%
    %%% Included in this collection of data are the significant parameters,
    %%% the pseudo R2, the weights and all of the other parameters of the
    %%% model in the model structure
    for i=1:length(fitStruct)
        param_names = fitStruct(i).covar_names;
        for j = 1:length(fitStruct(i).models)
            min_lambda_ind = fitStruct(i).models{j}.Index1SE;
            temp_struct.Intercept = fitStruct(i).models{j}.Intercept(min_lambda_ind);
            temp_struct.Lambda =fitStruct(i).models{j}.Lambda(min_lambda_ind);
            temp_struct.Alpha =1;
            temp_struct.DF =fitStruct(i).models{j}.DF(min_lambda_ind);
            temp_struct.Deviance =fitStruct(i).models{j}.Deviance(min_lambda_ind);
            
            sig_param_flag = fitStruct(i).weights{j}(:, min_lambda_ind)~=0;
            sig_params = param_names(sig_param_flag);
            
            min_deviance = fitStruct(i).models{j}.Deviance(min_lambda_ind);
            null_deviance = fitStruct(i).models{j}.Deviance(end);
            pR2 = 1- min_deviance/null_deviance;

            
            temp_struct.PredictorNames = sig_params;
            temp_struct.FitMetric = 'PseudoR2';
            temp_struct.FitVal = pR2;
            temp_struct.Weights = fitStruct(i).weights{j}(:, min_lambda_ind);
            fitStruct(i).min_model{j}=temp_struct;
            
        end

    end
end

