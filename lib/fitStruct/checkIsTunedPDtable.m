function [tuningVecAct, tuningVecPas] = checkIsTunedPDtable(neurons, cutoff, var)
%UNTITLED2 Summary of this function goes here
%   Detailed explanatio
    tuningVecAct = zeros(height(neurons), 1);
    tuningVecPas = zeros(height(neurons), 1);
    for i = 1:height(neurons)
%         pd = neurons(i,:).actPD;
        pd = neurons(i,:);
        tuningVecAct(i) = logical(isTuned(pd.([var, 'PD']), pd.([var, 'PDCI']), cutoff));
%         pdPas = neurons(i,:).pasPD;
%         tuningVecPas(i) = logical(isTuned(pdPas.velPD, pdPas.velPDCI, cutoff));
    end
end

