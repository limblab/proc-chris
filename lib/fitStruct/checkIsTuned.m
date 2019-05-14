function [tuningVecAct, tuningVecPas] = checkIsTuned(neurons, cutoff)
%UNTITLED2 Summary of this function goes here
%   Detailed explanatio
    tuningVecAct = zeros(height(neurons), 1);
    tuningVecPas = zeros(height(neurons), 1);
    for i = 1:height(neurons)
        pd = neurons(i,:).actPD;
%         pd = neurons(i,:);
        tuningVecAct(i) = logical(isTuned(pd.velPD, pd.velPDCI, cutoff));
        pdPas = neurons(i,:).pasPD;
        tuningVecPas(i) = logical(isTuned(pdPas.velPD, pdPas.velPDCI, cutoff));
    end
end

