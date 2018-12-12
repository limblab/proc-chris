function [b, dev, stats, acc] = multinomialLogRegressionCV(input, output,num_folds)
    c = cvpartition(length(input(:,1)),'kfold', num_folds);

    for i = 1:num_folds
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fit GLMs
        x = input(training(c, i),:);
        y = output(training(c, i),:);
        
        xTest = input(test(c,i), :);
        yTest = output(test(c,i), :);
        
        [b, dev, stats] = mnrfit(x, y);
        pred = mnrval(b, xTest);
        [~, predCat] = max(pred, [],2);
        acc(i) = sum(predCat== yTest)/length(yTest);
    end
end