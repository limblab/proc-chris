function [keepIndsAct, keepIndsPas] = getKeepInds(velAct, velPas)
    cutoff = 3;
    keepIndsPas = [];
    keepIndsAct = [];
    for i = 1:length(velPas)
        for j = 1:length(velAct)
            if abs(norm(velPas(i,:)-velAct(j,:))) <cutoff
                keepIndsPas(end+1) = i;
                break
            end
        end
        
    end
    
    for i = 1:length(velAct)
        for j = 1:length(velPas)
            if abs(norm(velAct(i,:)-velPas(j,:))) <cutoff
                keepIndsAct(end+1) = i;
                break
            end
        end
        
    end
end