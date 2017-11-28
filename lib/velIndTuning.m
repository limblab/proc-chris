function [tuningParams, mdl, mdl1, mdl2, comboModel, rTable ] = velIndTuning(td, params)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    arrayName = params.array;
    vel = cat(1, td.vel);
    xvel = vel(:,1);
    yvel = vel(:,2);
    speed = rownorm(vel)';
    numUnits = length(td(1).([arrayName, '_spikes'])(1,:));
    spiking =  cat(1,td.([arrayName, '_spikes']));
    for i = 1: numUnits
        mdl{i} = fitglm(speed, spiking(:,i),'Distribution', 'poisson');
        mdl2{i} = fitglm([xvel, yvel], spiking(:,i), 'Distribution', 'poisson');
        residual= mdl{i}.Residuals.Raw;
        speedParam = mdl{i}.Coefficients(2, 1);
        mdl1{i} = fitlm([xvel, yvel], residual);
        xParam = mdl1{i}.Coefficients.Estimate(2);
        yParam = mdl1{i}.Coefficients.Estimate(3);
        dir(i) = atan2(yParam,xParam);
        tuningParams(i).PD = dir(i);
        comboModel{i}= fitglm([speed, xvel, yvel], spiking(:,i));
        rTable(i, 1) = mdl{i}.Rsquared.Ordinary;
        rTable(i,2) = mdl1{i}.Rsquared.Ordinary;
        rTable(i,3) = mdl2{i}.Rsquared.Ordinary;
        rTable(i,4) = comboModel{i}.Rsquared.Ordinary;
    end
    
end

