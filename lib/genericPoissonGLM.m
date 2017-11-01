function [boot_coef] = genericPoissonGLM( response_var, indep_var )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
    num_boots = 1000;
    distribution = 'poisson';
    bootfunc = @(data) fitglm(data(:,2:end),data(:,1),'Distribution',distribution);
    tic;
    for uid = 1:size(response_var,2)
        disp(['  Bootstrapping GLM PD computation(ET=',num2str(toc),'s).'])
        %bootstrap for firing rates to get output parameters
            data_arr = [response_var indep_var];
            boot_tuning = bootstrp(num_boots,@(data) {bootfunc(data)}, data_arr);
            boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));

            if size(boot_coef,2) ~= 3
                error('getTDPDs:moveCorrProblem','GLM doesn''t have correct number of inputs')
            end
    end

end

