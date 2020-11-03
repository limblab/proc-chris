function [varCNAct, varCNPas, varS1Act, varS1Pas] = crossCompareBumpMoveCNS1(cnAct, cnPas, s1Act, s1Pas, covar1)
[files, numAxes, numBoots] = size(cnAct);
[filesS1, numAxes, numBoots] = size(s1Act);

minUnits = numBoots;
mcnAct = mean(cnAct,3);
ms1Act = mean(s1Act,3);
mcnActMarg = mean(mcnAct);
ms1ActMarg = mean(ms1Act);

mcnPas = mean(cnPas,3);
ms1Pas = mean(s1Pas,3);
mcnPasMarg = mean(mcnPas);
ms1PasMarg = mean(ms1Pas);

for axis1 = 1:numAxes
    switch axis1
        case 1
            axisName = 'X';
        case 2
            axisName = 'Y';
    end
    
    figure
    edges= 0:0.05:1;
    subplot(2,1,1)
    for i = 1:length(mcnAct(:,1))
        histogram(cnAct(i,axis1,:), edges)
        hold on
        varCNAct(i,axis1) = var(cnAct(i,axis1,:));
    end
    title([axisName, ' ',covar1, ' Decoding Accuracy with 10 random CN neurons'])
    xlabel('Act R2')
    ylabel('# of models')
    subplot(2,1,2)
    for i = 1:length(mcnAct(:,1))
        histogram(cnPas(i,axis1,:), edges)
        hold on
        varCNPas(i,axis1) = var(cnPas(i,axis1,:));
    end
    title([axisName, ' ', covar1, ' Bump Decoding Accuracy with 10 random CN neurons'])
    xlabel('Bump R2')
    ylabel('# of models')

    figure
    edges= 0:0.05:1;
    subplot(2,1,1)
    for i = 1:length(ms1Act(:,1))
        histogram(s1Act(i,axis1,:), edges)
        hold on
        varS1Act(i,axis1) = var(s1Act(i,axis1,:));
    end
    title([axisName, ' ',covar1, ' Decoding Accuracy with 10 random S1 neurons'])
    xlabel('R2')
    ylabel('# of models')

    subplot(2,1,2)
    for i = 1:length(ms1Pas(:,1))
        histogram(s1Pas(i,axis1,:), edges)
        hold on
        varS1Pas(i,axis1) = var(s1Pas(i,axis1,:));
    end
    title([axisName, ' ',covar1, ' Bump Decoding Accuracy with 10 random S1 neurons'])
    xlabel('Bump R2')
    ylabel('# of models')
end
    
end