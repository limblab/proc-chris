function fitStruct = findSigParamsLasso(fitStruct)
    for i=1:length(fitStruct)
        param_names = fitStruct(i).covar_names;
        for j = 1:length(fitStruct(i).models)
            best_lambda_ind = fitStruct(i).models{j}.IndexMinDeviance;
            sig_param_flag = fitStruct(i).weights{j}(:, best_lambda_ind)~=0;
            sig_params = param_names(sig_param_flag);
            fitStruct(i).sig_covars_best{j} = sig_params;
            min_lambda_ind = fitStruct(i).models{j}.Index1SE;
            sig_param_flag = fitStruct(i).weights{j}(:, min_lambda_ind)~=0;
            sig_params = param_names(sig_param_flag);
            fitStruct(i).sig_covars_min{j} = sig_params;
            
        end

    end
end

